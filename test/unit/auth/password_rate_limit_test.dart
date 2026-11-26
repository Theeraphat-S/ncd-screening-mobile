import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/services/auth_attempt_guard.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';
import 'package:ncd_screening_mobile/feature/auth/bloc/auth_bloc.dart';

class _NoopWiper implements DeviceWiper {
  int wipes = 0;
  @override
  Future<void> wipe() async => wipes++;
}

void main() {
  late AuthAttemptGuard guard;
  late _NoopWiper wiper;
  late AuthBloc bloc;
  late DateTime now;

  setUp(() {
    now = DateTime(2026, 11, 26, 9);
    wiper = _NoopWiper();
    guard = AuthAttemptGuard(
      store: InMemorySecureStore(),
      role: DeviceRole.spoke,
      wiper: wiper,
      now: () => now,
    );
    bloc = AuthBloc(MockNcdRepository(), attemptGuard: guard);
  });
  tearDown(() => bloc.close());

  Future<AuthState> submit({
    UserRole role = UserRole.nurse,
    String identifier = 'NUR001',
    String? password,
    DateTime? birthDate,
  }) {
    final done = bloc.stream.firstWhere(
      (s) => s.status == AuthStatus.authenticated || s.status == AuthStatus.error,
    );
    bloc.add(AuthLoginSubmitted(
      role: role,
      identifier: identifier,
      password: password,
      birthDate: birthDate,
    ));
    return done;
  }

  test('a wrong password says so; the 5th starts a wait', () async {
    for (var i = 1; i <= 4; i++) {
      final s = await submit(password: 'wrong');
      expect(s.status, AuthStatus.error);
      expect(s.errorMessage, startsWith('รหัสพยาบาลหรือรหัสผ่านไม่ถูกต้อง'));
    }
    final fifth = await submit(password: 'wrong');
    expect(fifth.errorMessage, contains('กรุณารอ 30 วินาที'));
  });

  test('during the wait even the right password is refused', () async {
    for (var i = 0; i < 5; i++) {
      await submit(password: 'wrong');
    }
    final blocked = await submit(password: 'password123');
    expect(blocked.status, AuthStatus.error);
    expect(blocked.errorMessage, contains('กรุณารอ'));

    now = now.add(const Duration(seconds: 31));
    final ok = await submit(password: 'password123');
    expect(ok.status, AuthStatus.authenticated);
    expect((await guard.status()).failures, 0);
  });

  test('wrong PINs and wrong passwords share one counter', () async {
    for (var i = 0; i < 4; i++) {
      await guard.attempt(() async => false); // four wrong PINs
    }
    final s = await submit(password: 'wrong');
    expect(s.errorMessage, contains('กรุณารอ'));
    expect((await guard.status()).failures, 5);
  });

  test('VHV sign-in is limited too', () async {
    for (var i = 0; i < 5; i++) {
      await submit(role: UserRole.vhv, identifier: '1111111111111', password: 'x');
    }
    expect((await guard.status()).kind, AttemptKind.delayed);
  });

  test('ten wrong passwords on a Spoke wipe it', () async {
    AuthState? last;
    for (var i = 0; i < 10; i++) {
      last = await submit(password: 'wrong');
      now = now.add(const Duration(hours: 1));
    }
    expect(wiper.wipes, 1);
    expect(last!.errorMessage, contains('ข้อมูลในเครื่องนี้ถูกลบแล้ว'));
  });

  test('patient sign-in is not counted (patient login goes away in M3)',
      () async {
    for (var i = 0; i < 6; i++) {
      final s = await submit(
        role: UserRole.patient,
        identifier: '1234567890121',
        birthDate: DateTime(1999, 1, 1),
      );
      expect(s.status, AuthStatus.error);
    }
    expect((await guard.status()).failures, 0);
  });
}
