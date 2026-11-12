import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/shared/bloc/app_lock/app_lock_cubit.dart';

void main() {
  group('AppLockCubit', () {
    test('starts signed out until a user signs in', () {
      final cubit = AppLockCubit();
      expect(cubit.state.status, AppLockStatus.signedOut);
      cubit.close();
    });

    test('startSession unlocks; 15 min of inactivity locks', () {
      fakeAsync((async) {
        final cubit = AppLockCubit();
        cubit.startSession();
        expect(cubit.state.status, AppLockStatus.unlocked);

        async.elapse(const Duration(minutes: 14, seconds: 59));
        expect(cubit.state.status, AppLockStatus.unlocked);

        async.elapse(const Duration(seconds: 2));
        expect(cubit.state.status, AppLockStatus.locked);
        cubit.close();
      });
    });

    test('user activity restarts the idle timer', () {
      fakeAsync((async) {
        final cubit = AppLockCubit();
        cubit.startSession();
        async.elapse(const Duration(minutes: 10));
        cubit.onUserActivity();
        async.elapse(const Duration(minutes: 10));
        expect(cubit.state.status, AppLockStatus.unlocked);
        async.elapse(const Duration(minutes: 6));
        expect(cubit.state.status, AppLockStatus.locked);
        cubit.close();
      });
    });

    test('activity while locked does not unlock', () {
      fakeAsync((async) {
        final cubit = AppLockCubit();
        cubit.startSession();
        async.elapse(const Duration(minutes: 16));
        cubit.onUserActivity();
        expect(cubit.state.status, AppLockStatus.locked);
        cubit.close();
      });
    });

    test('unlock() returns to unlocked and re-arms the timer', () {
      fakeAsync((async) {
        final cubit = AppLockCubit();
        cubit.startSession();
        async.elapse(const Duration(minutes: 16));
        cubit.unlock();
        expect(cubit.state.status, AppLockStatus.unlocked);
        async.elapse(const Duration(minutes: 16));
        expect(cubit.state.status, AppLockStatus.locked);
        cubit.close();
      });
    });

    test('endSession signs out and cancels the timer', () {
      fakeAsync((async) {
        final cubit = AppLockCubit();
        cubit.startSession();
        cubit.endSession();
        expect(cubit.state.status, AppLockStatus.signedOut);
        async.elapse(const Duration(hours: 1));
        expect(cubit.state.status, AppLockStatus.signedOut);
        cubit.close();
      });
    });

    test('idle limit is configurable', () {
      fakeAsync((async) {
        final cubit = AppLockCubit(idleTimeout: const Duration(minutes: 5));
        cubit.startSession();
        async.elapse(const Duration(minutes: 5, seconds: 1));
        expect(cubit.state.status, AppLockStatus.locked);
        cubit.close();
      });
    });
  });
}
