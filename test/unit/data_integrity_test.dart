import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/ncd_tables.dart';
import 'package:ncd_screening_mobile/data/repositories/drift_ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/repositories/repository_errors.dart';
import 'package:ncd_screening_mobile/domain/services/record_rules.dart';
import 'package:ncd_screening_mobile/feature/patient/bloc/patient_bloc.dart';
import 'package:ncd_screening_mobile/feature/screening/bloc/screening_bloc.dart';

import '../helpers/citizen_ids.dart';

/// P001 in both the Drift seed and the mock repository.
const _seedCitizenId = '1234567890121';

Patient _patient(String citizenId, {String id = ''}) => Patient(
  patientId: id,
  patientCitizenId: citizenId,
  patientTitle: 'นาง',
  patientFname: 'ทดสอบ',
  patientLname: 'ข้อมูล',
  patientGender: 'หญิง',
  patientBirthDate: DateTime(1970, 5, 1),
  patientAddress: '5 หมู่ 2',
  villageId: 'V001',
);

Screening _screening({
  double weight = 60,
  double height = 160,
  double waist = 80,
  double sbp = 130,
  double dbp = 85,
  double pulse = 75,
  double? sugar = 100,
}) => Screening(
  screenId: '',
  patientId: 'P001',
  vhvId: 'VHV001',
  screeningDate: DateTime(2026, 11, 26),
  ageAtScreening: 55,
  createdAt: DateTime(2026, 11, 26),
  reviewStatus: ReviewStatus.pending,
  weight: weight,
  height: height,
  bmi: 23.4,
  waistCm: waist,
  sbp: sbp,
  dbp: dbp,
  pulse: pulse,
  bloodSugar: sugar,
);

Future<bool> _hasUniqueIndex(AppDatabase db) async =>
    (await db
            .customSelect(
              "SELECT 1 FROM sqlite_master WHERE type = 'index' AND name = ?",
              variables: [
                Variable.withString(AppDatabaseIndexes.patientCitizenIdUnique),
              ],
            )
            .get())
        .isNotEmpty;

