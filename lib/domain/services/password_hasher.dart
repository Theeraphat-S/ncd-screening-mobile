import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// Hashes and verifies staff passwords with PBKDF2-HMAC-SHA256.
///
/// Stored format: `pbkdf2_sha256$<iterations>$<base64 salt>$<base64 key>`.
/// Plaintext passwords must never be persisted or returned from the data layer.
class PasswordHasher {
  static const String _scheme = 'pbkdf2_sha256';
  static const int defaultIterations = 210000;
  static const int _saltLength = 16;
  static const int _keyLength = 32;

  final int iterations;

  const PasswordHasher({this.iterations = defaultIterations});

  Future<String> hash(String password) async {
    final salt = _randomBytes(_saltLength);
    final key = await _derive(password, salt, iterations);
    return '$_scheme\$$iterations\$${base64Encode(salt)}\$${base64Encode(key)}';
  }

  /// Returns false for malformed or empty stored values instead of throwing.
  Future<bool> verify(String password, String stored) async {
    final parts = stored.split(r'$');
    if (parts.length != 4 || parts[0] != _scheme) return false;

    final iter = int.tryParse(parts[1]);
    if (iter == null || iter <= 0) return false;

    final List<int> salt;
    final List<int> expected;
    try {
      salt = base64Decode(parts[2]);
      expected = base64Decode(parts[3]);
    } on FormatException {
      return false;
    }

    final actual = await _derive(password, salt, iter);
    return _constantTimeEquals(actual, expected);
  }

  Future<List<int>> _derive(String password, List<int> salt, int iter) async {
    final algorithm = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iter,
      bits: _keyLength * 8,
    );
    final key = await algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
    return key.extractBytes();
  }

  static List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
