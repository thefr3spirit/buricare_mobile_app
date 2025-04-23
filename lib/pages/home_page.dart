import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/vitals_generator.dart';
import '../services/vitals_pipeline.dart';
import '../services/notification_service.dart';              // ← import notifications

import 'analytics/heart_rate_analytics.dart';
import 'analytics/temperature_analytics.dart';
import 'analytics/spo2_analytics.dart';

// Bring in your pipelineProvider from main.dart
import 'package:buricare/main.dart';

/// A single reading of the three vitals at a given instant.
class Vitals {
  final int heartRate;
  final double temperature;
  final int spo2;
  final DateTime timestamp;

  Vitals({
    required this.heartRate,
    required this.temperature,
    required this.spo2,
    required this.timestamp,
  });
}

/// Emits a new [Vitals] whenever fresh data arrives.
final vitalsStreamProvider = StreamProvider<Vitals>((ref) {
  return VitalsGenerator.stream;
});

/// Dashboard page showing three real‑time vitals tiles,
/// starting the pipeline, and surfacing alerts.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  late final VitalsPipeline _pipeline;
  late final StreamSubscription<Vitals> _alertSub;

  // Track which vitals are currently in a breach,
  // so we only alert once per breach
  bool _hrBreached = false, _tempBreached = false, _spo2Breached = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Start your pipeline
    _pipeline = ref.read(pipelineProvider);

    // Listen for vitals and check for out‐of‐range
    _alertSub = VitalsGenerator.stream.listen(_checkForAlerts);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _alertSub.cancel();
    _pipeline.dispose();
    super.dispose();
  }

  void _checkForAlerts(Vitals v) {
    // Heart rate out‑of‑range?
    if (!_hrBreached && (v.heartRate < 120 || v.heartRate > 160)) {
      _hrBreached = true;
      _showAlert('⚠️ Heart rate out of range: ${v.heartRate} bpm');
    } else if (_hrBreached && v.heartRate >= 120 && v.heartRate <= 160) {
      _hrBreached = false;
    }

    // Temperature out‑of‑range?
    if (!_tempBreached && (v.temperature < 36.5 || v.temperature > 37.5)) {
      _tempBreached = true;
      _showAlert(
        '⚠️ Temperature out of range: ${v.temperature.toStringAsFixed(1)} °C',
      );
    } else if (_tempBreached && v.temperature >= 36.5 && v.temperature <= 37.5) {
      _tempBreached = false;
    }

    // SpO₂ out‑of‑range?
    if (!_spo2Breached && v.spo2 < 95) {
      _spo2Breached = true;
      _showAlert('⚠️ SpO₂ out of range: ${v.spo2}%');
    } else if (_spo2Breached && v.spo2 >= 95) {
      _spo2Breached = false;
    }
  }

  void _showAlert(String message) {
    // 1) In‑app banner
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 4),
      ),
    );

    // 2) System notification
    NotificationService.showAlert(message);
  }

  @override
  Widget build(BuildContext context) {
    final vitalsAsync = ref.watch(vitalsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('BuriCare Dashboard')),
      body: vitalsAsync.when(
        data: (v) => _buildVitalsGrid(context, v),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildVitalsGrid(BuildContext context, Vitals v) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _VitalsTile(
            label: 'Heart Rate',
            value: '${v.heartRate} bpm',
            icon: Icons.favorite,
            color: Colors.red,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HeartRateAnalytics()),
            ),
          ),
          _VitalsTile(
            label: 'Temperature',
            value: '${v.temperature.toStringAsFixed(1)} °C',
            icon: Icons.thermostat,
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TemperatureAnalytics()),
            ),
          ),
          _VitalsTile(
            label: 'SpO₂',
            value: '${v.spo2} %',
            icon: Icons.bloodtype,
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SpO2Analytics()),
            ),
          ),
          Container(), // empty placeholder
        ],
      ),
    );
  }
}

class _VitalsTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _VitalsTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }
    return card;
  }
}
