import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/vitals_generator.dart';
import '../home_page.dart'; // for Vitals model

/// Full analytics screen for heart rate.
class HeartRateAnalytics extends StatefulWidget {
  const HeartRateAnalytics({super.key});
  @override
  State<HeartRateAnalytics> createState() => _HeartRateAnalyticsState();
}

class _HeartRateAnalyticsState extends State<HeartRateAnalytics>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }
  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Rate Analytics'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Real‑Time'),
            Tab(text: 'Last Hour'),
            Tab(text: 'Last Day'),
            Tab(text: 'Last Month'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _HRRealtime(),
          _HRLastHour(),
          _HRLastDay(),
          _HRLastMonth(),
        ],
      ),
    );
  }
}

/// 1️⃣ Real‑Time: last 60 seconds from VitalsGenerator.stream
class _HRRealtime extends StatefulWidget {
  const _HRRealtime();
  @override
  State<_HRRealtime> createState() => _HRRealtimeState();
}

class _HRRealtimeState extends State<_HRRealtime> {
  final _points = <FlSpot>[];
  late final DateTime _start;
  late final StreamSubscription<Vitals> _sub;

  @override
  void initState() {
    super.initState();
    _start = DateTime.now();
    _sub = VitalsGenerator.stream.listen((v) {
      final t = DateTime.now().difference(_start).inSeconds.toDouble();
      setState(() {
        _points.add(FlSpot(t, v.heartRate.toDouble()));
        if (_points.length > 60) _points.removeAt(0);
      });
    });
  }
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          minX: _points.isEmpty ? 0 : _points.first.x,
          maxX: _points.isEmpty ? 60 : _points.last.x,
          minY: 0, maxY: 200,
          lineBarsData: [LineChartBarData(spots: _points, isCurved: true, dotData: FlDotData(show: false))],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, interval: 10,
                getTitlesWidget: (v, _) => Text('${v.toInt()}s'),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, interval: 20,
                getTitlesWidget: (v, _) => Text('${v.toInt()}'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 2️⃣ Last Hour: minuteAverages for past 60 minutes
class _HRLastHour extends StatelessWidget {
  const _HRLastHour();
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final now = DateTime.now();
    final hourAgo = now.subtract(const Duration(hours: 1));
    final stream = FirebaseFirestore.instance
      .collection('users').doc(uid)
      .collection('minuteAverages')
      .where('timestamp', isGreaterThan: hourAgo.toIso8601String())
      .orderBy('timestamp')
      .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (ctx, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final spots = snap.data!.docs.map((d) {
          final data = d.data()! as Map;
          final ts = DateTime.parse(data['timestamp']);
          final x = ts.difference(hourAgo).inMinutes.toDouble();
          final y = (data['heartRate'] as int).toDouble();
          return FlSpot(x, y);
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: LineChart(LineChartData(
            minX: 0, maxX: 60, minY: 0, maxY: 200,
            lineBarsData: [LineChartBarData(spots: spots)],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 10,
                getTitlesWidget: (v, _) {
                  final dt = hourAgo.add(Duration(minutes: v.toInt()));
                  return Text('${dt.hour}:${dt.minute.toString().padLeft(2,'0')}');
                },
              )),
            ),
          )),
        );
      },
    );
  }
}

/// 3️⃣ Last Day: hourlyAverages for past 24 hours
class _HRLastDay extends StatelessWidget {
  const _HRLastDay();
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final now = DateTime.now();
    final ago = now.subtract(const Duration(days: 1));
    final stream = FirebaseFirestore.instance
      .collection('users').doc(uid)
      .collection('hourlyAverages')
      .where('timestamp', isGreaterThan: ago.toIso8601String())
      .orderBy('timestamp')
      .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (ctx, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final spots = snap.data!.docs.map((d) {
          final data = d.data()! as Map;
          final ts = DateTime.parse(data['timestamp']);
          final x = ts.difference(ago).inHours.toDouble();
          final y = (data['heartRate'] as int).toDouble();
          return FlSpot(x, y);
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: LineChart(LineChartData(
            minX: 0, maxX: 24, minY: 0, maxY: 200,
            lineBarsData: [LineChartBarData(spots: spots)],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 4,
                getTitlesWidget: (v, _) => Text('${v.toInt()}h'),
              )),
            ),
          )),
        );
      },
    );
  }
}

/// 4️⃣ Last Month: group hourlyAverages by day for past 30 days
class _HRLastMonth extends StatelessWidget {
  const _HRLastMonth();
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    final stream = FirebaseFirestore.instance
      .collection('users').doc(uid)
      .collection('hourlyAverages')
      .where('timestamp', isGreaterThan: monthAgo.toIso8601String())
      .orderBy('timestamp')
      .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (ctx, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final byDay = <String, List<dynamic>>{};
        for (var d in snap.data!.docs) {
          final data = d.data()! as Map;
          final ts = DateTime.parse(data['timestamp']);
          final key = '${ts.year}-${ts.month}-${ts.day}';
          (byDay[key] ??= []).add(data['heartRate'] as int);
        }
        final spots = byDay.entries.map((e) {
          final parts = e.key.split('-');
          final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          final x = dt.difference(monthAgo).inDays.toDouble();
          final avg = e.value.reduce((a, b) => a + b) / e.value.length;
          return FlSpot(x, avg);
        }).toList()..sort((a, b) => a.x.compareTo(b.x));

        return Padding(
          padding: const EdgeInsets.all(16),
          child: LineChart(LineChartData(
            minX: 0, maxX: 30, minY: 0, maxY: 200,
            lineBarsData: [LineChartBarData(spots: spots)],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 5,
                getTitlesWidget: (v, _) {
                  final dt = monthAgo.add(Duration(days: v.toInt()));
                  return Text('${dt.month}/${dt.day}');
                },
              )),
            ),
          )),
        );
      },
    );
  }
}
