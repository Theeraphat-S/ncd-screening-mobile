import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Salted PBKDF2-HMAC-SHA256 password hashing.
///
/// Stored format: `pbkdf2$<iterations>$<saltBase64>$<hashBase64>`.
/// Anything that does not match this format (e.g. legacy plaintext) is
/// never accepted by [verify]; callers decide how to migrate such values.
class PasswordHasher {
  PasswordHasher._();

  static const _prefix = 'pbkdf2';
  static const _defaultIterations = 10000;
  static const _saltLength = 16;
  static const _keyLength = 32;

  static final _random = Random.secure();

  static bool isHashed(String stored) => stored.startsWith('$_prefix\$');

  static String hash(String password, {int iterations = _defaultIterations}) {
    final salt = Uint8List.fromList(
      List<int>.generate(_saltLength, (_) => _random.nextInt(256)),
    );
    final key = _pbkdf2(utf8.encode(password), salt, iterations, _keyLength);
    return '$_prefix\$$iterations\$${base64.encode(salt)}\$${base64.encode(key)}';
  }

  static bool verify(String password, String stored) {
    final parts = stored.split(r'$');
    if (parts.length != 4 || parts[0] != _prefix) return false;
    final iterations = int.tryParse(parts[1]);
    if (iterations == null || iterations <= 0) return false;
    final List<int> salt;
    final List<int> expected;
    try {
      salt = base64.decode(parts[2]);
      expected = base64.decode(parts[3]);
    } on FormatException {
      return false;
    }
    final actual = _pbkdf2(utf8.encode(password), salt, iterations, expected.length);
    return _constantTimeEquals(actual, expected);
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  static List<int> _pbkdf2(
    List<int> password,
    List<int> salt,
    int iterations,
    int length,
  ) {
    final hmac = Hmac(sha256, password);
    final blocks = (length / 32).ceil();
    final out = <int>[];
    for (var block = 1; block <= blocks; block++) {
      var u = hmac.convert([
        ...salt,
        (block >> 24) & 0xff,
        (block >> 16) & 0xff,
        (block >> 8) & 0xff,
        block & 0xff,
      ]).bytes;
      final t = List<int>.from(u);
      for (var i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (var j = 0; j < t.length; j++) {
          t[j] ^= u[j];
        }
      }
      out.addAll(t);
    }
    return out.sublist(0, length);
  }
}
