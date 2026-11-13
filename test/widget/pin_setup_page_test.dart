import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/data/services/device_security_services.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';
import 'package:ncd_screening_mobile/feature/auth/pages/pin_setup_page.dart';
import 'package:ncd_screening_mobile/locator.dart';

Future<void> _tapPin(WidgetTester tester, String pin) async {
  for (final d in pin.split('')) {
    await tester.tap(find.byKey(Key('pin_key_$d')));
    await tester.pump();
  }
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
  await tester.pump();
}

void main() {
  late PinService pins;
  late DeviceSessionStore sessions;
  late int finished;

  setUp(() async {
    await locator.reset();
    final store = InMemorySecureStore();
    pins = PinService(store);
    locator.registerSingleton<PinService>(pins);
    sessions = DeviceSessionStore(store);
    locator.registerSingleton<DeviceSessionStore>(sessions);
    locator.registerSingleton<BiometricService>(const NoBiometricService());
    finished = 0;
  });

  tearDown(locator.reset);

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<PinService>.value(value: pins),
          RepositoryProvider<DeviceSessionStore>.value(value: sessions),
          RepositoryProvider<BiometricService>.value(value: const NoBiometricService()),
        ],
        child: MaterialApp(
          home: PinSetupPage(userId: 'VHV001', onFinished: (_) => finished++),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('asks to enter then confirm, then saves the PIN', (tester) async {
    await pumpPage(tester);
    expect(find.text('ตั้ง PIN 6 หลัก'), findsOneWidget);

    await _tapPin(tester, '482913');
    expect(find.text('ยืนยัน PIN อีกครั้ง'), findsOneWidget);

    await _tapPin(tester, '482913');
    expect(finished, 1);
    expect(await tester.runAsync(() => pins.hasPin('VHV001')), isTrue);
  });

  testWidgets('mismatching confirmation restarts with an error', (tester) async {
    await pumpPage(tester);
    await _tapPin(tester, '482913');
    await _tapPin(tester, '482914');

    expect(find.text('PIN ไม่ตรงกัน กรุณาตั้งใหม่'), findsOneWidget);
    expect(find.text('ตั้ง PIN 6 หลัก'), findsOneWidget);
    expect(finished, 0);
    expect(await tester.runAsync(() => pins.hasPin('VHV001')), isFalse);
  });

  testWidgets('an easily guessed PIN is rejected', (tester) async {
    await pumpPage(tester);
    await _tapPin(tester, '123456');
    await _tapPin(tester, '123456');

    expect(find.text('PIN เดาง่ายเกินไป กรุณาเลือกเลขอื่น'), findsOneWidget);
    expect(finished, 0);
  });

  testWidgets('can be skipped without saving a PIN', (tester) async {
    await pumpPage(tester);
    final skip = find.text('ข้ามไปก่อน (ใช้รหัสผ่านครั้งหน้า)');
    await tester.ensureVisible(skip);
    await tester.pump();
    await tester.tap(skip);
    await tester.pump();

    expect(finished, 1);
    expect(await tester.runAsync(() => pins.hasPin('VHV001')), isFalse);
  });

  testWidgets('biometric switch is hidden when the device has none',
      (tester) async {
    await pumpPage(tester);
    expect(find.byType(SwitchListTile), findsNothing);
  });
}
