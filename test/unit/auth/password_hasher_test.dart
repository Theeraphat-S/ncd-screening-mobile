import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/services/password_hasher.dart';
import 'package:ncd_screening_mobile/domain/services/pbkdf2_sha256.dart';

String _hex(List<int> b) => b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

/// Straightforward PBKDF2 (one generic HMAC per iteration), as PasswordHasher
/// computed it before M1. Hashes stored then must keep verifying.
List<int> _genericPbkdf2(List<int> password, List<int> salt, int iterations, int length) {
  final hmac = Hmac(sha256, password);
  final out = <int>[];
  for (var block = 1; out.length < length; block++) {
    var u = hmac.convert([...salt, 0, 0, 0, block]).bytes;
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

void main() {
  group('pbkdf2HmacSha256', () {
    final p = utf8.encode('password');
    final s = utf8.encode('salt');

    test('matches the RFC 7914 PBKDF2-HMAC-SHA256 test vectors', () {
      expect(_hex(pbkdf2HmacSha256(p, s, 1, 32)),
          '120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b');
      expect(_hex(pbkdf2HmacSha256(p, s, 2, 32)),
          'ae4d0c95af6b46d32d0adff928f06dd02a303f8ef3c251dfd6e2d85a95474c43');
      expect(_hex(pbkdf2HmacSha256(p, s, 4096, 32)),
          'c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134a');
      expect(
        _hex(pbkdf2HmacSha256(utf8.encode('passwd'), s, 1, 64)),
        '55ac046e56e3089fec1691c22544b605f94185216dde0465e68b9d57c20dacbc'
        '49ca9cccf179b645991664b39d77ef317c71b845b1e30bd509112041d3a19783',
      );
    });

    test('equals the generic construction, including keys over 64 bytes', () {
      final long = utf8.encode('รหัสผ่านยาวมาก' * 8);
      for (final pw in [p, utf8.encode('482913'), long]) {
        expect(pbkdf2HmacSha256(pw, s, 777, 32), _genericPbkdf2(pw, s, 777, 32));
      }
    });
  });

  group('PasswordHasher', () {
    test('new hashes use at least 100k iterations (ADR 0011)', () {
      expect(PasswordHasher.defaultIterations, greaterThanOrEqualTo(100000));
      final parts = PasswordHasher.hash('password123').split(r'$');
      expect(int.parse(parts[1]), PasswordHasher.defaultIterations);
    });

    test('hashes stored before M1 (10k iterations) still verify', () {
      final salt = List<int>.generate(16, (i) => i);
      final key = _genericPbkdf2(utf8.encode('password123'), salt, 10000, 32);
      final old = 'pbkdf2\$10000\$${base64.encode(salt)}\$${base64.encode(key)}';
      expect(PasswordHasher.verify('password123', old), isTrue);
      expect(PasswordHasher.verify('password124', old), isFalse);
    });

    test('needsRehash flags plaintext and low iteration counts', () {
      expect(PasswordHasher.needsRehash('plain'), isTrue);
      expect(PasswordHasher.needsRehash(PasswordHasher.hash('x', iterations: 10000)), isTrue);
      expect(PasswordHasher.needsRehash(PasswordHasher.hash('x')), isFalse);
    });

    test('hash never contains the plaintext and uses a versioned format', () {
      final hash = PasswordHasher.hash('password123');
      expect(hash, isNot(contains('password123')));
      expect(hash, startsWith(r'pbkdf2$'));
    });

    test('same password hashes differently each time (random salt)', () {
      expect(
        PasswordHasher.hash('abc12345'),
        isNot(equals(PasswordHasher.hash('abc12345'))),
      );
    });

    test('verify accepts the right password and rejects a wrong one', () {
      final hash = PasswordHasher.hash('correct-horse');
      expect(PasswordHasher.verify('correct-horse', hash), isTrue);
      expect(PasswordHasher.verify('wrong-horse', hash), isFalse);
      expect(PasswordHasher.verify('', hash), isFalse);
    });

    test('async variants produce interoperable hashes on a worker isolate',
        () async {
      PasswordHasher.runInIsolate = true;
      addTearDown(() => PasswordHasher.runInIsolate = false);

      final hash = await PasswordHasher.hashAsync('correct-horse');
      expect(hash, startsWith(r'pbkdf2$'));
      expect(await PasswordHasher.verifyAsync('correct-horse', hash), isTrue);
      expect(await PasswordHasher.verifyAsync('wrong-horse', hash), isFalse);
      expect(PasswordHasher.verify('correct-horse', hash), isTrue);
    });

    test('verify rejects malformed or legacy plaintext stored values', () {
      expect(PasswordHasher.verify('password123', 'password123'), isFalse);
      expect(PasswordHasher.verify('x', r'pbkdf2$bad'), isFalse);
      expect(PasswordHasher.isHashed('password123'), isFalse);
      expect(PasswordHasher.isHashed(PasswordHasher.hash('x1y2z3')), isTrue);
    });
  });
}
