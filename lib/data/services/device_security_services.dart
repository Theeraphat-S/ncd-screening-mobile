import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';

/// Keychain (iOS/macOS) / Keystore (Android) backed [SecureStore].
class PlatformSecureStore implements SecureStore {
  final FlutterSecureStorage _storage;

  const PlatformSecureStore([
    this._storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  ]);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

abstract class BiometricService {
  Future<bool> isAvailable();
  Future<bool> authenticate(String reason);
}

class LocalAuthBiometricService implements BiometricService {
  final LocalAuthentication _auth;

  LocalAuthBiometricService([LocalAuthentication? auth])
      : _auth = auth ?? LocalAuthentication();

  @override
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported() &&
          (await _auth.getAvailableBiometrics()).isNotEmpty;
    } catch (e) {
      debugPrint('Biometric availability check failed: $e');
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      debugPrint('Biometric authentication failed: $e');
      return false;
    }
  }
}

/// Fake used by tests and on platforms without biometrics.
class NoBiometricService implements BiometricService {
  const NoBiometricService();
  @override
  Future<bool> isAvailable() async => false;
  @override
  Future<bool> authenticate(String reason) async => false;
}

/// Remembers which staff member last signed in on this device, and whether
/// they turned on biometric unlock, so the next launch can offer PIN login.
class DeviceSessionStore {
  static const _lastUserKey = 'last_staff_user';
  final SecureStore _store;

  DeviceSessionStore(this._store);

  Future<void> rememberUser(UserRole role, String userId) =>
      _store.write(_lastUserKey, '${role.name}:$userId');

  Future<({UserRole role, String userId})?> lastUser() async {
    final raw = await _store.read(_lastUserKey);
    if (raw == null) return null;
    final idx = raw.indexOf(':');
    if (idx <= 0) return null;
    final role = UserRole.values.where((r) => r.name == raw.substring(0, idx));
    if (role.isEmpty || role.first == UserRole.patient) return null;
    return (role: role.first, userId: raw.substring(idx + 1));
  }

  Future<void> forgetUser() => _store.delete(_lastUserKey);

  String _bioKey(String userId) => 'biometric_enabled_$userId';

  Future<bool> isBiometricEnabled(String userId) async =>
      (await _store.read(_bioKey(userId))) == '1';

  Future<void> setBiometricEnabled(String userId, bool enabled) => enabled
      ? _store.write(_bioKey(userId), '1')
      : _store.delete(_bioKey(userId));
}
