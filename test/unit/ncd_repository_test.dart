import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import '../support/mock_ncd_repository.dart';

void main() {
  late MockNcdRepository repository;

  setUp(() {
    repository = MockNcdRepository();
  });

  group('MockNcdRepository - Authentication (login)', () {
    test('Patient login succeeds with valid 13-digit citizen ID', () async {
      final user = await repository.login(
        role: UserRole.patient,
        identifier: '1234567890123',
      );

      expect(user, isA<Patient>());
      final patient = user as Patient;
      expect(patient.patientId, equals('P001'));
      expect(patient.patientFname, equals('สมชาย'));
    });

    test(
      'Patient login throws Exception for unregistered citizen ID',
      () async {
        expect(
          () => repository.login(
            role: UserRole.patient,
            identifier: '9999999999999',
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test(
      'VHV login succeeds with valid credentials (mobile/ID and correct password)',
      () async {
        final user = await repository.login(
          role: UserRole.vhv,
          identifier: '0800000001',
          password: 'password123',
        );

        expect(user, isA<VHV>());
        final vhv = user as VHV;
        expect(vhv.vhvId, equals('VHV001'));
        expect(vhv.vhvFname, equals('อสม'));
      },
    );

    test('VHV login throws Exception with wrong password', () async {
      expect(
        () => repository.login(
          role: UserRole.vhv,
          identifier: '0800000001',
          password: 'wrong_password',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Nurse login succeeds with valid nurse ID and password', () async {
      final user = await repository.login(
        role: UserRole.nurse,
        identifier: 'NUR001',
        password: 'password123',
      );

      expect(user, isA<Nurse>());
      final nurse = user as Nurse;
      expect(nurse.nurseId, equals('NUR001'));
      expect(nurse.nurseFname, equals('กานดา'));
    });

    test('Nurse login throws Exception with wrong password', () async {
      expect(
        () => repository.login(
          role: UserRole.nurse,
          identifier: 'NUR001',
          password: 'incorrectPassword',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('MockNcdRepository - Patient CRUD and Search/Filter', () {
    test('getPatients retrieves full seeded list', () async {
      final patients = await repository.getPatients();
      expect(patients.length, greaterThanOrEqualTo(6));
    });

    test('getPatients filters correctly by villageId', () async {
      final patientsV001 = await repository.getPatients(villageId: 'V001');
      expect(patientsV001.every((p) => p.villageId == 'V001'), isTrue);

      final patientsNonExistent = await repository.getPatients(
        villageId: 'V999',
      );
      expect(patientsNonExistent, isEmpty);
    });

    test(
      'getPatients filters correctly by searchQuery (name and citizen ID)',
      () async {
        final resultsByName = await repository.getPatients(
          searchQuery: 'สมชาย',
        );
        expect(resultsByName.length, equals(1));
        expect(resultsByName.first.patientFname, equals('สมชาย'));

        final resultsById = await repository.getPatients(
          searchQuery: '1234567890123',
        );
        expect(resultsById.length, equals(1));
        expect(resultsById.first.patientId, equals('P001'));
      },
    );

    test(
      'getPatientById and getPatientByCitizenId return correct patient',
      () async {
        final patientById = await repository.getPatientById('P001');
        expect(patientById, isNotNull);
        expect(patientById!.patientFname, equals('สมชาย'));

        final patientByCitizenId = await repository.getPatientByCitizenId(
          '1234567890123',
        );
        expect(patientByCitizenId, isNotNull);
        expect(patientByCitizenId!.patientId, equals('P001'));

        final notFound = await repository.getPatientById('INVALID_ID');
        expect(notFound, isNull);
      },
    );

    test('addPatient inserts a new patient and assigns an ID', () async {
      final newPatient = Patient(
        patientId: '',
        patientCitizenId: '9876543210123',
        patientTitle: 'นาย',
        patientFname: 'ทดสอบ',
        patientLname: 'ระบบ',
        patientGender: 'ชาย',
        patientBirthDate: DateTime(1995, 1, 1),
        patientAddress: '123 หมู่ 2',
        patientMobile: '0811111111',
        villageId: 'V002',
      );

      final added = await repository.addPatient(newPatient);
      expect(added.patientId, startsWith('P'));
      expect(added.patientFname, equals('ทดสอบ'));

      final fetched = await repository.getPatientById(added.patientId);
      expect(fetched, isNotNull);
      expect(fetched!.patientCitizenId, equals('9876543210123'));
    });

    test('updatePatient updates patient details successfully', () async {
      final existing = (await repository.getPatientById('P001'))!;
      final updated = existing.copyWith(patientMobile: '0899999999');

      final result = await repository.updatePatient(updated);
      expect(result.patientMobile, equals('0899999999'));

      final fetched = await repository.getPatientById('P001');
      expect(fetched!.patientMobile, equals('0899999999'));
    });

    test('deletePatient removes patient from repository', () async {
      final deleteSuccess = await repository.deletePatient('P002');
      expect(deleteSuccess, isTrue);

      final fetched = await repository.getPatientById('P002');
      expect(fetched, isNull);
    });
  });

  group('MockNcdRepository - VHV Management', () {
    test('getVhvs retrieves list and can filter by villageId', () async {
      final allVhvs = await repository.getVhvs();
      expect(allVhvs.length, greaterThanOrEqualTo(3));

      final vhvV001 = await repository.getVhvs(villageId: 'V001');
      expect(vhvV001.every((v) => v.villageId == 'V001'), isTrue);
    });

    test('getVhvById returns matching VHV or null', () async {
      final vhv = await repository.getVhvById('VHV001');
      expect(vhv, isNotNull);
      expect(vhv!.vhvFname, equals('อสม'));

      final invalid = await repository.getVhvById('VHV_NONEXIST');
      expect(invalid, isNull);
    });

    test('addVhv inserts a new VHV', () async {
      final newVhv = VHV(
        vhvId: '',
        vhvCitizenId: '5555555555555',
        vhvTitle: 'นางสาว',
        vhvFname: 'ใจดี',
        vhvLname: 'บริการ',
        vhvMobile: '0855555555',
        vhvEmail: 'jaidee@example.com',
        vhvPassword: 'password123',
        vhvBirthDate: DateTime(1992, 4, 10),
        vhvGender: 'หญิง',
        vhvAddress: '88 หมู่ 3',
        villageId: 'V003',
      );

      final created = await repository.addVhv(newVhv);
      expect(created.vhvId, startsWith('VHV'));
      expect(created.vhvFname, equals('ใจดี'));

      final fetched = await repository.getVhvById(created.vhvId);
      expect(fetched, isNotNull);
      expect(fetched!.vhvEmail, equals('jaidee@example.com'));
    });

    test('updateVhv updates existing VHV information', () async {
      final existing = (await repository.getVhvById('VHV001'))!;
      final modified = existing.copyWith(vhvMobile: '0809999999');

      final result = await repository.updateVhv(modified);
      expect(result.vhvMobile, equals('0809999999'));

      final fetched = await repository.getVhvById('VHV001');
      expect(fetched!.vhvMobile, equals('0809999999'));
    });
  });

  group('MockNcdRepository - Screenings and Nurse Approval', () {
    test(
      'getScreeningsByPatient returns screenings ordered descending by date',
      () async {
        final screenings = await repository.getScreeningsByPatient('P001');
        expect(screenings.isNotEmpty, isTrue);
        expect(screenings.length, greaterThanOrEqualTo(2));
        expect(
          screenings.first.screeningDate.isAfter(screenings.last.screeningDate),
          isTrue,
        );
      },
    );

    test(
      'getAllScreenings returns all screenings or filtered by villageId',
      () async {
        final all = await repository.getAllScreenings();
        expect(all.length, greaterThanOrEqualTo(2));

        final v001Screenings = await repository.getAllScreenings(
          villageId: 'V001',
        );
        expect(v001Screenings.length, equals(2));

        final v002Screenings = await repository.getAllScreenings(
          villageId: 'V002',
        );
        expect(v002Screenings, isEmpty);
      },
    );

    test('saveScreening adds a new screening record', () async {
      final newScreening = Screening(
        screenId: '',
        patientId: 'P003',
        vhvId: 'VHV001',
        screeningDate: DateTime.now(),
        ageAtScreening: 50,
        createdAt: DateTime.now(),
        reviewStatus: ReviewStatus.pending,
        weight: 65,
        height: 165,
        bmi: 23.9,
        waistCm: 78,
        sbp: 130,
        dbp: 85,
        pulse: 75,
        bloodSugar: 110,
        histories: [],
        results: [],
      );

      final saved = await repository.saveScreening(newScreening);
      expect(saved.screenId, startsWith('S'));

      final fetched = await repository.getScreeningById(saved.screenId);
      expect(fetched, isNotNull);
      expect(fetched!.patientId, equals('P003'));
      expect(fetched.reviewStatus, equals(ReviewStatus.pending));
    });

    test(
      'updateScreeningReview approves/rejects screening with nurseId and timestamp',
      () async {
        final updated = await repository.updateScreeningReview(
          screeningId: 'S001',
          status: ReviewStatus.approved,
          nurseId: 'NUR001',
        );

        expect(updated.reviewStatus, equals(ReviewStatus.approved));
        expect(updated.reviewedByNurseId, equals('NUR001'));
        expect(updated.reviewedAt, isNotNull);

        final fetched = await repository.getScreeningById('S001');
        expect(fetched!.reviewStatus, equals(ReviewStatus.approved));
      },
    );
  });

  group('MockNcdRepository - Villages & Nurse', () {
    test('getVillages returns list of 5 seeded villages', () async {
      final villages = await repository.getVillages();
      expect(villages.length, equals(5));
      expect(villages.any((v) => v.villageName == 'บ้านท่าตอน'), isTrue);
    });

    test('getVillageById returns correct village', () async {
      final village = await repository.getVillageById('V001');
      expect(village, isNotNull);
      expect(village!.villageName, equals('บ้านท่าตอน'));
    });

    test('getNurseById returns nurse data', () async {
      final nurse = await repository.getNurseById('NUR001');
      expect(nurse, isNotNull);
      expect(nurse!.nurseFname, equals('กานดา'));
    });
  });
}
