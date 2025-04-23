import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/vitals_generator.dart';
import '../home_page.dart'; // for Vitals model

/// Full analytics screen for temperature.
class TemperatureAnalytics extends StatefulWidget {
  const TemperatureAnalytics({super.key});
  @override
  State<TemperatureAnalytics> createState() => _TemperatureAnalyticsState();
}

class _TemperatureAnalyticsState extends State<TemperatureAnalytics>
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
        title: const Text('Temperature Analytics'),
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
          _TempRealtime(),
          _TempLastHour(),
          _TempLastDay(),
          _TempLastMonth(),
        ],
      ),
    );
  }
}

/// 1️⃣ Real‑Time: last 60 seconds from VitalsGenerator.stream
class _TempRealtime extends StatefulWidget {
  const _TempRealtime();
  @override
  State<_TempRealtime> createState() => _TempRealtimeState();
}

class _TempRealtimeState extends State<_TempRealtime> {
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
        _points.add(FlSpot(t, v.temperature));
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
      child: LineChart(LineChartData(
        minX: _points.isEmpty ? 0 : _points.first.x,
        maxX: _points.isEmpty ? 60 : _points.last.x,
        minY: 34,
        maxY: 40,
        lineBarsData: [
          LineChartBarData(
            spots: _points,
            isCurved: true,
            dotData: FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 10,
              getTitlesWidget: (v, _) => Text('${v.toInt()}s'),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 1,
              getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1)),
            ),
          ),
        ),
      )),
    );
  }
}

/// 2️⃣ Last Hour: minuteAverages over past 60 minutes
class _TempLastHour extends StatelessWidget {
  const _TempLastHour();
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
          final y = (data['temperature'] as num).toDouble();
          return FlSpot(x, y);
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: LineChart(LineChartData(
            minX: 0, maxX: 60, minY: 34, maxY: 40,
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

/// 3️⃣ Last Day: hourlyAverages over past 24 hours
class _TempLastDay extends StatelessWidget {
  const _TempLastDay();
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
          final y = (data['temperature'] as num).toDouble();
          return FlSpot(x, y);
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: LineChart(LineChartData(
            minX: 0, maxX: 24, minY: 34, maxY: 40,
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
class _TempLastMonth extends StatelessWidget {
  const _TempLastMonth();
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

        // group by day
        final byDay = <String, List<double>>{};
        for (var d in snap.data!.docs) {
          final data = d.data()! as Map;
          final ts = DateTime.parse(data['timestamp']);
          final key = '${ts.year}-${ts.month}-${ts.day}';
          (byDay[key] ??= []).add((data['temperature'] as num).toDouble());
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
            minX: 0, maxX: 30, minY: 34, maxY: 40,
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
