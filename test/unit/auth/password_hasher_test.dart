import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/services/password_hasher.dart';

void main() {
  group('PasswordHasher', () {
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

    test('verify rejects malformed or legacy plaintext stored values', () {
      expect(PasswordHasher.verify('password123', 'password123'), isFalse);
      expect(PasswordHasher.verify('x', r'pbkdf2$bad'), isFalse);
      expect(PasswordHasher.isHashed('password123'), isFalse);
      expect(PasswordHasher.isHashed(PasswordHasher.hash('x1y2z3')), isTrue);
    });
  });
}
