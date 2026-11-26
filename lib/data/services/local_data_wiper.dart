import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:ncd_screening_mobile/domain/services/auth_attempt_guard.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';

/// Erases this app's data on a Spoke after too many wrong PINs / passwords:
/// every secret in secure storage (the database key, PIN hashes, the
/// remembered user) and the database file, which also holds the screening
/// drafts.
///
/// Secrets go first. Without its key the encrypted database is unreadable,
/// so even if deleting the file fails the data is gone.
class LocalDataWiper implements DeviceWiper {
  final SecureStore store;
  final Future<void> Function() closeDatabase;
  final Future<File> Function() databaseFile;

  LocalDataWiper({
    required this.store,
    required this.closeDatabase,
    required this.databaseFile,
  });

  static const _sidecars = ['', '-wal', '-shm', '-journal'];

  @override
  Future<void> wipe() async {
    await _try('secure storage', store.deleteAll);
    await _try('close database', closeDatabase);
    await _try('database files', () async {
      final db = await databaseFile();
      for (final suffix in _sidecars) {
        final f = File('${db.path}$suffix');
        if (await f.exists()) await f.delete();
      }
    });
  }

  Future<void> _try(String step, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      debugPrint('Wipe step "$step" failed: $e');
    }
  }
}
