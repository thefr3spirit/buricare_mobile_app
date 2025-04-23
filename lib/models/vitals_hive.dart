import 'package:hive/hive.dart';
import '../pages/home_page.dart'; // for Vitals

part 'vitals_hive.g.dart';

@HiveType(typeId: 0)
class VitalsHive extends HiveObject {
  @HiveField(0)
  int heartRate;

  @HiveField(1)
  double temperature;

  @HiveField(2)
  int spo2;

  @HiveField(3)
  DateTime timestamp;

  VitalsHive({
    required this.heartRate,
    required this.temperature,
    required this.spo2,
    required this.timestamp,
  });

  factory VitalsHive.fromVitals(Vitals v) => VitalsHive(
        heartRate: v.heartRate,
        temperature: v.temperature,
        spo2: v.spo2,
        timestamp: v.timestamp,
      );

  Vitals toVitals() => Vitals(
        heartRate: heartRate,
        temperature: temperature,
        spo2: spo2,
        timestamp: timestamp,
      );
}
