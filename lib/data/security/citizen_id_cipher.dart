import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage for the two 256-bit keys that protect citizen IDs on this device.
abstract class SecretKeyStore {
  Future<String?> read(String name);
  Future<void> write(String name, String value);
}

/// Keys live in the platform keystore/keychain, never in the database.
class SecureKeyStore implements SecretKeyStore {
  final FlutterSecureStorage _storage;

  const SecureKeyStore([this._storage = const FlutterSecureStorage()]);

  @override
  Future<String?> read(String name) => _storage.read(key: name);

  @override
  Future<void> write(String name, String value) =>
      _storage.write(key: name, value: value);
}

/// Protects national ID numbers at rest.
///
/// * [encrypt]/[decrypt]: AES-256-GCM with a random nonce per value.
/// * [indexOf]: HMAC-SHA256 under a separate key, so equal IDs map to equal
///   index values for exact lookups without storing the ID in clear.
///
/// Losing the keys makes stored IDs unrecoverable. Do not enable backups of
/// the app data (see AndroidManifest `allowBackup="false"`).
class CitizenIdCipher {
  static const String _encKeyName = 'citizen_id.enc_key.v1';
  static const String _indexKeyName = 'citizen_id.index_key.v1';
  static const int _keyBytes = 32;
  static const int _nonceBytes = 12;

  static final AesGcm _aes = AesGcm.with256bits(nonceLength: _nonceBytes);
  static final Hmac _hmac = Hmac.sha256();

  final SecretKey _encKey;
  final SecretKey _indexKey;

  CitizenIdCipher._(this._encKey, this._indexKey);

  /// Fixed keys for tests. Never use with real patient data.
  factory CitizenIdCipher.withKeys({
    required List<int> encKey,
    required List<int> indexKey,
  }) {
    assert(encKey.length == _keyBytes && indexKey.length == _keyBytes);
    return CitizenIdCipher._(SecretKey(encKey), SecretKey(indexKey));
  }

  /// Loads the keys from [store], creating them on first use.
  static Future<CitizenIdCipher> loadOrCreate(SecretKeyStore store) async {
    final enc = await _loadOrCreateKey(store, _encKeyName);
    final index = await _loadOrCreateKey(store, _indexKeyName);
    return CitizenIdCipher._(SecretKey(enc), SecretKey(index));
  }

  /// Random in-memory keys. Intended for tests only: data written with these
  /// keys cannot be read after the process exits.
  static Future<CitizenIdCipher> ephemeral() async {
    final random = Random.secure();
    List<int> bytes() =>
        List<int>.generate(_keyBytes, (_) => random.nextInt(256));
    return CitizenIdCipher._(SecretKey(bytes()), SecretKey(bytes()));
  }

  Future<String> encrypt(String plain) async {
    final box = await _aes.encrypt(
      utf8.encode(_normalize(plain)),
      secretKey: _encKey,
    );
    return base64Encode(box.concatenation());
  }

  Future<String> decrypt(String stored) async {
    final box = SecretBox.fromConcatenation(
      base64Decode(stored),
      nonceLength: _nonceBytes,
      macLength: 16,
    );
    final clear = await _aes.decrypt(box, secretKey: _encKey);
    return utf8.decode(clear);
  }

  Future<String> indexOf(String plain) async {
    final mac = await _hmac.calculateMac(
      utf8.encode(_normalize(plain)),
      secretKey: _indexKey,
    );
    return base64Encode(mac.bytes);
  }

  static String _normalize(String value) => value.trim();

  static Future<List<int>> _loadOrCreateKey(
    SecretKeyStore store,
    String name,
  ) async {
    final existing = await store.read(name);
    if (existing != null) {
      final bytes = base64Decode(existing);
      if (bytes.length != _keyBytes) {
        throw StateError('Stored key $name has an invalid length');
      }
      return bytes;
    }
    final random = Random.secure();
    final bytes = List<int>.generate(_keyBytes, (_) => random.nextInt(256));
    await store.write(name, base64Encode(bytes));
    return bytes;
  }
}
