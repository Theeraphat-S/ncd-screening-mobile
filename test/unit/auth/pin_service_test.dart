import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/services/password_hasher.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';

void main() {
  late InMemorySecureStore store;
  late PinService pins;

  setUp(() {
    store = InMemorySecureStore();
    pins = PinService(store);
  });

  group('PinService', () {
    test('no PIN is set initially', () async {
      expect(await pins.hasPin('vhv-1'), isFalse);
    });

    test('rejects PINs that are not exactly 6 digits', () async {
      for (final bad in ['12345', '1234567', 'abcdef', '12 456', '']) {
        await expectLater(
          pins.setPin('vhv-1', bad),
          throwsA(isA<PinFormatError>()),
          reason: bad,
        );
      }
    });

    test('rejects trivially guessable PINs', () async {
      for (final bad in ['000000', '111111', '123456', '654321']) {
        await expectLater(
          pins.setPin('vhv-1', bad),
          throwsA(isA<PinFormatError>()),
          reason: bad,
        );
      }
    });

    test('stores only a hash, never the PIN itself', () async {
      await pins.setPin('vhv-1', '482913');
      expect(await pins.hasPin('vhv-1'), isTrue);
      expect(store.dump().values.join(), isNot(contains('482913')));
    });

    test('verifies correct PIN and rejects wrong PIN', () async {
      await pins.setPin('vhv-1', '482913');
      expect(await pins.verifyPin('vhv-1', '482913'), PinResult.ok);
      expect(await pins.verifyPin('vhv-1', '482914'), PinResult.wrong);
    });

    test('PINs are per user', () async {
      await pins.setPin('vhv-1', '482913');
      expect(await pins.hasPin('vhv-2'), isFalse);
      expect(await pins.verifyPin('vhv-2', '482913'), PinResult.notSet);
    });

    test('wrong PINs are not counted here (AuthAttemptGuard does that)',
        () async {
      await pins.setPin('vhv-1', '482913');
      for (var i = 0; i < 12; i++) {
        expect(await pins.verifyPin('vhv-1', '000001'), PinResult.wrong);
      }
      expect(await pins.hasPin('vhv-1'), isTrue);
      expect(await pins.verifyPin('vhv-1', '482913'), PinResult.ok);
    });

    test('a PIN hashed with the old iteration count is upgraded on use',
        () async {
      await store.write('pin_hash_vhv-1', PasswordHasher.hash('482913', iterations: 10000));
      expect(await pins.verifyPin('vhv-1', '482913'), PinResult.ok);
      final upgraded = (await store.read('pin_hash_vhv-1'))!;
      expect(PasswordHasher.needsRehash(upgraded), isFalse);
      expect(await pins.verifyPin('vhv-1', '482913'), PinResult.ok);
    });

    test('clearPin removes the PIN', () async {
      await pins.setPin('vhv-1', '482913');
      await pins.clearPin('vhv-1');
      expect(await pins.hasPin('vhv-1'), isFalse);
    });
  });
}