void main() {
  group('RecordRules', () {
    test('a new citizen ID must pass the check digit', () {
      expect(
        () => RecordRules.checkPatient(_patient('1234567890123')),
        throwsA(isA<InvalidRecordException>()),
      );
      expect(
        () => RecordRules.checkPatient(_patient('12345')),
        throwsA(isA<InvalidRecordException>()),
      );
      RecordRules.checkPatient(_patient(' $_seedCitizenId '));
    });

    test('an unchanged ID from before the check can still be edited', () {
      RecordRules.checkPatient(
        _patient('1111111111111'),
        previousCitizenId: '1111111111111',
      );
      expect(
        () => RecordRules.checkPatient(
          _patient('1111111111112'),
          previousCitizenId: '1111111111111',
        ),
        throwsA(isA<InvalidRecordException>()),
      );
    });

    test('screening values are re-checked with ScreeningValidator', () {
      RecordRules.checkScreening(_screening());
      RecordRules.checkScreening(_screening(sugar: null));
      String messageFor(Screening s) {
        try {
          RecordRules.checkScreening(s);
        } on InvalidRecordException catch (e) {
          return e.message;
        }
        fail('accepted $s');
      }

      expect(messageFor(_screening(height: 1.6)), contains('เซนติเมตร'));
      expect(
        messageFor(_screening(sbp: 80, dbp: 120)),
        contains('DBP ต้องน้อยกว่า SBP'),
      );
      expect(messageFor(_screening(sbp: 400)), contains('ความดันตัวบน'));
      expect(messageFor(_screening(weight: double.nan)), contains('น้ำหนัก'));
      expect(messageFor(_screening(pulse: -5)), contains('ชีพจร'));
      expect(messageFor(_screening(sugar: 5000)), contains('น้ำตาล'));
    });
  });

  group('Unique citizen ID in the database (schema v6)', () {
    test('a new database has the unique index', () async {
      final db = AppDatabase(NativeDatabase.memory(), seedDemoData: true);
      addTearDown(db.close);
      expect(await _hasUniqueIndex(db), isTrue);
      await expectLater(
        db.customStatement(
          'INSERT INTO patients (patient_id, patient_citizen_id, patient_title, '
          'patient_fname, patient_lname, patient_gender, patient_birth_date, '
          "patient_address, village_id) VALUES ('X', '$_seedCitizenId', 'นาย', "
          "'a', 'b', 'ชาย', 0, 'c', 'V001')",
        ),
        throwsA(anything),
      );
    });

    group('upgrade from v5', () {
      late Directory dir;
      late File file;

      setUp(() => dir = Directory.systemTemp.createTempSync('ncd_v6'));
      tearDown(() {
        try {
          dir.deleteSync(recursive: true);
        } on FileSystemException {
          // Windows may hold the handle briefly; a temp dir is harmless.
        }
      });

      /// A v5 database: seeded, without the index, optionally with a
      /// second patient sharing P001's citizen ID.
      Future<void> writeV5({required bool duplicate}) async {
        file = File('${dir.path}/app.sqlite');
        final db = AppDatabase(NativeDatabase(file), seedDemoData: true);
        await db.customSelect('SELECT 1').get();
        await db.customStatement(
          'DROP INDEX ${AppDatabaseIndexes.patientCitizenIdUnique}',
        );
        if (duplicate) {
          await db.customStatement(
            "INSERT INTO patients SELECT 'P_DUP', patient_citizen_id, "
            'patient_title, patient_fname, patient_lname, patient_gender, '
            'patient_birth_date, patient_address, patient_mobile, patient_img, '
            "village_id FROM patients WHERE patient_id = 'P001'",
          );
        }
        await db.customStatement('PRAGMA user_version = 5');
        await db.close();
      }

      test('adds the index when there are no duplicates', () async {
        await writeV5(duplicate: false);
        final db = AppDatabase(NativeDatabase(file), seedDemoData: false);
        addTearDown(db.close);
        expect(await _hasUniqueIndex(db), isTrue);
        final v = await db.customSelect('PRAGMA user_version').getSingle();
        expect(v.read<int>('user_version'), 6);
      });

      test(
        'keeps data with duplicates and adds the index once they are resolved',
        () async {
          await writeV5(duplicate: true);
          var db = AppDatabase(NativeDatabase(file), seedDemoData: false);
          expect(await _hasUniqueIndex(db), isFalse);
          expect(await db.duplicateCitizenIds(), [_seedCitizenId]);
          expect(await db.select(db.patientsTable).get(), hasLength(7));

          // New duplicates are still refused by the repository.
          await expectLater(
            DriftNcdRepository(db).addPatient(_patient(_seedCitizenId)),
            throwsA(isA<DuplicateCitizenIdException>()),
          );

          await DriftNcdRepository(db).deletePatient('P_DUP');
          await db.close();

          db = AppDatabase(NativeDatabase(file), seedDemoData: false);
          addTearDown(db.close);
          expect(await _hasUniqueIndex(db), isTrue);
        },
      );
    });
  });

  group('DriftNcdRepository rules', () {
    late AppDatabase db;
    late DriftNcdRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory(), seedDemoData: true);
      repo = DriftNcdRepository(db);
    });
    tearDown(() => db.close());

    test(
      'adding a citizen ID that exists is refused, spaces ignored',
      () async {
        await expectLater(
          repo.addPatient(_patient(' $_seedCitizenId ')),
          throwsA(isA<DuplicateCitizenIdException>()),
        );
        final count = (await db.select(db.patientsTable).get()).length;
        expect(count, 6, reason: 'nothing was written');
      },
    );

    test('a new ID is stored trimmed', () async {
      final id = withCheckDigit('310050012345');
      final added = await repo.addPatient(_patient('  $id '));
      expect(added.patientCitizenId, id);
      expect(
        (await repo.getPatientById(added.patientId))!.patientCitizenId,
        id,
      );
    });

    test('a wrong check digit is refused', () async {
      await expectLater(
        repo.addPatient(_patient('1234567890123')),
        throwsA(
          isA<InvalidRecordException>().having(
            (e) => e.message,
            'message',
            RecordRules.invalidCitizenIdMessage,
          ),
        ),
      );
    });

    test('editing to another patient\'s ID is refused', () async {
      final p002 = (await repo.getPatientById('P002'))!;
      await expectLater(
        repo.updatePatient(p002.copyWith(patientCitizenId: _seedCitizenId)),
        throwsA(isA<DuplicateCitizenIdException>()),
      );
      expect(
        (await repo.getPatientById('P002'))!.patientCitizenId,
        p002.patientCitizenId,
      );
    });

    test(
      'editing other fields keeps the own ID, even one without a valid check digit',
      () async {
        await (db.update(
          db.patientsTable,
        )..where((t) => t.patientId.equals('P002'))).write(
          const PatientsTableCompanion(
            patientCitizenId: Value('2222222222220'), // entered before M1
          ),
        );
        final p002 = (await repo.getPatientById('P002'))!;
        final saved = await repo.updatePatient(
          p002.copyWith(patientFname: 'ใหม่'),
        );
        expect(saved.patientFname, 'ใหม่');

        await expectLater(
          repo.updatePatient(p002.copyWith(patientCitizenId: '2222222222221')),
          throwsA(isA<InvalidRecordException>()),
        );
      },
    );

    test('an out-of-range screening is not saved', () async {
      final before = (await repo.getAllScreenings()).length;
      await expectLater(
        repo.saveScreening(_screening(sbp: 80, dbp: 120)),
        throwsA(isA<InvalidRecordException>()),
      );
      expect((await repo.getAllScreenings()).length, before);
      await repo.saveScreening(_screening());
      expect((await repo.getAllScreenings()).length, before + 1);
    });
  });

  group('MockNcdRepository rules', () {
    test('duplicates and bad check digits are refused', () async {
      final repo = MockNcdRepository();
      await expectLater(
        repo.addPatient(_patient(_seedCitizenId)),
        throwsA(isA<DuplicateCitizenIdException>()),
      );
      await expectLater(
        repo.addPatient(_patient('1234567890123')),
        throwsA(isA<InvalidRecordException>()),
      );
      final p002 = (await repo.getPatientById('P002'))!;
      await expectLater(
        repo.updatePatient(p002.copyWith(patientCitizenId: _seedCitizenId)),
        throwsA(isA<DuplicateCitizenIdException>()),
      );
      await expectLater(
        repo.saveScreening(_screening(height: 1.6)),
        throwsA(isA<InvalidRecordException>()),
      );
    });
  });

  group('BLoCs show the rule that was broken', () {
    test('PatientBloc: duplicate citizen ID', () async {
      final bloc = PatientBloc(MockNcdRepository());
      addTearDown(bloc.close);
      final failed = bloc.stream.firstWhere(
        (s) => s.status == PatientStatus.failure,
      );
      bloc.add(PatientAddRequested(_patient(_seedCitizenId)));
      expect(
        (await failed).errorMessage,
        const DuplicateCitizenIdException().message,
      );
    });

    test('ScreeningBloc: out-of-range value', () async {
      final bloc = ScreeningBloc(MockNcdRepository());
      addTearDown(bloc.close);
      final failed = bloc.stream.firstWhere(
        (s) => s.status == ScreeningStatus.failure,
      );
      bloc.add(ScreeningSaveRequested(_screening(sbp: 80, dbp: 120)));
      expect((await failed).errorMessage, contains('DBP ต้องน้อยกว่า SBP'));
    });
  });
}
