import 'dart:async';
import 'dart:math';

// Import your Vitals model
import '../pages/home_page.dart';

/// A helper class that fakes a stream of [Vitals] readings every second.
///
/// It emits values mostly within normal neonatal ranges, with rare anomalies
/// to simulate out‑of‑range events.
class VitalsGenerator {
  // Random number generator
  static final Random _rng = Random();

  // ---- Normal bounds for a premature baby ----
  static const int _hrMin = 120;    // beats per minute
  static const int _hrMax = 160;
  static const double _tempMin = 36.5; // °C
  static const double _tempMax = 37.5;
  static const int _spo2Min = 95;   // percent
  static const int _spo2Max = 100;

  // ---- Anomaly probabilities ----
  // Adjust these to make out‑of‑range readings more or less frequent
  static const double _hrAnomalyProb = 0.05;    // 5% chance
  static const double _tempAnomalyProb = 0.02;  // 2% chance
  static const double _spo2AnomalyProb = 0.03;  // 3% chance

  /// Generates one [Vitals] reading, occasionally injecting anomalies.
  static Vitals _generateReading() {
    // HEART RATE
    final bool hrAnomaly = _rng.nextDouble() < _hrAnomalyProb;
    final int heartRate = hrAnomaly
        // 50/50 high vs low anomaly
        ? (_rng.nextBool()
            ? _hrMax + 10 + _rng.nextInt(11)   // 10–20 bpm above max
            : _hrMin - 10 - _rng.nextInt(11))  // 10–20 bpm below min
        // Normal random within range
        : _hrMin + _rng.nextInt(_hrMax - _hrMin + 1);

    // TEMPERATURE
    final bool tempAnomaly = _rng.nextDouble() < _tempAnomalyProb;
    final double temperature = tempAnomaly
        ? (_rng.nextBool()
            // Slight fever
            ? _tempMax + 1 + _rng.nextDouble() * 0.5
            // Slight hypothermia
            : _tempMin - 1 - _rng.nextDouble() * 0.5)
        : _tempMin + _rng.nextDouble() * (_tempMax - _tempMin);

    // SPO₂
    final bool spo2Anomaly = _rng.nextDouble() < _spo2AnomalyProb;
    final int spo2 = spo2Anomaly
        // Drop below normal by 1–5%
        ? _spo2Min - 1 - _rng.nextInt(5)
        : _spo2Min + _rng.nextInt(_spo2Max - _spo2Min + 1);

    return Vitals(
      heartRate: heartRate,
      temperature: double.parse(temperature.toStringAsFixed(1)),
      spo2: spo2,
      timestamp: DateTime.now(),
    );
  }

  /// A broadcast [Stream] of [Vitals] that emits one reading per second.
  static Stream<Vitals> get stream => Stream<Vitals>.periodic(
        const Duration(seconds: 1),
        (_) => _generateReading(),
      ).asBroadcastStream();
}
