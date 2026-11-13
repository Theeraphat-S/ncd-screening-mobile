import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/feature/auth/bloc/auth_bloc.dart';
import 'package:ncd_screening_mobile/feature/nurse/bloc/village_bloc.dart';
import 'package:ncd_screening_mobile/feature/patient/bloc/patient_bloc.dart';
import 'package:ncd_screening_mobile/feature/screening/bloc/screening_bloc.dart';
import 'package:ncd_screening_mobile/feature/vhv/bloc/vhv_bloc.dart';

void main() {
  late MockNcdRepository repository;

  setUp(() {
    repository = MockNcdRepository();
  });

  group('AuthBloc tests', () {
    test('Initial state is initial status', () {
      final bloc = AuthBloc(repository);
      expect(bloc.state.status, equals(AuthStatus.initial));
    });

    test('Patient login emits authenticated with Patient', () async {
      final bloc = AuthBloc(repository);
      bloc.add(AuthLoginSubmitted(
        role: UserRole.patient,
        identifier: '1234567890123',
        birthDate: DateTime(1980, 2, 1),
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.authenticated)
              .having((s) => s.currentUser, 'currentUser', isA<Patient>()),
        ]),
      );
      await bloc.close();
    });

    test('VHV login emits authenticated with VHV', () async {
      final bloc = AuthBloc(repository);
      bloc.add(const AuthLoginSubmitted(
        role: UserRole.vhv,
        identifier: '1111111111111',
        password: 'password123',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.authenticated)
              .having((s) => s.currentUser, 'currentUser', isA<VHV>()),
        ]),
      );
      await bloc.close();
    });

    test('Nurse login emits authenticated with Nurse', () async {
      final bloc = AuthBloc(repository);
      bloc.add(const AuthLoginSubmitted(
        role: UserRole.nurse,
        identifier: 'NUR001',
        password: 'password123',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.authenticated)
              .having((s) => s.currentUser, 'currentUser', isA<Nurse>()),
        ]),
      );
      await bloc.close();
    });

    test('Logout emits unauthenticated status', () async {
      final bloc = AuthBloc(repository);
      bloc.add(AuthLogoutRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthState>().having((s) => s.status, 'status', AuthStatus.unauthenticated),
        ]),
      );
      await bloc.close();
    });
  });

  group('PatientBloc tests', () {
    test('PatientLoadRequested loads patients', () async {
      final bloc = PatientBloc(repository);
      bloc.add(const PatientLoadRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PatientState>().having((s) => s.status, 'status', PatientStatus.loading),
          isA<PatientState>()
              .having((s) => s.status, 'status', PatientStatus.success)
              .having((s) => s.patients.length, 'patients count', greaterThanOrEqualTo(6)),
        ]),
      );
      await bloc.close();
    });

    test('PatientSearchChanged filters results', () async {
      final bloc = PatientBloc(repository);
      bloc.add(const PatientSearchChanged('สมชาย'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PatientState>().having((s) => s.status, 'status', PatientStatus.loading),
          isA<PatientState>()
              .having((s) => s.status, 'status', PatientStatus.success)
              .having((s) => s.patients.first.patientFname, 'first patient', 'สมชาย'),
        ]),
      );
      await bloc.close();
    });

    test('PatientAddRequested adds patient and refreshes list', () async {
      final bloc = PatientBloc(repository);
      final newPatient = Patient(
        patientId: '',
        patientCitizenId: '7777777777777',
        patientTitle: 'นาย',
        patientFname: 'ทดสอบบล็อก',
        patientLname: 'ใจดี',
        patientGender: 'ชาย',
        patientBirthDate: DateTime(1990, 1, 1),
        patientAddress: '99/9 หมู่ 1',
        villageId: 'V001',
      );

      bloc.add(PatientAddRequested(newPatient));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PatientState>().having((s) => s.status, 'status', PatientStatus.loading),
          isA<PatientState>().having((s) => s.status, 'status', PatientStatus.success),
        ]),
      );
      await bloc.close();
    });
  });

  group('ScreeningBloc tests', () {
    test('ScreeningHistoryLoadRequested loads patient screenings', () async {
      final bloc = ScreeningBloc(repository);
      bloc.add(const ScreeningHistoryLoadRequested('P001'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ScreeningState>().having((s) => s.status, 'status', ScreeningStatus.loading),
          isA<ScreeningState>()
              .having((s) => s.status, 'status', ScreeningStatus.success)
              .having((s) => s.historyList.isNotEmpty, 'history not empty', isTrue),
        ]),
      );
      await bloc.close();
    });

    test('ScreeningApproveRequested updates review status', () async {
      final bloc = ScreeningBloc(repository);
      bloc.add(const ScreeningApproveRequested(
        screeningId: 'S001',
        status: ReviewStatus.approved,
        nurseId: 'NUR001',
      ));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ScreeningState>().having((s) => s.status, 'status', ScreeningStatus.loading),
          isA<ScreeningState>()
              .having((s) => s.status, 'status', ScreeningStatus.success)
              .having((s) => s.currentScreening?.reviewStatus, 'approved', ReviewStatus.approved),
        ]),
      );
      await bloc.close();
    });
  });

  group('VillageBloc & VhvBloc tests', () {
    test('VillageListLoadRequested loads villages', () async {
      final bloc = VillageBloc(repository);
      bloc.add(VillageListLoadRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<VillageState>().having((s) => s.status, 'status', VillageStatus.loading),
          isA<VillageState>()
              .having((s) => s.status, 'status', VillageStatus.success)
              .having((s) => s.villages.length, 'villages count', 5),
        ]),
      );
      await bloc.close();
    });

    test('VhvListLoadRequested loads VHVs', () async {
      final bloc = VhvBloc(repository);
      bloc.add(const VhvListLoadRequested());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<VhvState>().having((s) => s.status, 'status', VhvStatus.loading),
          isA<VhvState>()
              .having((s) => s.status, 'status', VhvStatus.success)
              .having((s) => s.vhvs.isNotEmpty, 'vhvs not empty', isTrue),
        ]),
      );
      await bloc.close();
    });
  });
}
