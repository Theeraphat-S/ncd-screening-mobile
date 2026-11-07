import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_risk_calculator.dart';
import 'package:ncd_screening_mobile/domain/services/pdf_report_service.dart';
import 'package:ncd_screening_mobile/locator.dart';
import 'package:pdf/widgets.dart' as pw;
import '../support/memory_key_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PdfReportService pdfService;

  const sampleVillage = Village(
    villageId: 'VIL001',
    villageName: 'บ้านท่าตอนใต้',
    villageNumber: '1',
    subdistrictId: 'SD001',
    subdistrictName: 'ท่าตอน',
    districtName: 'แม่อาย',
    provinceName: 'เชียงใหม่',
  );

  final samplePatient = Patient(
    patientId: 'P001',
    patientCitizenId: '1509900123456',
    patientTitle: 'นาย',
    patientFname: 'สมชาย',
    patientLname: 'ใจดี',
    patientGender: 'ชาย',
    patientBirthDate: DateTime(1975, 5, 12),
    patientAddress: '123 หมู่ 1 ต.ท่าตอน',
    patientMobile: '0812345678',
    villageId: 'VIL001',
  );

  final sampleVhv = VHV(
    vhvId: 'VHV001',
    vhvCitizenId: '1509900987654',
    vhvTitle: 'นาง',
    vhvFname: 'สมศรี',
    vhvLname: 'รักสุข',
    vhvMobile: '0898765432',
    vhvEmail: 'somsri@example.com',
    vhvPassword: 'password123',
    vhvBirthDate: DateTime(1980, 3, 15),
    vhvGender: 'หญิง',
    vhvAddress: '45 หมู่ 1 ต.ท่าตอน',
    villageId: 'VIL001',
  );

  final sampleNurse = Nurse(
    nurseId: 'NUR001',
    nurseTitle: 'นางสาว',
    nurseFname: 'วิภาดา',
    nurseLname: 'สุขสมบูรณ์',
    nurseMobile: '0811122334',
    nurseEmail: 'wipada@maeai-hospital.go.th',
    nursePassword: 'nursepassword',
    nurseGender: 'หญิง',
    nurseBirthDate: DateTime(1990, 8, 20),
    subdistrictId: 'SD001',
  );

  final samplePendingScreening = Screening(
    screenId: 'SCR20260822001',
    patientId: 'P001',
    vhvId: 'VHV001',
    screeningDate: DateTime(2026, 8, 22),
    ageAtScreening: 51,
    createdAt: DateTime(2026, 8, 22, 9, 30),
    reviewStatus: ReviewStatus.pending,
    weight: 68.5,
    height: 168.0,
    bmi: 24.3,
    waistCm: 88.0,
    sbp: 128.0,
    dbp: 82.0,
    pulse: 74.0,
    bloodSugar: 110.0,
    results: NcdRiskCalculator.evaluateRisk(
      screeningId: 'SCR20260822001',
      weight: 68.5,
      height: 168.0,
      bmi: 24.3,
      waistCm: 88.0,
      sbp: 128.0,
      dbp: 82.0,
      pulse: 74.0,
      bloodSugar: 110.0,
      gender: 'ชาย',
    ),
  );

  final sampleApprovedScreening = samplePendingScreening.copyWith(
    reviewStatus: ReviewStatus.approved,
    reviewedByNurseId: 'NUR001',
    reviewedAt: DateTime(2026, 8, 22, 14, 15),
  );

  setUp(() {
    pdfService = PdfReportService(
      fontRegularLoader: () async => pw.Font.helvetica(),
      fontBoldLoader: () async => pw.Font.helveticaBold(),
    );
  });

  group('PdfReportService - Interface & DI Registration', () {
    test('PdfReportService implements PdfReportServiceInterface', () {
      expect(pdfService, isA<PdfReportServiceInterface>());
    });

    test('PdfReportServiceInterface is registered in GetIt locator', () async {
      locator.reset();
      await initLocator(keyStore: MemoryKeyStore());
      expect(locator.isRegistered<PdfReportServiceInterface>(), isTrue);
      final resolved = locator<PdfReportServiceInterface>();
      expect(resolved, isNotNull);
      expect(resolved, isA<PdfReportService>());
    });
  });

  group('PdfReportService - PDF Report Generation', () {
    test('generates valid PDF bytes for pending screening', () async {
      final pdfBytes = await pdfService.generateScreeningReport(
        patient: samplePatient,
        screening: samplePendingScreening,
        vhv: sampleVhv,
        village: sampleVillage,
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      expect(pdfBytes.length, greaterThan(1000));

      // Assert PDF Header magic bytes (%PDF-)
      final header = utf8.decode(pdfBytes.sublist(0, 5), allowMalformed: true);
      expect(header, equals('%PDF-'));
    });

    test(
      'generates valid PDF bytes for approved screening with nurse sign-off',
      () async {
        final pdfBytes = await pdfService.generateScreeningReport(
          patient: samplePatient,
          screening: sampleApprovedScreening,
          vhv: sampleVhv,
          nurse: sampleNurse,
          village: sampleVillage,
        );

        expect(pdfBytes, isNotNull);
        expect(pdfBytes.isNotEmpty, isTrue);
        expect(pdfBytes.length, greaterThan(1000));

        final header = utf8.decode(
          pdfBytes.sublist(0, 5),
          allowMalformed: true,
        );
        expect(header, equals('%PDF-'));
      },
    );

    test(
      'generates valid PDF when optional parameters (vhv, nurse, village) are null',
      () async {
        final pdfBytes = await pdfService.generateScreeningReport(
          patient: samplePatient,
          screening: samplePendingScreening,
          vhv: null,
          nurse: null,
          village: null,
        );

        expect(pdfBytes, isNotNull);
        expect(pdfBytes.isNotEmpty, isTrue);
        expect(pdfBytes.length, greaterThan(1000));
      },
    );

    test(
      'generates valid PDF when screening.results is empty (fallback calculation)',
      () async {
        final screeningWithoutResults = samplePendingScreening.copyWith(
          results: [],
        );

        final pdfBytes = await pdfService.generateScreeningReport(
          patient: samplePatient,
          screening: screeningWithoutResults,
          vhv: sampleVhv,
          village: sampleVillage,
        );

        expect(pdfBytes, isNotNull);
        expect(pdfBytes.isNotEmpty, isTrue);
        expect(pdfBytes.length, greaterThan(1000));
      },
    );

    test('generates valid PDF for high-risk screening in all 4 NCDs', () async {
      final highRiskScreening = samplePendingScreening.copyWith(
        weight: 95.0,
        height: 160.0,
        bmi: 37.1,
        waistCm: 105.0,
        sbp: 165.0,
        dbp: 105.0,
        pulse: 108.0,
        bloodSugar: 195.0,
        results: NcdRiskCalculator.evaluateRisk(
          screeningId: 'SCR_HIGH_RISK',
          weight: 95.0,
          height: 160.0,
          bmi: 37.1,
          waistCm: 105.0,
          sbp: 165.0,
          dbp: 105.0,
          pulse: 108.0,
          bloodSugar: 195.0,
          gender: 'ชาย',
        ),
      );

      final pdfBytes = await pdfService.generateScreeningReport(
        patient: samplePatient,
        screening: highRiskScreening,
        vhv: sampleVhv,
        nurse: sampleNurse,
        village: sampleVillage,
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
    });

    test('generates valid PDF for low-risk normal screening', () async {
      final lowRiskScreening = samplePendingScreening.copyWith(
        weight: 58.0,
        height: 165.0,
        bmi: 21.3,
        waistCm: 72.0,
        sbp: 110.0,
        dbp: 70.0,
        pulse: 68.0,
        bloodSugar: 88.0,
        results: NcdRiskCalculator.evaluateRisk(
          screeningId: 'SCR_LOW_RISK',
          weight: 58.0,
          height: 165.0,
          bmi: 21.3,
          waistCm: 72.0,
          sbp: 110.0,
          dbp: 70.0,
          pulse: 68.0,
          bloodSugar: 88.0,
          gender: 'หญิง',
        ),
      );

      final femalePatient = samplePatient.copyWith(
        patientGender: 'หญิง',
        patientTitle: 'นางสาว',
        patientFname: 'พรทิพย์',
      );

      final pdfBytes = await pdfService.generateScreeningReport(
        patient: femalePatient,
        screening: lowRiskScreening,
        vhv: sampleVhv,
        nurse: sampleNurse,
        village: sampleVillage,
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
    });

    test('handles default constructor with font fallback gracefully', () async {
      final defaultPdfService = PdfReportService();
      final pdfBytes = await defaultPdfService.generateScreeningReport(
        patient: samplePatient,
        screening: samplePendingScreening,
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
    });
  });
}
