import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/data/repositories/drift_ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/clinical_triage_service.dart';
import 'package:ncd_screening_mobile/domain/services/health_data_export_service.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_lifestyle_advisor.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_risk_calculator.dart';
import 'package:ncd_screening_mobile/domain/services/pdf_report_service.dart';
import 'package:ncd_screening_mobile/feature/patient/widgets/screening_detail/screening_vitals_card.dart';
import 'package:pdf/widgets.dart' as pw;

List<ScreeningResult> _evaluate({
  double? sugar,
  bool personalNcd = false,
  String? detail,
  bool familyNcd = false,
}) =>
    NcdRiskCalculator.evaluateRisk(
      screeningId: 'S1',
      weight: 60,
      height: 170,
      bmi: 20.8,
      waistCm: 75,
      sbp: 118,
      dbp: 76,
      pulse: 72,
      bloodSugar: sugar,
      gender: 'ชาย',
      hasPersonalNcd: personalNcd,
      personalNcdDetail: detail,
      hasDirectFamilyNcd: familyNcd,
    );

Screening _screening({double? sugar, String id = 'S1'}) => Screening(
      screenId: id,
      patientId: 'P001',
      vhvId: 'VHV001',
      screeningDate: DateTime(2026, 11, 12),
      ageAtScreening: 46,
      createdAt: DateTime(2026, 11, 12),
      reviewStatus: ReviewStatus.pending,
      weight: 60,
      height: 170,
      bmi: 20.8,
      waistCm: 75,
      sbp: 118,
      dbp: 76,
      pulse: 72,
      bloodSugar: sugar,
      results: _evaluate(sugar: sugar),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('risk calculator without a blood sugar reading', () {
    test('diabetes is reported as incomplete, not as low risk', () {
      final dm = _evaluate(sugar: null)
          .firstWhere((r) => r.diseaseCode == 'DIABETES');
      expect(dm.isIncomplete, isTrue);
      expect(dm.criteriaText, contains('ข้อมูลไม่ครบ'));
      expect(dm.adviceText, contains('ตรวจ'));
    });

    test('score 0 on a non-diabetes result (no CVD risk factors) is not "incomplete"',
        () {
      const cvd = ScreeningResult(
        resultId: 'r',
        screeningId: 's',
        diseaseName: 'โรคหลอดเลือดหัวใจ',
        diseaseCode: 'CVD',
        score: 0,
        riskLevel: RiskLevel.low,
        adviceText: '',
      );
      expect(cvd.isIncomplete, isFalse);
    });

    test('a measured value is never incomplete', () {
      final dm = _evaluate(sugar: 90)
          .firstWhere((r) => r.diseaseCode == 'DIABETES');
      expect(dm.isIncomplete, isFalse);
      expect(dm.riskLevel, RiskLevel.low);
    });

    test('a known diabetes history still produces a high-risk result', () {
      final dm = _evaluate(
        sugar: null,
        personalNcd: true,
        detail: 'โรคเบาหวาน',
      ).firstWhere((r) => r.diseaseCode == 'DIABETES');
      expect(dm.riskLevel, RiskLevel.high);
      expect(dm.isIncomplete, isFalse);
      expect(dm.criteriaText, contains('ประวัติ'));
    });

    test('the other three diseases are unaffected by a missing sugar value', () {
      final withSugar = _evaluate(sugar: 90);
      final without = _evaluate(sugar: null);
      for (final code in ['HYPERTENSION', 'METABOLIC_OBESITY', 'CVD']) {
        expect(
          without.firstWhere((r) => r.diseaseCode == code).riskLevel,
          withSugar.firstWhere((r) => r.diseaseCode == code).riskLevel,
          reason: code,
        );
      }
    });
  });

  group('model', () {
    test('toMap / fromMap keep a null blood sugar null (not 0)', () {
      final restored = Screening.fromMap(_screening(sugar: null).toMap());
      expect(restored.bloodSugar, isNull);
      final withValue = Screening.fromMap(_screening(sugar: 101.5).toMap());
      expect(withValue.bloodSugar, 101.5);
    });
  });

  group('persistence', () {
    test('a screening without blood sugar round-trips through Drift', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = DriftNcdRepository(db);

      final saved = await repo.saveScreening(_screening(sugar: null, id: ''));
      final loaded = (await repo.getScreeningById(saved.screenId))!;
      expect(loaded.bloodSugar, isNull);
      expect(
        loaded.results.firstWhere((r) => r.diseaseCode == 'DIABETES').isIncomplete,
        isTrue,
      );
    });

    test('upgrading v4 -> v5 keeps existing screenings and allows null sugar',
        () async {
      final dir = Directory.systemTemp.createTempSync('ncd_v5_migration');
      final file = File('${dir.path}/app.sqlite');
      addTearDown(() {
        try {
          dir.deleteSync(recursive: true);
        } on FileSystemException {
          // Windows may still hold the handle briefly; the temp dir is harmless.
        }
      });

      // Build a current DB, then rewrite `screenings` the way v4 had it
      // (blood_sugar NOT NULL) and rewind the version.
      final first = AppDatabase(NativeDatabase(file));
      await first.customSelect('SELECT 1').get();
      await first.customStatement('DROP TABLE screenings');
      await first.customStatement('''
        CREATE TABLE screenings (
          screen_id TEXT NOT NULL PRIMARY KEY,
          patient_id TEXT NOT NULL,
          vhv_id TEXT NOT NULL,
          screening_date INTEGER NOT NULL,
          age_at_screening INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          review_status TEXT NOT NULL DEFAULT 'PENDING',
          reviewed_by_nurse_id TEXT NULL,
          reviewed_at INTEGER NULL,
          weight REAL NOT NULL,
          height REAL NOT NULL,
          bmi REAL NOT NULL,
          waist_cm REAL NOT NULL,
          sbp REAL NOT NULL,
          dbp REAL NOT NULL,
          pulse REAL NOT NULL,
          blood_sugar REAL NOT NULL
        )''');
      await first.customStatement('''
        INSERT INTO screenings VALUES
          ('OLD1','P001','VHV001',1700000000,46,1700000000,'PENDING',NULL,NULL,
           60,170,20.8,75,118,76,72,99.0)''');
      await first.customStatement('PRAGMA user_version = 4');
      await first.close();

      final upgraded = AppDatabase(NativeDatabase(file));
      addTearDown(upgraded.close);

      final repo = DriftNcdRepository(upgraded);
      final old = await repo.getScreeningById('OLD1');
      expect(old, isNotNull);
      expect(old!.bloodSugar, 99.0);

      final fresh = await repo.saveScreening(_screening(sugar: null, id: ''));
      expect((await repo.getScreeningById(fresh.screenId))!.bloodSugar, isNull);
    });
  });

  group('consumers tolerate a missing value', () {
    test('triage does not treat a missing value as severe hyperglycaemia', () {
      final s = _screening(sugar: null);
      final assessment = ClinicalTriageService.assess(
        screening: s,
        results: s.results,
      );
      expect(assessment.urgencyLevel, isNot(TriageUrgencyLevel.emergency));
    });

    test('lifestyle advice is generated without crashing', () {
      final s = _screening(sugar: null);
      final advice = NcdLifestyleAdvisor.generateAdviceList(
        screening: s,
        results: s.results,
      );
      expect(advice, isNotEmpty);
    });

    test('CSV export leaves the cell empty, not 0.0', () {
      final csv = HealthDataExportService.generateCsv(
        patients: [
          Patient(
            patientId: 'P001',
            patientCitizenId: '1234567890121',
            patientTitle: 'นาย',
            patientFname: 'สมชาย',
            patientLname: 'ใจดี',
            patientGender: 'ชาย',
            patientBirthDate: DateTime(1980, 2, 1),
            patientAddress: '1 หมู่ 1',
            villageId: 'V001',
          ),
        ],
        screenings: [_screening(sugar: null)],
        villages: const [
          Village(
            villageId: 'V001',
            villageName: 'บ้านท่าตอน',
            villageNumber: '1',
          ),
        ],
        mode: ExportPrivacyMode.anonymized,
      );
      final rows = csv.trim().split(RegExp(r'\r?\n'));
      expect(rows.length, 2, reason: 'header + one data row');
      final column = rows.first.split(',').indexOf('น้ำตาลในเลือด_mgdL');
      expect(column, greaterThan(0));
      expect(rows[1].split(',')[column], isEmpty);
    });

    test('PDF report builds without a blood sugar value', () async {
      final service = PdfReportService(
        fontRegularLoader: () async => pw.Font.helvetica(),
        fontBoldLoader: () async => pw.Font.helveticaBold(),
      );
      final bytes = await service.generateScreeningReport(
        patient: Patient(
          patientId: 'P001',
          patientCitizenId: '1234567890121',
          patientTitle: 'นาย',
          patientFname: 'สมชาย',
          patientLname: 'ใจดี',
          patientGender: 'ชาย',
          patientBirthDate: DateTime(1980, 2, 1),
          patientAddress: '1 หมู่ 1',
          villageId: 'V001',
        ),
        screening: _screening(sugar: null),
      );
      expect(bytes, isNotEmpty);
    });

    testWidgets('vitals card says the test was not done', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScreeningVitalsCard(screening: _screening(sugar: null)),
          ),
        ),
      );
      expect(find.text('ไม่ได้ตรวจ'), findsOneWidget);
      expect(find.textContaining('mg/dL'), findsNothing);
    });
  });
}
