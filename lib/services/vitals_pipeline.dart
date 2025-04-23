import 'dart:async';

import '../utils/vitals_generator.dart';
import '../pages/home_page.dart';
import 'vitals_repository.dart';

// Offline cache & sync
import 'local_cache.dart';
import 'sync_service.dart';
import '../models/vitals_hive.dart';

/// Buffers readings, computes averages, and writes to Firestore,
/// with Hive‑backed offline caching and automatic sync on connectivity.
class VitalsPipeline {
  final VitalsRepository _repo;
  final SyncService _syncService = SyncService();
  late final StreamSubscription<Vitals> _sub;

  final List<Vitals> _secondBuffer = [];
  final List<Vitals> _minuteBuffer = [];

  VitalsPipeline(String uid)
      : _repo = VitalsRepository(uid) {
    // Start listening for connectivity changes
    _syncService.start();
    // Subscribe to live stream
    _sub = VitalsGenerator.stream.listen(_onReading);
  }

  void _onReading(Vitals v) {
    // 0) Cache locally in Hive
    final hiveObj = VitalsHive.fromVitals(v);
    LocalCache.cache(hiveObj);

    // 1) Attempt to write raw immediately (will also trigger sync of any cached items)
    _repo.writeRaw(v);

    // 2) Buffer for minute averaging
    _secondBuffer.add(v);
    if (_secondBuffer.length >= 60) {
      final avg = _average(_secondBuffer);
      final minuteStamp = DateTime.now();
      _repo.writeMinuteAverage(minuteStamp, avg);
      _secondBuffer.clear();

      // Also buffer into hourly
      _minuteBuffer.add(avg);
      if (_minuteBuffer.length >= 60) {
        final hrAvg = _average(_minuteBuffer);
        final hourStamp = DateTime.now();
        _repo.writeHourlyAverage(hourStamp, hrAvg);
        _minuteBuffer.clear();
      }
    }
  }

  /// Compute simple averages over a list of Vitals.
  Vitals _average(List<Vitals> list) {
    final count = list.length;
    final hr = (list.map((v) => v.heartRate).reduce((a, b) => a + b) / count).round();
    final temp = double.parse(
        (list.map((v) => v.temperature).reduce((a, b) => a + b) / count)
            .toStringAsFixed(1));
    final sp = (list.map((v) => v.spo2).reduce((a, b) => a + b) / count).round();
    return Vitals(
      heartRate: hr,
      temperature: temp,
      spo2: sp,
      timestamp: DateTime.now(),
    );
  }

  /// Cancel both the stream subscription and the sync listener.
  Future<void> dispose() async {
    await _sub.cancel();
    _syncService.dispose();
  }
}
