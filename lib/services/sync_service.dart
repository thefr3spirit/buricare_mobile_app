import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

import 'vitals_repository.dart';
import '../models/vitals_hive.dart';

class SyncService {
  final _connectivity = Connectivity();
  StreamSubscription<dynamic>? _sub; // listen to whatever the plugin emits

  /// Start listening for connectivity changes and flush cache when online.
  void start() {
    _sub = _connectivity.onConnectivityChanged.listen((_) async {
      // On any change, re-check actual status
      final status = await _connectivity.checkConnectivity();
      if (status != ConnectivityResult.none) {
        await _flushCache();
      }
    });
  }

  Future<void> _flushCache() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    // NOTE: VitalsRepository takes a positional uid argument
    final repo = VitalsRepository(uid);

    // Open the same Hive box that LocalCache uses
    final box = Hive.box<VitalsHive>('cached_readings');
    final entries = box.toMap(); // Map<int, VitalsHive>

    for (final key in entries.keys) {
      final vHive = entries[key]!;
      final v = vHive.toVitals();
      try {
        await repo.writeRaw(v);
        // On success, delete from cache
        await box.delete(key);
      } catch (e) {
        // Stop if any write fails; will retry later
        break;
      }
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
