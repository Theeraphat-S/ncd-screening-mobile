import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/data/services/device_security_services.dart';

void main() {
  test('Windows (the Hub) uses Windows Hello without biometricOnly', () {
    final service = LocalAuthBiometricService(platform: TargetPlatform.windows);
    expect(service.options.biometricOnly, isFalse);
  });

  test('phones accept biometrics only', () {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      final service = LocalAuthBiometricService(platform: platform);
      expect(service.options.biometricOnly, isTrue, reason: '$platform');
      expect(service.options.stickyAuth, isTrue);
    }
  });
}
