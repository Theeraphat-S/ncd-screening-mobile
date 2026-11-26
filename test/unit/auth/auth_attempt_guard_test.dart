import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/services/auth_attempt_guard.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';
import 'package:ncd_screening_mobile/shared/config/app_config.dart';

class _RecordingWiper implements DeviceWiper {
  int wipes = 0;
  final InMemorySecureStore? store;
  _RecordingWiper([this.store]);

  @override
  Future<void> wipe() async {
    wipes++;
    await store?.deleteAll();
  }
}

void main() {
  late InMemorySecureStore store;
  late _RecordingWiper wiper;
  late DateTime now;

  AuthAttemptGuard guard(DeviceRole role) => AuthAttemptGuard(
        store: store,
        role: role,
        wiper: wiper,
        now: () => now,
      );

  Future<AttemptStatus> fail(AuthAttemptGuard g) => g.attempt(() async => false);

  setUp(() {
    store = InMemorySecureStore();
    wiper = _RecordingWiper(store);
    now = DateTime(2026, 11, 26, 9);
  });

  group('AuthAttemptGuard', () {
    test('the first 4 failures can be retried at once', () async {
      final g = guard(DeviceRole.spoke);
      for (var i = 1; i <= 4; i++) {
        final r = await fail(g);
        expect(r.kind, AttemptKind.rejected);
        expect(r.failures, i);
      }
      expect((await g.status()).allowsAttempt, isTrue);
    });

    test('from the 5th failure every retry waits longer', () async {
      final g = guard(DeviceRole.spoke);
      for (var i = 0; i < 4; i++) {
        await fail(g);
      }
      final waits = <Duration>[];
      for (var i = 5; i <= 9; i++) {
        final r = await fail(g);
        expect(r.kind, AttemptKind.delayed, reason: 'failure $i');
        waits.add(r.wait);
        now = now.add(r.wait);
      }
      expect(waits, AuthAttemptGuard.delays);
      for (var i = 1; i < waits.length; i++) {
        expect(waits[i], greaterThan(waits[i - 1]));
      }
    });

    test('nothing is checked while the wait runs', () async {
      final g = guard(DeviceRole.spoke);
      for (var i = 0; i < 5; i++) {
        await fail(g);
      }
      var checked = false;
      final r = await g.attempt(() async {
        checked = true;
        return true;
      });
      expect(checked, isFalse, reason: 'even a correct PIN must wait');
      expect(r.kind, AttemptKind.delayed);
      expect(r.wait, const Duration(seconds: 30));

      now = now.add(const Duration(seconds: 31));
      expect((await g.attempt(() async => true)).kind, AttemptKind.success);
    });

    test('a correct credential resets the counter', () async {
      final g = guard(DeviceRole.spoke);
      for (var i = 0; i < 4; i++) {
        await fail(g);
      }
      expect((await g.attempt(() async => true)).kind, AttemptKind.success);
      for (var i = 1; i <= 4; i++) {
        expect((await fail(g)).kind, AttemptKind.rejected);
      }
    });

    test('the counter and the wait survive an app restart', () async {
      final first = guard(DeviceRole.spoke);
      for (var i = 0; i < 5; i++) {
        await fail(first);
      }
      final restarted = guard(DeviceRole.spoke);
      final s = await restarted.status();
      expect(s.kind, AttemptKind.delayed);
      expect(s.failures, 5);
    });

    test('setting the clock back does not lengthen the wait', () async {
      final g = guard(DeviceRole.spoke);
      for (var i = 0; i < 5; i++) {
        await fail(g);
      }
      now = now.subtract(const Duration(days: 3));
      expect((await g.status()).wait, const Duration(seconds: 30));
    });

    test('errors from the check are not counted as failures', () async {
      final g = guard(DeviceRole.spoke);
      await expectLater(
        g.attempt(() async => throw StateError('database busy')),
        throwsStateError,
      );
      expect((await g.status()).failures, 0);
    });

    test('concurrent attempts are counted one by one', () async {
      final g = guard(DeviceRole.spoke);
      await Future.wait([for (var i = 0; i < 4; i++) fail(g)]);
      expect((await g.status()).failures, 4);
    });

    test('Spoke: the 10th failure wipes local data', () async {
      final g = guard(DeviceRole.spoke);
      await store.write('db_key', 'secret');
      final terminal = g.terminalStates.first;
      AttemptStatus? last;
      for (var i = 1; i <= 10; i++) {
        last = await fail(g);
        now = now.add(const Duration(hours: 1));
      }
      expect(last!.kind, AttemptKind.wiped);
      expect(wiper.wipes, 1);
      expect(store.dump(), isEmpty);
      expect((await terminal).kind, AttemptKind.wiped);

      // Nothing more can be tried on a wiped device.
      var checked = false;
      final after = await g.attempt(() async => checked = true);
      expect(after.kind, AttemptKind.wiped);
      expect(checked, isFalse);
    });

    test('Hub: the 10th failure locks the device but never wipes it',
        () async {
      final g = guard(DeviceRole.hub);
      final terminal = g.terminalStates.first;
      for (var i = 1; i <= 10; i++) {
        await fail(g);
        now = now.add(const Duration(hours: 1));
      }
      expect(wiper.wipes, 0);
      expect((await terminal).kind, AttemptKind.lockedOut);
      expect((await g.status()).kind, AttemptKind.lockedOut);

      var checked = false;
      expect((await g.attempt(() async => checked = true)).kind,
          AttemptKind.lockedOut);
      expect(checked, isFalse, reason: 'even the right password is refused');

      // Still locked after a restart.
      expect((await guard(DeviceRole.hub).status()).kind, AttemptKind.lockedOut);
    });
  });

  group('AttemptStatus.message', () {
    test('warns before the first wait', () {
      const s = AttemptStatus(AttemptKind.rejected, role: DeviceRole.spoke, failures: 3);
      expect(s.message('PIN ไม่ถูกต้อง'), contains('ผิดอีก 2 ครั้งจะต้องรอ'));
      const early = AttemptStatus(AttemptKind.rejected, role: DeviceRole.spoke, failures: 1);
      expect(early.message('PIN ไม่ถูกต้อง'), 'PIN ไม่ถูกต้อง');
    });

    test('a wait says how long and what happens next', () {
      const spoke = AttemptStatus(AttemptKind.delayed,
          role: DeviceRole.spoke, failures: 6, wait: Duration(seconds: 90));
      expect(spoke.message(''), contains('2 นาที'));
      expect(spoke.message(''), contains('ผิดอีก 4 ครั้ง ข้อมูลในเครื่องนี้จะถูกลบ'));

      const hub = AttemptStatus(AttemptKind.delayed,
          role: DeviceRole.hub, failures: 5, wait: Duration(seconds: 30));
      expect(hub.message(''), contains('30 วินาที'));
      expect(hub.message(''), contains('เครื่องนี้จะถูกล็อก'));
    });
  });

  group('DeviceRoleConfig', () {
    test('Windows is the Hub, phones are Spokes', () {
      expect(DeviceRoleConfig.forPlatform(TargetPlatform.windows, override: ''),
          DeviceRole.hub);
      expect(DeviceRoleConfig.forPlatform(TargetPlatform.android, override: ''),
          DeviceRole.spoke);
      expect(DeviceRoleConfig.forPlatform(TargetPlatform.iOS, override: ''),
          DeviceRole.spoke);
    });

    test('DEVICE_ROLE overrides the platform', () {
      expect(DeviceRoleConfig.forPlatform(TargetPlatform.android, override: 'hub'),
          DeviceRole.hub);
      expect(DeviceRoleConfig.forPlatform(TargetPlatform.windows, override: 'spoke'),
          DeviceRole.spoke);
    });
  });
}
