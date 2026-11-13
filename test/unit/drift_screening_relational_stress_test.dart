import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/data/repositories/drift_ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_risk_calculator.dart';

void main() {
  late AppDatabase db;
  late DriftNcdRepository repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = DriftNcdRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Empirical Challenge: Screening Persistence & Relational Integrity', () {
    test(
        'saveScreening inserts into screenings, screening_histories, and screening_results tables',
        () async {
      // 1. Check initial row counts in underlying SQLite tables
      final initialScreeningRows = await db.select(db.screeningsTable).get();
      final initialHistoryRows =
          await db.select(db.screeningHistoriesTable).get();
      final initialResultRows =
          await db.select(db.screeningResultsTable).get();

      expect(initialScreeningRows.length, equals(2));
      expect(initialHistoryRows.length, equals(8));
      expect(initialResultRows.length, equals(8));

      // 2. Construct screening with 4 histories and 4 results
      final histories = [
        const ScreeningHistory(
          historyId: '',
          screeningId: '',
          questionId: 'Q001',
          questionText: '1) ประวัติป่วย/พบแพทย์ด้วยโรค NCDs',
          answerText: 'มี (ความดันโลหิตสูง)',
        ),
        const ScreeningHistory(
          historyId: '',
          screeningId: '',
          questionId: 'Q002',
          questionText: '2) ประวัติแพ้ยา',
          answerText: 'ไม่มี',
        ),
        const ScreeningHistory(
          historyId: '',
          screeningId: '',
          questionId: 'Q003',
          questionText: '3) ประวัติแพ้อาหาร',
          answerText: 'ไม่มี',
        ),
        const ScreeningHistory(
          historyId: '',
          screeningId: '',
          questionId: 'Q004',
          questionText: '4) ญาติตรงสาย ป่วยเป็นโรค NCDs',
          answerText: 'มี (เบาหวาน)',
        ),
      ];

      final results = NcdRiskCalculator.evaluateRisk(
        screeningId: '',
        weight: 78.5,
        height: 168.0,
        bmi: 27.81,
        waistCm: 92.0,
        sbp: 145.0,
        dbp: 95.0,
        pulse: 82.0,
        bloodSugar: 135.0,
        gender: 'หญิง',
        hasPersonalNcd: true,
        personalNcdDetail: 'ความดันโลหิตสูง',
        hasDirectFamilyNcd: true,
      );

      final screening = Screening(
        screenId: '',
        patientId: 'P002',
        vhvId: 'VHV002',
        screeningDate: DateTime(2026, 3, 1, 9, 30),
        ageAtScreening: 30,
        createdAt: DateTime(2026, 3, 1, 9, 30),
        reviewStatus: ReviewStatus.pending,
        weight: 78.5,
        height: 168.0,
        bmi: 27.81,
        waistCm: 92.0,
        sbp: 145.0,
        dbp: 95.0,
        pulse: 82.0,
        bloodSugar: 135.0,
        histories: histories,
        results: results,
      );

      final saved = await repository.saveScreening(screening);
      expect(saved.screenId, isNotEmpty);
      final assignedId = saved.screenId;

      // 3. Verify SQLite table rows directly
      final directScreening = await (db.select(db.screeningsTable)
            ..where((t) => t.screenId.equals(assignedId)))
          .getSingleOrNull();
      expect(directScreening, isNotNull);
      expect(directScreening!.patientId, equals('P002'));
      expect(directScreening.vhvId, equals('VHV002'));
      expect(directScreening.weight, equals(78.5));
      expect(directScreening.height, equals(168.0));
      expect(directScreening.bmi, equals(27.81));
      expect(directScreening.waistCm, equals(92.0));
      expect(directScreening.sbp, equals(145.0));
      expect(directScreening.dbp, equals(95.0));
      expect(directScreening.pulse, equals(82.0));
      expect(directScreening.bloodSugar, equals(135.0));
      expect(directScreening.reviewStatus, equals('PENDING'));

      // 4. Verify SQLite histories table rows
      final directHistories = await (db.select(db.screeningHistoriesTable)
            ..where((t) => t.screeningId.equals(assignedId)))
          .get();
      expect(directHistories.length, equals(4));
      expect(directHistories.every((h) => h.screeningId == assignedId), isTrue);
      expect(directHistories.map((h) => h.questionId),
          containsAll(['Q001', 'Q002', 'Q003', 'Q004']));

      // 5. Verify SQLite results table rows
      final directResults = await (db.select(db.screeningResultsTable)
            ..where((t) => t.screeningId.equals(assignedId)))
          .get();
      expect(directResults.length, equals(4));
      expect(directResults.every((r) => r.screeningId == assignedId), isTrue);
      expect(directResults.map((r) => r.diseaseCode),
          containsAll(['DIABETES', 'HYPERTENSION', 'METABOLIC_OBESITY', 'CVD']));

      // 6. Verify total row counts increased exactly as expected
      final afterScreenings = await db.select(db.screeningsTable).get();
      final afterHistories = await db.select(db.screeningHistoriesTable).get();
      final afterResults = await db.select(db.screeningResultsTable).get();

      expect(afterScreenings.length, equals(3));
      expect(afterHistories.length, equals(12));
      expect(afterResults.length, equals(12));

      // 7. Verify roundtrip through repository mapper
      final fetched = await repository.getScreeningById(assignedId);
      expect(fetched, isNotNull);
      expect(fetched!.screenId, equals(assignedId));
      expect(fetched.histories.length, equals(4));
      expect(fetched.results.length, equals(4));
    });

    test('saveScreening handles empty histories and empty results gracefully',
        () async {
      final minimalScreening = Screening(
        screenId: 'S_MINIMAL',
        patientId: 'P001',
        vhvId: 'VHV001',
        screeningDate: DateTime(2026, 3, 2),
        ageAtScreening: 46,
        createdAt: DateTime(2026, 3, 2),
        reviewStatus: ReviewStatus.pending,
        weight: 60.0,
        height: 170.0,
        bmi: 20.76,
        waistCm: 75.0,
        sbp: 120.0,
        dbp: 80.0,
        pulse: 72.0,
        bloodSugar: 90.0,
        histories: const [],
        results: const [],
      );

      final saved = await repository.saveScreening(minimalScreening);
      expect(saved.screenId, equals('S_MINIMAL'));

      final fetched = await repository.getScreeningById('S_MINIMAL');
      expect(fetched, isNotNull);
      expect(fetched!.histories, isEmpty);
      expect(fetched.results, isEmpty);
    });

    test('saveScreening with pre-specified screenId and item IDs preserves them',
        () async {
      final explicitScreening = Screening(
        screenId: 'S_CUSTOM_999',
        patientId: 'P001',
        vhvId: 'VHV001',
        screeningDate: DateTime(2026, 3, 2, 11, 0),
        ageAtScreening: 50,
        createdAt: DateTime(2026, 3, 2, 11, 0),
        reviewStatus: ReviewStatus.pending,
        weight: 62.0,
        height: 165.0,
        bmi: 22.77,
        waistCm: 76.0,
        sbp: 115.0,
        dbp: 75.0,
        pulse: 70.0,
        bloodSugar: 95.0,
        histories: const [
          ScreeningHistory(
            historyId: 'H_CUSTOM_1',
            screeningId: 'S_CUSTOM_999',
            questionId: 'Q001',
            questionText: 'Test question',
            answerText: 'Test answer',
          ),
        ],
        results: const [
          ScreeningResult(
            resultId: 'R_CUSTOM_1',
            screeningId: 'S_CUSTOM_999',
            diseaseName: 'Test Disease',
            diseaseCode: 'TEST',
            score: 1,
            riskLevel: RiskLevel.low,
            adviceText: 'Test Advice',
            criteriaText: 'Test Criteria',
          ),
        ],
      );

      final saved = await repository.saveScreening(explicitScreening);
      expect(saved.screenId, equals('S_CUSTOM_999'));

      final fetched = await repository.getScreeningById('S_CUSTOM_999');
      expect(fetched, isNotNull);
      expect(fetched!.histories.first.historyId, equals('H_CUSTOM_1'));
      expect(fetched.results.first.resultId, equals('R_CUSTOM_1'));
    });

    test('rapid insertions generate unique IDs without collisions',
        () async {
      final ids = <String>[];
      for (var i = 0; i < 10; i++) {
        final sc = Screening(
          screenId: '',
          patientId: 'P001',
          vhvId: 'VHV001',
          screeningDate: DateTime(2026, 3, 10, i),
          ageAtScreening: 46,
          createdAt: DateTime(2026, 3, 10, i),
          reviewStatus: ReviewStatus.pending,
          weight: 60.0 + i,
          height: 170.0,
          bmi: 20.8,
          waistCm: 75.0,
          sbp: 120.0,
          dbp: 80.0,
          pulse: 70.0,
          bloodSugar: 90.0 + i,
        );
        final saved = await repository.saveScreening(sc);
        ids.add(saved.screenId);
      }

      // Check all 10 generated IDs are unique
      expect(ids.toSet().length, equals(10));
      expect(ids, everyElement(isNotEmpty));
    });

    test('extreme biometric values and floating point precision are preserved',
        () async {
      final extremeScreening = Screening(
        screenId: 'S_EXTREME',
        patientId: 'P004',
        vhvId: 'VHV001',
        screeningDate: DateTime(2026, 4, 1),
        ageAtScreening: 60,
        createdAt: DateTime(2026, 4, 1),
        reviewStatus: ReviewStatus.pending,
        weight: 145.75,
        height: 195.5,
        bmi: 38.13,
        waistCm: 132.8,
        sbp: 210.0,
        dbp: 130.0,
        pulse: 115.0,
        bloodSugar: 380.5,
      );

      await repository.saveScreening(extremeScreening);
      final fetched = await repository.getScreeningById('S_EXTREME');

      expect(fetched, isNotNull);
      expect(fetched!.weight, equals(145.75));
      expect(fetched.height, equals(195.5));
      expect(fetched.bmi, equals(38.13));
      expect(fetched.waistCm, equals(132.8));
      expect(fetched.sbp, equals(210.0));
      expect(fetched.dbp, equals(130.0));
      expect(fetched.pulse, equals(115.0));
      expect(fetched.bloodSugar, equals(380.5));
    });
  });

  group('Empirical Challenge: Nurse Review Updates & Results Replacement', () {
    test(
        'updateScreeningReview replaces results atomically and updates review metadata',
        () async {
      // S001 initially has 4 results
      final beforeResults = await (db.select(db.screeningResultsTable)
            ..where((t) => t.screeningId.equals('S001')))
          .get();
      expect(beforeResults.length, equals(4));

      // Nurse provides 2 modified results with specific clinical notes
      final modifiedResults = [
        const ScreeningResult(
          resultId: 'R_CUSTOM_1',
          screeningId: 'S001',
          diseaseName: 'โรคเบาหวาน (DM)',
          diseaseCode: 'DIABETES',
          score: 8,
          riskLevel: RiskLevel.high,
          adviceText: 'ส่งต่อพบแพทย์เพื่อตรวจเลือดซ้ำ FBS >= 126',
          criteriaText: 'พยาบาลประเมินซ้ำ',
        ),
        const ScreeningResult(
          resultId: 'R_CUSTOM_2',
          screeningId: 'S001',
          diseaseName: 'โรคความดันโลหิตสูง (HT)',
          diseaseCode: 'HYPERTENSION',
          score: 2,
          riskLevel: RiskLevel.moderate,
          adviceText: 'นัดติดตามความดันโลหิต 2 สัปดาห์',
          criteriaText: 'พยาบาลประเมินซ้ำ',
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
      expect(updated.reviewedAt, isNotNull);
      expect(updated.results.length, equals(2));
      expect(updated.results.first.adviceText,
          equals('ส่งต่อพบแพทย์เพื่อตรวจเลือดซ้ำ FBS >= 126'));

      // Verify SQLite table directly: old 4 rows replaced with exactly 2 new rows
      final directResults = await (db.select(db.screeningResultsTable)
            ..where((t) => t.screeningId.equals('S001')))
          .get();
      expect(directResults.length, equals(2));
      expect(directResults.map((r) => r.resultId),
          containsAll(['R_CUSTOM_1', 'R_CUSTOM_2']));
      expect(directResults.first.riskLevel, equals('high'));
    });

    test(
        'updateScreeningReview without updatedResults preserves existing results',
        () async {
      // S002 initially has 4 results
      final beforeResults = await (db.select(db.screeningResultsTable)
            ..where((t) => t.screeningId.equals('S002')))
          .get();
      expect(beforeResults.length, equals(4));

      // Approve review without modifying results
      final updated = await repository.updateScreeningReview(
        screeningId: 'S002',
        status: ReviewStatus.approved,
        nurseId: 'NUR001',
        updatedResults: null,
      );

      expect(updated.reviewStatus, equals(ReviewStatus.approved));
      expect(updated.reviewedByNurseId, equals('NUR001'));
      expect(updated.results.length, equals(4));

      // Verify SQLite table still contains all 4 original results
      final afterResults = await (db.select(db.screeningResultsTable)
            ..where((t) => t.screeningId.equals('S002')))
          .get();
      expect(afterResults.length, equals(4));
    });

    test('consecutive updates to review results work idempotently', () async {
      // First update
      await repository.updateScreeningReview(
        screeningId: 'S001',
        status: ReviewStatus.approved,
        nurseId: 'NUR001',
        updatedResults: [
          const ScreeningResult(
            resultId: 'R_REV_1',
            screeningId: 'S001',
            diseaseName: 'DM',
            diseaseCode: 'DIABETES',
            score: 5,
            riskLevel: RiskLevel.high,
            adviceText: 'First revision',
            criteriaText: 'Rev 1',
          ),
        ],
      );

      // Second update: Nurse amends advice
      await repository.updateScreeningReview(
        screeningId: 'S001',
        status: ReviewStatus.approved,
        nurseId: 'NUR001',
        updatedResults: [
          const ScreeningResult(
            resultId: 'R_REV_2',
            screeningId: 'S001',
            diseaseName: 'DM',
            diseaseCode: 'DIABETES',
            score: 6,
            riskLevel: RiskLevel.high,
            adviceText: 'Second revision amended',
            criteriaText: 'Rev 2',
          ),
        ],
      );

      final fetched = await repository.getScreeningById('S001');
      expect(fetched!.results.length, equals(1));
      expect(fetched.results.first.resultId, equals('R_REV_2'));
      expect(fetched.results.first.adviceText, equals('Second revision amended'));

      final directRows = await (db.select(db.screeningResultsTable)
            ..where((t) => t.screeningId.equals('S001')))
          .get();
      expect(directRows.length, equals(1));
      expect(directRows.first.resultId, equals('R_REV_2'));
    });

    test('updateScreeningReview throws Exception for non-existent screeningId',
        () async {
      expect(
        () => repository.updateScreeningReview(
          screeningId: 'S_NONEXISTENT',
          status: ReviewStatus.approved,
          nurseId: 'NUR001',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Empirical Challenge: getAllScreenings Queries & Village Filtering',
      () {
    test(
        'getAllScreenings handles multiple villages, patients with 0 screenings, and dynamic patient relocation',
        () async {
      // 1. Initial State:
      // Seeded patients P001..P006 all belong to V001.
      // S001, S002 belong to P001 (V001).
      final allInitial = await repository.getAllScreenings();
      expect(allInitial.length, equals(2));

      final v001Initial = await repository.getAllScreenings(villageId: 'V001');
      expect(v001Initial.length, equals(2));

      final v002Initial = await repository.getAllScreenings(villageId: 'V002');
      expect(v002Initial, isEmpty);

      // 2. Add Patient P010 to Village V002 and add 2 screenings
      final patientV002 = await repository.addPatient(Patient(
        patientId: 'P010',
        patientCitizenId: '1100223344556',
        patientTitle: 'นาย',
        patientFname: 'จันทร์',
        patientLname: 'ดอยหมอก',
        patientGender: 'ชาย',
        patientBirthDate: DateTime(1985, 5, 12),
        patientAddress: '10 หมู่ 2',
        patientMobile: '0812340002',
        villageId: 'V002',
      ));

      await repository.saveScreening(Screening(
        screenId: 'S010_1',
        patientId: patientV002.patientId,
        vhvId: 'VHV002',
        screeningDate: DateTime(2026, 1, 10),
        ageAtScreening: 40,
        createdAt: DateTime(2026, 1, 10),
        reviewStatus: ReviewStatus.pending,
        weight: 70,
        height: 170,
        bmi: 24.2,
        waistCm: 80,
        sbp: 120,
        dbp: 80,
        pulse: 70,
        bloodSugar: 95,
        histories: const [],
        results: const [],
      ));

      await repository.saveScreening(Screening(
        screenId: 'S010_2',
        patientId: patientV002.patientId,
        vhvId: 'VHV002',
        screeningDate: DateTime(2026, 2, 20),
        ageAtScreening: 40,
        createdAt: DateTime(2026, 2, 20),
        reviewStatus: ReviewStatus.approved,
        weight: 69,
        height: 170,
        bmi: 23.8,
        waistCm: 79,
        sbp: 118,
        dbp: 78,
        pulse: 68,
        bloodSugar: 92,
        histories: const [],
        results: const [],
      ));

      // 3. Add Patient P011 to Village V003 with ZERO screenings
      await repository.addPatient(Patient(
        patientId: 'P011',
        patientCitizenId: '1100223344557',
        patientTitle: 'นาง',
        patientFname: 'ดาว',
        patientLname: 'ห้วยปู',
        patientGender: 'หญิง',
        patientBirthDate: DateTime(1990, 8, 15),
        patientAddress: '22 หมู่ 3',
        patientMobile: '0812340003',
        villageId: 'V003',
      ));

      // 4. Test Queries across all scenarios:
      // (a) Unfiltered query retrieves all 4 screenings across all villages
      final allScreenings = await repository.getAllScreenings();
      expect(allScreenings.length, equals(4));
      expect(allScreenings.map((s) => s.screenId),
          containsAll(['S001', 'S002', 'S010_1', 'S010_2']));
      // Verifying descending date ordering
      for (var i = 0; i < allScreenings.length - 1; i++) {
        expect(
          allScreenings[i]
              .screeningDate
              .isBefore(allScreenings[i + 1].screeningDate),
          isFalse,
        );
      }

      // (b) Empty string villageId behaves like null (unfiltered)
      final emptyVillageScreenings =
          await repository.getAllScreenings(villageId: '');
      expect(emptyVillageScreenings.length, equals(4));

      // (c) V001 query returns only V001 screenings (S001, S002)
      final v001Screenings =
          await repository.getAllScreenings(villageId: 'V001');
      expect(v001Screenings.length, equals(2));
      expect(
          v001Screenings.map((s) => s.screenId), containsAll(['S001', 'S002']));

      // (d) V002 query returns only V002 screenings (S010_1, S010_2)
      final v002Screenings =
          await repository.getAllScreenings(villageId: 'V002');
      expect(v002Screenings.length, equals(2));
      expect(v002Screenings.map((s) => s.screenId),
          containsAll(['S010_1', 'S010_2']));

      // (e) V003 query: Village has a patient (P011) but 0 screenings -> returns empty list
      final v003Screenings =
          await repository.getAllScreenings(villageId: 'V003');
      expect(v003Screenings, isEmpty);

      // (f) V004 query: Village exists in DB but has 0 patients -> returns empty list
      final v004Screenings =
          await repository.getAllScreenings(villageId: 'V004');
      expect(v004Screenings, isEmpty);

      // (g) Non-existent village -> returns empty list
      final v999Screenings =
          await repository.getAllScreenings(villageId: 'V999');
      expect(v999Screenings, isEmpty);

      // 5. Dynamic Relocation Stress Test:
      // Move patient P010 from V002 to V001
      final updatedPatient = patientV002.copyWith(villageId: 'V001');
      await repository.updatePatient(updatedPatient);

      // Now V001 should have 4 screenings (S001, S002, S010_1, S010_2)
      final v001AfterRelocation =
          await repository.getAllScreenings(villageId: 'V001');
      expect(v001AfterRelocation.length, equals(4));

      // And V002 should have 0 screenings
      final v002AfterRelocation =
          await repository.getAllScreenings(villageId: 'V002');
      expect(v002AfterRelocation, isEmpty);
    });
  });
}
