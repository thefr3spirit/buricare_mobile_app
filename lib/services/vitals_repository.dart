import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/home_page.dart'; // Vitals model

/// Handles all Firestore writes for a single user.
class VitalsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid;

  VitalsRepository(this.uid);

  Future<void> writeRaw(Vitals v) {
    return _db
      .collection('users')
      .doc(uid)
      .collection('rawReadings')
      .add({
        'heartRate': v.heartRate,
        'temperature': v.temperature,
        'spo2': v.spo2,
        'timestamp': v.timestamp.toIso8601String(),
      });
  }

  Future<void> writeMinuteAverage(DateTime stamp, Vitals avg) {
    final id = stamp.toIso8601String().substring(0, 16); 
    return _db
      .collection('users')
      .doc(uid)
      .collection('minuteAverages')
      .doc(id)
      .set({
        'heartRate': avg.heartRate,
        'temperature': avg.temperature,
        'spo2': avg.spo2,
        'timestamp': stamp.toIso8601String(),
      });
  }

  Future<void> writeHourlyAverage(DateTime stamp, Vitals avg) {
    final id = stamp.toIso8601String().substring(0, 13);
    return _db
      .collection('users')
      .doc(uid)
      .collection('hourlyAverages')
      .doc(id)
      .set({
        'heartRate': avg.heartRate,
        'temperature': avg.temperature,
        'spo2': avg.spo2,
        'timestamp': stamp.toIso8601String(),
      });
  }
}
