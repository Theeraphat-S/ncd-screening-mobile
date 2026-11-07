import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/data/repositories/drift_ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/locator.dart';
import '../support/test_citizen_ids.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Empirical Challenge: Drift SQLite Persistence & Repository', () {
    late AppDatabase db;
    late DriftNcdRepository repository;

    setUp(() async {
      db = AppDatabase(
        citizenIds: testCitizenIds(),
        executor: NativeDatabase.memory(),
      );
      repository = DriftNcdRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    group('1. Edge Cases & Boundary Conditions for Patient CRUD', () {
      test(
        'Patient with Thai unicode diacritics, symbols, and leading zeroes',
        () async {
          final specialPatient = Patient(
            patientId: '',
            patientCitizenId: '0123456789012',
            patientTitle: 'นาย',
            patientFname: 'สมศักดิ์-บุญมี',
            patientLname: 'ณ เชียงใหม่ (เจ้าเก่า)',
            patientGender: 'ชาย',
            patientBirthDate: DateTime(1985, 12, 31),
            patientAddress:
                '100/4 หมู่ 5 ซอย 2/1 ถ.ริมน้ำ ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่ 50280',
            patientMobile: '089-999-8888',
            patientImg: 'https://example.com/images/p_01.png?v=1.0&size=thumb',
            villageId: 'V001',
          );

          final added = await repository.addPatient(specialPatient);
          expect(added.patientId, isNotEmpty);
          expect(added.patientCitizenId, equals('0123456789012'));
          expect(added.patientFname, equals('สมศักดิ์-บุญมี'));

          // Query back
          final fetched = await repository.getPatientById(added.patientId);
          expect(fetched, isNotNull);
          expect(fetched!.patientLname, equals('ณ เชียงใหม่ (เจ้าเก่า)'));
          expect(fetched.patientMobile, equals('089-999-8888'));
          expect(
            fetched.patientImg,
            equals('https://example.com/images/p_01.png?v=1.0&size=thumb'),
          );

          // Query by citizen ID with whitespace
          final byCitizenId = await repository.getPatientByCitizenId(
            '  0123456789012  ',
          );
          expect(byCitizenId, isNotNull);
          expect(byCitizenId!.patientId, equals(added.patientId));
        },
      );

      test(
        'Consecutive additions generate unique sequential IDs without collisions',
        () async {
          final initialCount = (await repository.getPatients()).length;
          final ids = <String>{};

          for (var i = 0; i < 10; i++) {
            final p = Patient(
              patientId: '',
              patientCitizenId: '90000000000$i',
              patientTitle: 'นาย',
              patientFname: 'AutoSeq_$i',
              patientLname: 'Test',
              patientGender: 'ชาย',
              patientBirthDate: DateTime(1990, 1, 1),
              patientAddress: 'Addr $i',
              villageId: 'V001',
            );
            final created = await repository.addPatient(p);
            expect(
              ids.contains(created.patientId),
              isFalse,
              reason: 'Generated duplicate ID: ${created.patientId}',
            );
            ids.add(created.patientId);
          }

          final finalPatients = await repository.getPatients();
          expect(finalPatients.length, equals(initialCount + 10));
        },
      );

      test(
        'updatePatient throws Exception if target patient does not exist',
        () async {
          final ghostPatient = Patient(
            patientId: 'P_NON_EXISTENT_999',
            patientCitizenId: '9999999999999',
            patientTitle: 'นาย',
            patientFname: 'Ghost',
            patientLname: 'Person',
            patientGender: 'ชาย',
            patientBirthDate: DateTime(1990, 1, 1),
            patientAddress: 'Nowhere',
            villageId: 'V001',
          );

          expect(
            () => repository.updatePatient(ghostPatient),
            throwsA(isA<Exception>()),
          );
        },
      );

      test(
        'deletePatient returns true for existing and false for non-existent ID',
        () async {
          final resultExisting = await repository.deletePatient('P001');
          expect(resultExisting, isTrue);

          final checkDeleted = await repository.getPatientById('P001');
          expect(checkDeleted, isNull);

          final resultNonExisting = await repository.deletePatient(
            'P_DOES_NOT_EXIST',
          );
          expect(resultNonExisting, isFalse);
        },
      );
    });

    group('2. Search, Query, & Filtering Rigorous Stress Tests', () {
      test(
        'Search by partial Thai first name, last name, and full name',
        () async {
          // "สมชาย"
          final searchSom = await repository.getPatients(searchQuery: 'สม');
          expect(searchSom.length, greaterThanOrEqualTo(2)); // สมชาย, สมศรี
          expect(
            searchSom.any((p) => p.patientFname.contains('สมชาย')),
            isTrue,
          );
          expect(
            searchSom.any((p) => p.patientFname.contains('สมศรี')),
            isTrue,
          );

          // Search by last name "มีสุข"
          final searchLname = await repository.getPatients(
            searchQuery: 'มีสุข',
          );
          expect(searchLname.length, equals(1));
          expect(searchLname.first.patientFname, equals('สมศรี'));

          // Search by full name with title or space "นาง สมศรี มีสุข"
          final searchFullName = await repository.getPatients(
            searchQuery: 'สมศรี มีสุข',
          );
          expect(searchFullName.length, equals(1));
          expect(searchFullName.first.patientId, equals('P003'));
        },
      );

      test(
        'Search with special SQL characters (% _ \' ") does not crash or inject',
        () async {
          final dangerousQueries = [
            '%',
            '_',
            "'",
            "''",
            '"',
            r'\',
            "'; DROP TABLE patients; --",
            "%' OR '1'='1",
            '   ',
          ];

          for (final q in dangerousQueries) {
            final res = await repository.getPatients(searchQuery: q);
            expect(res, isA<List<Patient>>());
          }

          // Verify table was not dropped
          final all = await repository.getPatients();
          expect(all.length, greaterThanOrEqualTo(5));
        },
      );

      test(
        'Combination of villageId and searchQuery filters correctly',
        () async {
          // P001 (สมชาย) is in V001
          final matchBoth = await repository.getPatients(
            villageId: 'V001',
            searchQuery: 'สมชาย',
          );
          expect(matchBoth.length, equals(1));
          expect(matchBoth.first.patientId, equals('P001'));

          // Search for สมชาย in V002 where he is not registered
          final matchNone = await repository.getPatients(
            villageId: 'V002',
            searchQuery: 'สมชาย',
          );
          expect(matchNone, isEmpty);
        },
      );
    });

    group('3. VHV CRUD & Edge Cases', () {
      test(
        'addVhv with auto-generated ID sequence and update validation',
        () async {
          final vhv = VHV(
            vhvId: '',
            vhvCitizenId: '1122334455667',
            vhvTitle: 'นาย',
            vhvFname: 'สมบัติ',
            vhvLname: 'สุขใจ',
            vhvMobile: '0898887777',
            vhvEmail: 'sombat@example.com',
            vhvPassword: 'pass',
            vhvBirthDate: DateTime(1980, 5, 5),
            vhvGender: 'ชาย',
            vhvAddress: '123 Village 1',
            villageId: 'V001',
          );

          final created = await repository.addVhv(vhv);
          expect(created.vhvId, startsWith('VHV'));

          final fetched = await repository.getVhvById(created.vhvId);
          expect(fetched, isNotNull);
          expect(fetched!.vhvFname, equals('สมบัติ'));

          // Update VHV
          final modified = fetched.copyWith(vhvMobile: '0812340000');
          final updated = await repository.updateVhv(modified);
          expect(updated.vhvMobile, equals('0812340000'));

          // Update non-existing VHV throws Exception
          final ghostVhv = modified.copyWith(vhvId: 'VHV_GHOST_999');
          expect(
            () => repository.updateVhv(ghostVhv),
            throwsA(isA<Exception>()),
          );
        },
      );

      test(
        'VHV login supports citizenId, mobile number, or vhvId with trimming',
        () async {
          // Login by VHV ID
          final byId = await repository.login(
            role: UserRole.vhv,
            identifier: '  VHV001  ',
            password: 'password123',
          );
          expect((byId as VHV).vhvId, equals('VHV001'));

          // Login by mobile
          final byMobile = await repository.login(
            role: UserRole.vhv,
            identifier: '0800000001',
            password: 'password123',
          );
          expect((byMobile as VHV).vhvId, equals('VHV001'));

          // Login by citizen ID
          final byCitizen = await repository.login(
            role: UserRole.vhv,
            identifier: '1111111111111',
            password: 'password123',
          );
          expect((byCitizen as VHV).vhvId, equals('VHV001'));
        },
      );
    });

    group('4. Screening Persistence, Cascade, & Review Updates', () {
      test(
        'saveScreening with float biometrics, histories, and results',
        () async {
          final screening = Screening(
            screenId: '',
            patientId: 'P002',
            vhvId: 'VHV001',
            screeningDate: DateTime(2026, 3, 1, 9, 30),
            ageAtScreening: 30,
            createdAt: DateTime(2026, 3, 1, 9, 30),
            reviewStatus: ReviewStatus.pending,
            weight: 72.5,
            height: 178.2,
            bmi: 22.83,
            waistCm: 81.5,
            sbp: 135.5,
            dbp: 88.0,
            pulse: 76.0,
            bloodSugar: 105.5,
            histories: [
              const ScreeningHistory(
                historyId: '',
                screeningId: '',
                questionId: 'Q001',
                questionText: 'ประวัติโรคประจำตัว',
                answerText: 'ไม่มี',
              ),
              const ScreeningHistory(
                historyId: '',
                screeningId: '',
                questionId: 'Q002',
                questionText: 'ประวัติแพ้ยา',
                answerText: 'แพ้เพนนิซิลิน',
              ),
            ],
            results: [
              const ScreeningResult(
                resultId: '',
                screeningId: '',
                diseaseName: 'โรคเบาหวาน',
                diseaseCode: 'DM',
                score: 0,
                riskLevel: RiskLevel.low,
                adviceText: 'สุขภาพปกติ',
                criteriaText: 'FBS < 100',
              ),
              const ScreeningResult(
                resultId: '',
                screeningId: '',
                diseaseName: 'โรคความดันโลหิตสูง',
                diseaseCode: 'HT',
                score: 1,
                riskLevel: RiskLevel.moderate,
                adviceText: 'เฝ้าระวังความดัน',
                criteriaText: 'SBP 130-139',
              ),
            ],
          );

          final saved = await repository.saveScreening(screening);
          expect(saved.screenId, startsWith('S'));

          final fetched = await repository.getScreeningById(saved.screenId);
          expect(fetched, isNotNull);
          expect(fetched!.weight, closeTo(72.5, 0.01));
          expect(fetched.height, closeTo(178.2, 0.01));
          expect(fetched.bmi, closeTo(22.83, 0.01));
          expect(fetched.waistCm, closeTo(81.5, 0.01));
          expect(fetched.sbp, closeTo(135.5, 0.01));
          expect(fetched.dbp, closeTo(88.0, 0.01));
          expect(fetched.pulse, closeTo(76.0, 0.01));
          expect(fetched.bloodSugar, closeTo(105.5, 0.01));

          expect(fetched.histories.length, equals(2));
          expect(fetched.histories[1].answerText, equals('แพ้เพนนิซิลิน'));

          expect(fetched.results.length, equals(2));
          expect(fetched.results[1].diseaseCode, equals('HT'));
          expect(fetched.results[1].riskLevel, equals(RiskLevel.moderate));
        },
      );

      test(
        'updateScreeningReview cleanly replaces results without orphans',
        () async {
          final screening = (await repository.getScreeningById('S001'))!;
          expect(screening.results.length, equals(4));

          final modifiedResults = [
            const ScreeningResult(
              resultId: 'R_CUSTOM_1',
              screeningId: 'S001',
              diseaseName: 'โรคเบาหวาน',
              diseaseCode: 'DM',
              score: 3,
              riskLevel: RiskLevel.high,
              adviceText: 'พบแพทย์ด่วนเพื่อตรวจซ้ำ',
              criteriaText: 'FBS >= 126',
            ),
            const ScreeningResult(
              resultId: 'R_CUSTOM_2',
              screeningId: 'S001',
              diseaseName: 'โรคไตเรื้อรัง',
              diseaseCode: 'CKD',
              score: 2,
              riskLevel: RiskLevel.moderate,
              adviceText: 'ตรวจค่าไต',
              criteriaText: 'eGFR 60-89',
            ),
          ];

          final updated = await repository.updateScreeningReview(
            screeningId: 'S001',
            status: ReviewStatus.approved,
            nurseId: 'NUR001',
            updatedResults: modifiedResults,
          );

          expect(updated.reviewStatus, equals(ReviewStatus.approved));
          expect(updated.reviewedByNurseId, equals('NUR001'));
          expect(updated.results.length, equals(2));
          expect(updated.results.first.diseaseCode, equals('DM'));
          expect(updated.results.first.riskLevel, equals(RiskLevel.high));

          // Direct DB verification that old results (4) were replaced by (2)
          final dbResults = await (db.select(
            db.screeningResultsTable,
          )..where((t) => t.screeningId.equals('S001'))).get();
          expect(dbResults.length, equals(2));
        },
      );

      test(
        'updateScreeningReview throws Exception for non-existent screening',
        () async {
          expect(
            () => repository.updateScreeningReview(
              screeningId: 'S_NON_EXISTENT',
              status: ReviewStatus.approved,
              nurseId: 'NUR001',
            ),
            throwsA(isA<Exception>()),
          );
        },
      );

      test(
        'getAllScreenings with village filter handles edge scenarios',
        () async {
          // Village V001 has patients P001..P006, P001 has S001 and S002
          final v001Screenings = await repository.getAllScreenings(
            villageId: 'V001',
          );
          expect(v001Screenings.length, equals(2));

          // Village V002 has no patients yet -> should return empty list
          final v002Screenings = await repository.getAllScreenings(
            villageId: 'V002',
          );
          expect(v002Screenings, isEmpty);

          // Add a patient to V002 but with no screenings -> should return empty list
          final pV002 = await repository.addPatient(
            Patient(
              patientId: '',
              patientCitizenId: '7777777777777',
              patientTitle: 'นาย',
              patientFname: 'คนใหม่',
              patientLname: 'หมู่สอง',
              patientGender: 'ชาย',
              patientBirthDate: DateTime(1990, 1, 1),
              patientAddress: 'หมู่ 2',
              villageId: 'V002',
            ),
          );
          expect(pV002.patientId, isNotEmpty);

          final v002ScreeningsAfterPatient = await repository.getAllScreenings(
            villageId: 'V002',
          );
          expect(v002ScreeningsAfterPatient, isEmpty);

          // Now save a screening for this patient in V002
          await repository.saveScreening(
            Screening(
              screenId: '',
              patientId: pV002.patientId,
              vhvId: 'VHV001',
              screeningDate: DateTime.now(),
              ageAtScreening: 36,
              createdAt: DateTime.now(),
              reviewStatus: ReviewStatus.pending,
              weight: 60,
              height: 170,
              bmi: 20.7,
              waistCm: 75,
              sbp: 120,
              dbp: 80,
              pulse: 70,
              bloodSugar: 95,
              histories: [],
              results: [],
            ),
          );

          final v002ScreeningsWithData = await repository.getAllScreenings(
            villageId: 'V002',
          );
          expect(v002ScreeningsWithData.length, equals(1));
          expect(
            v002ScreeningsWithData.first.patientId,
            equals(pV002.patientId),
          );
        },
      );
    });

    group('5. Concurrency & Stress Tests', () {
      test(
        'Concurrent operations (reads, writes, queries) execute cleanly',
        () async {
          final futures = <Future>[];

          // 10 concurrent patient inserts
          for (var i = 0; i < 10; i++) {
            futures.add(
              repository.addPatient(
                Patient(
                  patientId: 'P_CONCURRENT_$i',
                  patientCitizenId: '80000000000$i',
                  patientTitle: 'นาย',
                  patientFname: 'Concurrent_$i',
                  patientLname: 'User',
                  patientGender: 'ชาย',
                  patientBirthDate: DateTime(1990, 1, 1),
                  patientAddress: 'Address',
                  villageId: 'V001',
                ),
              ),
            );
          }

          // 10 concurrent reads
          for (var i = 0; i < 10; i++) {
            futures.add(repository.getPatients(searchQuery: 'สมชาย'));
            futures.add(repository.getAllScreenings(villageId: 'V001'));
            futures.add(repository.getVillages());
          }

          await Future.wait(futures);

          final all = await repository.getPatients();
          expect(all.length, greaterThanOrEqualTo(16));
        },
      );
    });

    group('6. Multi-Session Persistence Simulation (Close & Reopen File DB)', () {
      test(
        'Data mutations persist across database restarts without reseeding wipeout',
        () async {
          final tempDir = Directory.systemTemp.createTempSync('drift_test_');
          final dbFile = File('${tempDir.path}/test_ncd.sqlite');

          try {
            // Session 1: Open DB, seed baseline, insert a custom patient and screening
            final firstDb = AppDatabase(
              citizenIds: testCitizenIds(),
              executor: NativeDatabase(dbFile),
            );
            final firstRepo = DriftNcdRepository(firstDb);

            final initialVillages = await firstRepo.getVillages();
            expect(initialVillages.length, equals(5));

            final newPatient = await firstRepo.addPatient(
              Patient(
                patientId: 'P_PERSIST_1',
                patientCitizenId: '9898989898989',
                patientTitle: 'นาย',
                patientFname: 'คงกระพัน',
                patientLname: 'ชาตรี',
                patientGender: 'ชาย',
                patientBirthDate: DateTime(1970, 1, 1),
                patientAddress: '111/1 ท่าตอน',
                villageId: 'V001',
              ),
            );

            await firstRepo.saveScreening(
              Screening(
                screenId: 'S_PERSIST_1',
                patientId: newPatient.patientId,
                vhvId: 'VHV001',
                screeningDate: DateTime(2026, 3, 15),
                ageAtScreening: 56,
                createdAt: DateTime(2026, 3, 15),
                reviewStatus: ReviewStatus.pending,
                weight: 70,
                height: 170,
                bmi: 24.2,
                waistCm: 80,
                sbp: 130,
                dbp: 85,
                pulse: 75,
                bloodSugar: 110,
                histories: [],
                results: [],
              ),
            );

            // Close first DB
            await firstDb.close();

            // Session 2: Reopen DB file from disk
            final secondDb = AppDatabase(
              citizenIds: testCitizenIds(),
              executor: NativeDatabase(dbFile),
            );
            final secondRepo = DriftNcdRepository(secondDb);

            // Verify seeded data AND our newly created patient + screening persist intact
            final persistedVillages = await secondRepo.getVillages();
            expect(persistedVillages.length, equals(5));

            final fetchedPatient = await secondRepo.getPatientById(
              'P_PERSIST_1',
            );
            expect(fetchedPatient, isNotNull);
            expect(fetchedPatient!.patientFname, equals('คงกระพัน'));

            final fetchedScreening = await secondRepo.getScreeningById(
              'S_PERSIST_1',
            );
            expect(fetchedScreening, isNotNull);
            expect(fetchedScreening!.patientId, equals('P_PERSIST_1'));

            await secondDb.close();
          } finally {
            if (tempDir.existsSync()) {
              tempDir.deleteSync(recursive: true);
            }
          }
        },
      );
    });

    group('7. Service Locator (GetIt) Wiring Verification', () {
      test(
        'locator resolves DriftNcdRepository as NcdRepositoryInterface',
        () async {
          await locator.reset();
          locator.registerLazySingleton<AppDatabase>(
            () => AppDatabase(
              citizenIds: testCitizenIds(),
              executor: NativeDatabase.memory(),
            ),
          );
          locator.registerLazySingleton<NcdRepositoryInterface>(
            () => DriftNcdRepository(locator<AppDatabase>()),
          );

          expect(locator.isRegistered<AppDatabase>(), isTrue);
          expect(locator.isRegistered<NcdRepositoryInterface>(), isTrue);

          final repo = locator<NcdRepositoryInterface>();
          expect(repo, isA<DriftNcdRepository>());

          final villages = await repo.getVillages();
          expect(villages, isNotEmpty);
        },
      );
    });
  });
}
