import 'package:ncd_screening_mobile/domain/services/password_hasher.dart';

/// Minimal key/value contract for secrets (Keychain / Keystore in production).
abstract class SecureStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);

  /// Removes every secret this app stored (used by the device wipe).
  Future<void> deleteAll();
}

/// Test / fallback implementation that keeps everything in memory.
class InMemorySecureStore implements SecureStore {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async => _data[key] = value;

  @override
  Future<void> delete(String key) async => _data.remove(key);

  @override
  Future<void> deleteAll() async => _data.clear();

  Map<String, String> dump() => Map.unmodifiable(_data);
}

class PinFormatError implements Exception {
  final String message;
  const PinFormatError(this.message);
  @override
  String toString() => message;
}

enum PinResult { ok, wrong, notSet }

/// Quick-unlock PIN for staff (VHV / nurse). Only a salted hash is stored.
///
/// Wrong PINs are counted by `AuthAttemptGuard`, together with wrong
/// passwords, not here.
class PinService {
  static const pinLength = 6;

  final SecureStore _store;

  PinService(this._store);

  String _pinKey(String userId) => 'pin_hash_$userId';
  // Per-user counter from before AuthAttemptGuard; only ever deleted now.
  String _legacyAttemptsKey(String userId) => 'pin_attempts_$userId';

  Future<bool> hasPin(String userId) async =>
      (await _store.read(_pinKey(userId))) != null;

  Future<void> setPin(String userId, String pin) async {
    _validate(pin);
    await _store.write(_pinKey(userId), await PasswordHasher.hashAsync(pin));
    await _store.delete(_legacyAttemptsKey(userId));
  }

  Future<PinResult> verifyPin(String userId, String pin) async {
    final stored = await _store.read(_pinKey(userId));
    if (stored == null) return PinResult.notSet;
    if (!await PasswordHasher.verifyAsync(pin, stored)) return PinResult.wrong;
    // PINs set before the iteration count was raised are upgraded now.
    if (PasswordHasher.needsRehash(stored)) {
      await _store.write(_pinKey(userId), await PasswordHasher.hashAsync(pin));
    }
    return PinResult.ok;
  }

  Future<void> clearPin(String userId) async {
    await _store.delete(_pinKey(userId));
    await _store.delete(_legacyAttemptsKey(userId));
  }

  static void _validate(String pin) {
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      throw const PinFormatError('PIN ต้องเป็นตัวเลข 6 หลัก');
    }
    if (RegExp(r'^(\d)\1{5}$').hasMatch(pin) ||
        '0123456789'.contains(pin) ||
        '9876543210'.contains(pin)) {
      throw const PinFormatError('PIN เดาง่ายเกินไป กรุณาเลือกเลขอื่น');
    }
  }
}
