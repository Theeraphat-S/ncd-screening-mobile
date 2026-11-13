import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/services/citizen_id.dart';

void main() {
  group('CitizenId.isValid', () {
    test('accepts numbers with a correct check digit', () {
      expect(CitizenId.isValid('1100223344556'), isTrue);
      expect(CitizenId.isValid('1111111111119'), isTrue);
      expect(CitizenId.isValid('1999999999999'), isTrue);
    });

    test('rejects a wrong check digit (single typo)', () {
      expect(CitizenId.isValid('1100223344557'), isFalse);
      expect(CitizenId.isValid('1234567890123'), isFalse);
    });

    test('rejects wrong length and non-digits', () {
      expect(CitizenId.isValid(''), isFalse);
      expect(CitizenId.isValid('110022334455'), isFalse);
      expect(CitizenId.isValid('11002233445566'), isFalse);
      expect(CitizenId.isValid('11002233445a6'), isFalse);
      expect(CitizenId.isValid(' 1100223344556'), isFalse);
    });
  });
}
