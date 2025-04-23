import 'package:hive/hive.dart';
import '../models/vitals_hive.dart';

class LocalCache {
  static Box<VitalsHive> get _box => Hive.box<VitalsHive>('cached_readings');

  /// Cache one reading locally
  static Future<void> cache(VitalsHive v) async {
    await _box.add(v);
  }

  /// Retrieve all cached readings
  static List<VitalsHive> getAll() => _box.values.toList();

  /// Delete a cached entry by key
  static Future<void> deleteKey(int key) async {
    await _box.delete(key);
  }
}
