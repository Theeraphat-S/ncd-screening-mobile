import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/data/services/device_security_services.dart';
import 'package:ncd_screening_mobile/domain/services/auth_attempt_guard.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';
import 'package:ncd_screening_mobile/feature/auth/bloc/auth_bloc.dart';
import 'package:ncd_screening_mobile/locator.dart';
import 'package:ncd_screening_mobile/shared/bloc/app_lock/app_lock_cubit.dart';
import 'package:ncd_screening_mobile/shared/navigation.dart';
import 'package:ncd_screening_mobile/shared/widgets/app_lock_gate.dart';

Future<void> _tapPin(WidgetTester tester, String pin) async {
  for (final d in pin.split('')) {
    await tester.tap(find.byKey(Key('pin_key_$d')));
    await tester.pump();
  }
  // PBKDF2 verification is async; let it settle.
  await tester.pump(const Duration(milliseconds: 50));
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
  await tester.pump();
}

class _CountingWiper implements DeviceWiper {
  int wipes = 0;
  @override
  Future<void> wipe() async => wipes++;
}

void main() {
  late MockNcdRepository repo;
  late AuthBloc auth;
  late AppLockCubit lock;
  late PinService pins;
  late DeviceSessionStore sessions;
  late VHV vhv;

  setUp(() async {
    await locator.reset();
    repo = MockNcdRepository();
    pins = PinService(InMemorySecureStore());
    final store = InMemorySecureStore();
    locator.registerSingleton<NcdRepositoryInterface>(repo);
    locator.registerSingleton<PinService>(pins);
    sessions = DeviceSessionStore(store);
    locator.registerSingleton<DeviceSessionStore>(sessions);
    locator.registerSingleton<BiometricService>(const NoBiometricService());

    vhv = (await repo.getVhvById('VHV001'))!;
    auth = AuthBloc(repo)..add(AuthSessionRestored(role: UserRole.vhv, user: vhv));
    lock = AppLockCubit();
    locator.registerSingleton<AuthBloc>(auth);
    locator.registerSingleton<AppLockCubit>(lock);
  });

  tearDown(() async {
    await lock.close();
    await auth.close();
    await locator.reset();
  });

  // The idle timer must not outlive the test (pending-timer invariant).
  void lockTest(String name, Future<void> Function(WidgetTester) body) {
    testWidgets(name, (tester) async {
      // A failed lifecycle test must not leave the next one in the background.
      addTearDown(() => tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.resumed));
      await body(tester);
      lock.endSession();
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  Future<void> pumpApp(
    WidgetTester tester, {
    AuthAttemptGuard? guard,
    bool hideWhenInactive = true,
  }) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<NcdRepositoryInterface>.value(value: repo),
          RepositoryProvider<PinService>.value(value: pins),
          RepositoryProvider<DeviceSessionStore>.value(value: sessions),
          RepositoryProvider<BiometricService>.value(value: const NoBiometricService()),
          if (guard != null) RepositoryProvider<AuthAttemptGuard>.value(value: guard),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: auth),
            BlocProvider<AppLockCubit>.value(value: lock),
          ],
          child: MaterialApp(
            navigatorKey: appNavigatorKey,
            builder: (context, child) =>
                AppLockGate(hideWhenInactive: hideWhenInactive, child: child!),
            home: const Scaffold(body: Center(child: Text('หน้าหลัก'))),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  lockTest('shows the app while the session is active', (tester) async {
    await pumpApp(tester);
    lock.startSession();
    await tester.pump(const Duration(minutes: 4));
    expect(find.text('หน้าหลัก'), findsOneWidget);
    expect(find.text('หน้าจอถูกล็อก'), findsNothing);
  });

  lockTest('locks after 5 idle minutes and asks for the PIN', (tester) async {
    await pins.setPin(vhv.vhvId, '482913');
    await pumpApp(tester);
    lock.startSession();

    await tester.pump(const Duration(minutes: 5, seconds: 1));
    await tester.pump();
    expect(find.text('หน้าจอถูกล็อก'), findsOneWidget);
    expect(find.byKey(const Key('pin_key_5')), findsOneWidget);
  });

  lockTest('touching the screen keeps the session alive', (tester) async {
    await pins.setPin(vhv.vhvId, '482913');
    await pumpApp(tester);
    lock.startSession();

    await tester.pump(const Duration(minutes: 4));
    await tester.tapAt(const Offset(50, 50));
    await tester.pump(const Duration(minutes: 4));
    expect(find.text('หน้าจอถูกล็อก'), findsNothing);
  });

  lockTest('correct PIN unlocks and brings back the same screen',
      (tester) async {
    await pins.setPin(vhv.vhvId, '482913');
    await pumpApp(tester);
    lock.startSession();
    await tester.pump(const Duration(minutes: 16));
    await tester.pump();

    await _tapPin(tester, '482913');
    expect(find.text('หน้าจอถูกล็อก'), findsNothing);
    expect(find.text('หน้าหลัก'), findsOneWidget);
    expect(lock.state.status, AppLockStatus.unlocked);
  });

  lockTest('wrong PIN stays locked and shows an error', (tester) async {
    await pins.setPin(vhv.vhvId, '482913');
    await pumpApp(tester);
    lock.startSession();
    await tester.pump(const Duration(minutes: 16));
    await tester.pump();

    await _tapPin(tester, '000001');
    expect(find.text('หน้าจอถูกล็อก'), findsOneWidget);
    expect(find.text('PIN ไม่ถูกต้อง'), findsOneWidget);
    expect(lock.state.status, AppLockStatus.locked);
  });

  lockTest('without a PIN the lock screen asks for the password',
      (tester) async {
    await pumpApp(tester);
    lock.startSession();
    await tester.pump(const Duration(minutes: 16));
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'wrong-password');
    await tester.tap(find.text('ปลดล็อก'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('รหัสผ่านไม่ถูกต้อง'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'password123');
    await tester.tap(find.text('ปลดล็อก'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('หน้าจอถูกล็อก'), findsNothing);
    expect(lock.state.status, AppLockStatus.unlocked);
  });

  group('background privacy', () {
    lockTest('hides the app while it is in the background', (tester) async {
      await pumpApp(tester);
      lock.startSession();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      // Frames are switched off while paused; force one to see what the
      // last frame (the one the OS snapshots) contains.
      tester.binding.scheduleForcedFrame();
      await tester.pump();
      expect(find.byKey(const Key('privacy_cover')), findsOneWidget);
      expect(find.text('หน้าหลัก'), findsNothing);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.byKey(const Key('privacy_cover')), findsNothing);
      expect(find.text('หน้าหลัก'), findsOneWidget);
    });

    lockTest('phones also hide in the app switcher (inactive)', (tester) async {
      await pumpApp(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.byKey(const Key('privacy_cover')), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
    });

    lockTest('the Hub stays visible when its window only loses focus',
        (tester) async {
      await pumpApp(tester, hideWhenInactive: false);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.byKey(const Key('privacy_cover')), findsNothing);
      expect(find.text('หน้าหลัก'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
    });
  });

  group('attempt limit', () {
    late DateTime now;
    late _CountingWiper wiper;

    AuthAttemptGuard makeGuard(DeviceRole role) => AuthAttemptGuard(
          store: InMemorySecureStore(),
          role: role,
          wiper: wiper,
          now: () => now,
        );

    setUp(() {
      now = DateTime(2026, 11, 26, 9);
      wiper = _CountingWiper();
    });

    Future<void> lockNow(WidgetTester tester) async {
      lock.startSession();
      await tester.pump(const Duration(minutes: 6));
      await tester.pump();
    }

    lockTest('the 5th wrong PIN starts a wait', (tester) async {
      final guard = makeGuard(DeviceRole.spoke);
      await pins.setPin(vhv.vhvId, '482913');
      await pumpApp(tester, guard: guard);
      await lockNow(tester);

      for (var i = 0; i < 5; i++) {
        await _tapPin(tester, '000001');
      }
      expect(find.textContaining('กรุณารอ 30 วินาที'), findsOneWidget);

      // The right PIN is refused until the wait is over.
      await _tapPin(tester, '482913');
      expect(lock.state.status, AppLockStatus.locked);

      now = now.add(const Duration(seconds: 31));
      await _tapPin(tester, '482913');
      expect(lock.state.status, AppLockStatus.unlocked);
    });

    lockTest('wrong lock-screen passwords count too', (tester) async {
      final guard = makeGuard(DeviceRole.spoke);
      await pumpApp(tester, guard: guard);
      await lockNow(tester);

      await tester.enterText(find.byType(TextField), 'wrong-password');
      await tester.tap(find.text('ปลดล็อก'));
      await tester.pump(const Duration(seconds: 1));
      expect((await tester.runAsync(guard.status))!.failures, 1);
    });

    lockTest('ten wrong PINs on a Spoke wipe it and end the session',
        (tester) async {
      final guard = makeGuard(DeviceRole.spoke);
      await pins.setPin(vhv.vhvId, '482913');
      await pumpApp(tester, guard: guard);
      await lockNow(tester);

      for (var i = 0; i < 10; i++) {
        await _tapPin(tester, '000001');
        now = now.add(const Duration(hours: 1));
      }
      await tester.pump();

      expect(wiper.wipes, 1);
      expect(find.textContaining('ข้อมูลในเครื่องนี้ถูกลบแล้ว'), findsOneWidget);
      expect(find.text('หน้าหลัก'), findsNothing);
      expect(lock.state.status, AppLockStatus.signedOut);
    });

    lockTest('a Hub locked out before a restart opens on the locked screen',
        (tester) async {
      final guard = makeGuard(DeviceRole.hub);
      for (var i = 0; i < 10; i++) {
        await guard.attempt(() async => false);
        now = now.add(const Duration(hours: 1));
      }
      await pumpApp(tester, guard: guard);
      await tester.pump();

      expect(wiper.wipes, 0);
      expect(find.textContaining('เครื่องนี้ถูกล็อก'), findsOneWidget);
      expect(find.text('หน้าหลัก'), findsNothing);
    });
  });
}
