import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_risk_calculator.dart';
import 'package:ncd_screening_mobile/domain/services/pdf_report_service.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PdfReportService pdfService;

  setUp(() {
    pdfService = PdfReportService(
      fontRegularLoader: () async => pw.Font.helvetica(),
      fontBoldLoader: () async => pw.Font.helveticaBold(),
    );
  });

  const baseVillage = Village(
    villageId: 'VIL001',
    villageName: 'บ้านท่าตอนเหนือ',
    villageNumber: '2',
    subdistrictId: 'SD001',
    subdistrictName: 'ท่าตอน',
    districtName: 'แม่อาย',
    provinceName: 'เชียงใหม่',
  );

  final basePatient = Patient(
    patientId: 'P999',
    patientCitizenId: '1509900999999',
    patientTitle: 'นาย',
    patientFname: 'ทดสอบ',
    patientLname: 'ระบบคัดกรอง',
    patientGender: 'ชาย',
    patientBirthDate: DateTime(1960, 1, 1),
    patientAddress: '99/9 หมู่ 2 ตำบลท่าตอน อำเภอแม่อาย จังหวัดเชียงใหม่ 50280',
    patientMobile: '0899999999',
    villageId: 'VIL001',
  );

  final baseVhv = VHV(
    vhvId: 'VHV001',
    vhvCitizenId: '1509900111111',
    vhvTitle: 'นาง',
    vhvFname: 'สมหวัง',
    vhvLname: 'สุขใจ',
    vhvMobile: '0812345678',
    vhvEmail: 'somwang@example.com',
    vhvPassword: 'password123',
    vhvBirthDate: DateTime(1975, 4, 10),
    vhvGender: 'หญิง',
    vhvAddress: '10 หมู่ 2 ต.ท่าตอน',
    villageId: 'VIL001',
  );

  final baseNurse = Nurse(
    nurseId: 'NUR001',
    nurseTitle: 'พว.',
    nurseFname: 'กานดา',
    nurseLname: 'รักพยาบาล',
    nurseMobile: '0819876543',
    nurseEmail: 'kanda@hospital.go.th',
    nursePassword: 'nursepassword',
    nurseGender: 'หญิง',
    nurseBirthDate: DateTime(1985, 11, 25),
    subdistrictId: 'SD001',
  );

  void verifyPdfHeaderAndIntegrity(Uint8List bytes) {
    expect(bytes, isNotNull);
    expect(bytes.isNotEmpty, isTrue);
    expect(bytes.length, greaterThan(1500));

    // Verify %PDF- magic byte header
    final header = utf8.decode(bytes.sublist(0, 5), allowMalformed: true);
    expect(header, equals('%PDF-'));

    // Verify PDF end of file or trailer content
    final endSlice = utf8.decode(
      bytes.sublist(bytes.length - 256),
      allowMalformed: true,
    );
    expect(
      endSlice.contains('%%EOF') ||
          endSlice.contains('trailer') ||
          endSlice.contains('startxref'),
      isTrue,
    );
  }

  group('PDF Stress Test 1: Extreme Biometric & Risk Values', () {
    test(
      'Extreme hypertensive crisis & severe diabetes (SBP 240, DBP 140, Sugar 450, BMI 48.5)',
      () async {
        final screening = Screening(
          screenId: 'SCR_EXTREME_HIGH_01',
          patientId: basePatient.patientId,
          vhvId: baseVhv.vhvId,
          screeningDate: DateTime(2026, 8, 23),
          ageAtScreening: 66,
          createdAt: DateTime(2026, 8, 23, 10, 0),
          reviewStatus: ReviewStatus.pending,
          weight: 130.0,
          height: 164.0,
          bmi: 48.5,
          waistCm: 140.0,
          sbp: 240.0,
          dbp: 140.0,
          pulse: 135.0,
          bloodSugar: 450.0,
          results: NcdRiskCalculator.evaluateRisk(
            screeningId: 'SCR_EXTREME_HIGH_01',
            weight: 130.0,
            height: 164.0,
            bmi: 48.5,
            waistCm: 140.0,
            sbp: 240.0,
            dbp: 140.0,
            pulse: 135.0,
            bloodSugar: 450.0,
            gender: 'ชาย',
          ),
        );

        final bytes = await pdfService.generateScreeningReport(
          patient: basePatient,
          screening: screening,
          vhv: baseVhv,
          village: baseVillage,
        );

        verifyPdfHeaderAndIntegrity(bytes);
        expect(
          screening.results.every((r) => r.riskLevel == RiskLevel.high),
          isTrue,
        );
      },
    );

    test(
      'Extreme hypotensive & severe hypoglycemia (SBP 50, DBP 30, Sugar 35, BMI 11.5)',
      () async {
        final screening = Screening(
          screenId: 'SCR_EXTREME_LOW_02',
          patientId: basePatient.patientId,
          vhvId: baseVhv.vhvId,
          screeningDate: DateTime(2026, 8, 23),
          ageAtScreening: 89,
          createdAt: DateTime(2026, 8, 23, 11, 0),
          reviewStatus: ReviewStatus.pending,
          weight: 28.0,
          height: 155.0,
          bmi: 11.5,
          waistCm: 45.0,
          sbp: 50.0,
          dbp: 30.0,
          pulse: 42.0,
          bloodSugar: 35.0,
          results: NcdRiskCalculator.evaluateRisk(
            screeningId: 'SCR_EXTREME_LOW_02',
            weight: 28.0,
            height: 155.0,
            bmi: 11.5,
            waistCm: 45.0,
            sbp: 50.0,
            dbp: 30.0,
            pulse: 42.0,
            bloodSugar: 35.0,
            gender: 'ชาย',
          ),
        );

        final bytes = await pdfService.generateScreeningReport(
          patient: basePatient,
          screening: screening,
          vhv: baseVhv,
          village: baseVillage,
        );

        verifyPdfHeaderAndIntegrity(bytes);
      },
    );

    test('Zero boundary biometrics & edge values (all 0.0 values)', () async {
      final screening = Screening(
        screenId: 'SCR_ZERO_BOUND_03',
        patientId: basePatient.patientId,
        vhvId: baseVhv.vhvId,
        screeningDate: DateTime(2026, 1, 1),
        ageAtScreening: 0,
        createdAt: DateTime(2026, 1, 1, 0, 0),
        reviewStatus: ReviewStatus.pending,
        weight: 0.0,
        height: 0.0,
        bmi: 0.0,
        waistCm: 0.0,
        sbp: 0.0,
        dbp: 0.0,
        pulse: 0.0,
        bloodSugar: 0.0,
        results: [], // Tests fallback evaluation on 0 values
      );

      final bytes = await pdfService.generateScreeningReport(
        patient: basePatient,
        screening: screening,
      );

      verifyPdfHeaderAndIntegrity(bytes);
    });

    test(
      'Extreme large scale values (SBP 999, DBP 600, Sugar 9999, Weight 450 kg)',
      () async {
        final screening = Screening(
          screenId: 'SCR_MASSIVE_NUMS_04',
          patientId: basePatient.patientId,
          vhvId: baseVhv.vhvId,
          screeningDate: DateTime(2026, 12, 31),
          ageAtScreening: 120,
          createdAt: DateTime(2026, 12, 31, 23, 59),
          reviewStatus: ReviewStatus.approved,
          reviewedByNurseId: baseNurse.nurseId,
          reviewedAt: DateTime(2026, 12, 31, 23, 59),
          weight: 450.0,
          height: 250.0,
          bmi: 72.0,
          waistCm: 250.0,
          sbp: 999.0,
          dbp: 600.0,
          pulse: 300.0,
          bloodSugar: 9999.0,
          results: NcdRiskCalculator.evaluateRisk(
            screeningId: 'SCR_MASSIVE_NUMS_04',
            weight: 450.0,
            height: 250.0,
            bmi: 72.0,
            waistCm: 250.0,
            sbp: 999.0,
            dbp: 600.0,
            pulse: 300.0,
            bloodSugar: 9999.0,
            gender: 'ชาย',
          ),
        );

        final bytes = await pdfService.generateScreeningReport(
          patient: basePatient,
          screening: screening,
          nurse: baseNurse,
          vhv: baseVhv,
          village: baseVillage,
        );

        verifyPdfHeaderAndIntegrity(bytes);
      },
    );
  });

  group('PDF Stress Test 2: Thai Characters, Long Addresses & Special Characters', () {
    test(
      'Complex Thai tone marks, consonant clusters & rare ligatures',
      () async {
        final complexThaiPatient = Patient(
          patientId: 'P_THAI_COMPLEX',
          patientCitizenId: '1509988776655',
          patientTitle: 'นางสาว',
          patientFname: 'กฤษณาญ์พัชร์',
          patientLname: 'ศิริรัตนานุกูลพงศ์ไพศาล',
          patientGender: 'หญิง',
          patientBirthDate: DateTime(1992, 9, 19),
          patientAddress:
              '๙๙/๙๙ หมู่ ๙ ตำบลท่าตอน อำเภอแม่อาย จังหวัดเชียงใหม่ รหัสไปรษณีย์ ๕๐๒๘๐',
          patientMobile: '081-234-5678',
          villageId: 'VIL001',
        );

        final complexThaiVillage = const Village(
          villageId: 'VIL_COMPLEX',
          villageName: 'บ้านสันป่าสักทองพัฒนาสามัคคีธรรม',
          villageNumber: '๑๒',
          subdistrictId: 'SD001',
          subdistrictName: 'ท่าตอน (ลุ่มน้ำกก)',
          districtName: 'แม่อาย',
          provinceName: 'เชียงใหม่',
        );

        final screening = Screening(
          screenId: 'SCR_THAI_COMPLEX',
          patientId: complexThaiPatient.patientId,
          vhvId: baseVhv.vhvId,
          screeningDate: DateTime(2026, 8, 23),
          ageAtScreening: 34,
          createdAt: DateTime(2026, 8, 23),
          reviewStatus: ReviewStatus.pending,
          weight: 55.0,
          height: 160.0,
          bmi: 21.5,
          waistCm: 70.0,
          sbp: 115.0,
          dbp: 75.0,
          pulse: 72.0,
          bloodSugar: 92.0,
          results: NcdRiskCalculator.evaluateRisk(
            screeningId: 'SCR_THAI_COMPLEX',
            weight: 55.0,
            height: 160.0,
            bmi: 21.5,
            waistCm: 70.0,
            sbp: 115.0,
            dbp: 75.0,
            pulse: 72.0,
            bloodSugar: 92.0,
            gender: 'หญิง',
          ),
        );

        final bytes = await pdfService.generateScreeningReport(
          patient: complexThaiPatient,
          screening: screening,
          vhv: baseVhv,
          village: complexThaiVillage,
        );

        verifyPdfHeaderAndIntegrity(bytes);
      },
    );

    test(
      'Extremely long Thai address & multi-line patient details (1000+ characters)',
      () async {
        final longAddress =
            'อาคารชุดเคหะชุมชนท่าตอนริเวอร์วิลล์ ชั้นที่ 14 ห้องชุดเลขที่ 1408/99 '
            'ซอยสุขสมบูรณ์สามัคคีวิวัฒน์พัฒนา ถนนเชียงใหม่-ฝาง-แม่อาย แยกทางหลวงชนบท ชม.4012 '
            'หมู่บ้านจัดสรรล้านนาสวรรค์ริมดอย ตำบลท่าตอน อำเภอแม่อาย จังหวัดเชียงใหม่ 50280 '
            'จุดสังเกต: เยื้องศาลากลางหมู่บ้าน ตรงข้ามสวนผลไม้ลุงบุญมีและสะพานข้ามแม่น้ำกก '
            '(ติดต่อ รปภ. ประตูด้านหน้าก่อนเข้าตรวจเยี่ยมบ้าน)';

        final longAddressPatient = basePatient.copyWith(
          patientAddress: longAddress,
          patientFname: 'สมเกียรติเกรียงไกรยิ่งยงไพบูลย์วัฒนาถาวร',
          patientLname: 'อภิชาตตระกูลสถาพรพิทักษ์ประชาธิปัตย์',
        );

        final screening = Screening(
          screenId: 'SCR_LONG_ADDR',
          patientId: longAddressPatient.patientId,
          vhvId: baseVhv.vhvId,
          screeningDate: DateTime(2026, 8, 23),
          ageAtScreening: 58,
          createdAt: DateTime(2026, 8, 23),
          reviewStatus: ReviewStatus.pending,
          weight: 70.0,
          height: 170.0,
          bmi: 24.2,
          waistCm: 85.0,
          sbp: 130.0,
          dbp: 85.0,
          pulse: 78.0,
          bloodSugar: 105.0,
          results: NcdRiskCalculator.evaluateRisk(
            screeningId: 'SCR_LONG_ADDR',
            weight: 70.0,
            height: 170.0,
            bmi: 24.2,
            waistCm: 85.0,
            sbp: 130.0,
            dbp: 85.0,
            pulse: 78.0,
            bloodSugar: 105.0,
            gender: 'ชาย',
          ),
        );

        final bytes = await pdfService.generateScreeningReport(
          patient: longAddressPatient,
          screening: screening,
          vhv: baseVhv,
          village: baseVillage,
        );

        verifyPdfHeaderAndIntegrity(bytes);
      },
    );

    test(
      'Special symbols, XML/HTML tags, quotes, emojis, and injection strings',
      () async {
        final specialPatient = basePatient.copyWith(
          patientFname: '<script>alert("XSS & Test")</script>',
          patientLname:
              "O'Connor & Sons #1 (Special % / \\ ~ ` ? ! @ \$ ^ * [ ] { } | + = ; : , .)",
          patientCitizenId: '1-5099-00123-45-6 / #001',
          patientMobile: '+66 (081) 234-5678 ext. 99#',
        );

        final specialResults = [
          const ScreeningResult(
            resultId: 'RES_SPEC_01',
            screeningId: 'SCR_SPEC',
            diseaseName: 'โรคเบาหวาน (DM & Type-2) <High Alert>',
            diseaseCode: 'DM',
            score: 3,
            riskLevel: RiskLevel.high,
            criteriaText:
                'FBS >= 126 mg/dL & HbA1c > 6.5% | (BP 180/110 & "Critical")',
            adviceText:
                'คำเตือน: <Warning> & "ด่วนที่สุด" / แนะนำพบแพทย์ รพ.สต. ทันที (100% Verified)',
          ),
          const ScreeningResult(
            resultId: 'RES_SPEC_02',
            screeningId: 'SCR_SPEC',
            diseaseName: 'โรคหลอดเลือดหัวใจ (CVD/Stroke) [ICD-10: I25.1]',
            diseaseCode: 'CVD',
            score: 4,
            riskLevel: RiskLevel.high,
            criteriaText: 'Framingham Risk Score > 20% + Pulse >= 120 bpm',
            adviceText:
                'ส่งต่อโรงพยาบาลแม่อายด่วน (Referral Priority: #1 Level-A+)',
          ),
        ];

        final screening = Screening(
          screenId: 'SCR_SPEC_INJECTION_#99',
          patientId: specialPatient.patientId,
          vhvId: baseVhv.vhvId,
          screeningDate: DateTime(2026, 8, 23),
          ageAtScreening: 60,
          createdAt: DateTime(2026, 8, 23),
          reviewStatus: ReviewStatus.approved,
          reviewedByNurseId: baseNurse.nurseId,
          reviewedAt: DateTime(2026, 8, 23),
          weight: 80.0,
          height: 165.0,
          bmi: 29.4,
          waistCm: 95.0,
          sbp: 180.0,
          dbp: 110.0,
          pulse: 120.0,
          bloodSugar: 210.0,
          results: specialResults,
        );

        final bytes = await pdfService.generateScreeningReport(
          patient: specialPatient,
          screening: screening,
          nurse: baseNurse,
          vhv: baseVhv,
          village: baseVillage,
        );

        verifyPdfHeaderAndIntegrity(bytes);
      },
    );
  });

  group('PDF Stress Test 3: Multi-Page Flow & Extended Clinical Battery', () {
    test(
      'Handles 12 custom screening results with multi-page automatic layout splitting',
      () async {
        final extendedResults = List.generate(
          12,
          (i) => ScreeningResult(
            resultId: 'RES_EXTENDED_$i',
            screeningId: 'SCR_EXTENDED',
            diseaseName:
                'การประเมินภาวะสุขภาพและโรคเฉพาะทางข้อที่ ${i + 1} (Extended Clinical Protocol #$i)',
            diseaseCode: 'EXT_$i',
            score: (i % 3) + 1,
            riskLevel: i % 3 == 0
                ? RiskLevel.high
                : (i % 3 == 1 ? RiskLevel.moderate : RiskLevel.low),
            criteriaText:
                'เกณฑ์การประเมินข้อที่ $i: ตรวจพบค่าตัวชี้วัดความดัน $i/80 mmHg, น้ำตาล ${i}0 mg/dL, อาการแทรกซ้อน $i ประการ',
            adviceText:
                'คำแนะนำการรักษาและติดตามผลข้อที่ $i: ดำเนินการตามคู่มือเวชปฏิบัติสาธารณสุขชุมชนอย่างเคร่งครัดและนัดตรวจซ้ำใน $i สัปดาห์',
          ),
        );

        final multiPageScreening = Screening(
          screenId: 'SCR_MULTIPAGE_12',
          patientId: basePatient.patientId,
          vhvId: baseVhv.vhvId,
          screeningDate: DateTime(2026, 8, 23),
          ageAtScreening: 65,
          createdAt: DateTime(2026, 8, 23),
          reviewStatus: ReviewStatus.approved,
          reviewedByNurseId: baseNurse.nurseId,
          reviewedAt: DateTime(2026, 8, 23),
          weight: 75.0,
          height: 165.0,
          bmi: 27.5,
          waistCm: 92.0,
          sbp: 145.0,
          dbp: 95.0,
          pulse: 84.0,
          bloodSugar: 140.0,
          results: extendedResults,
        );

        final bytes = await pdfService.generateScreeningReport(
          patient: basePatient,
          screening: multiPageScreening,
          nurse: baseNurse,
          vhv: baseVhv,
          village: baseVillage,
        );

        verifyPdfHeaderAndIntegrity(bytes);
        // Extended results should yield a larger document
        expect(bytes.length, greaterThan(3000));
      },
    );
  });

  group('PDF Stress Test 4: Concurrency & High Load Generation', () {
    test(
      'Generates 25 distinct PDF reports concurrently in parallel without memory corruption or race conditions',
      () async {
        final futures = List.generate(25, (index) {
          final patient = basePatient.copyWith(
            patientId: 'P_CONCURRENT_$index',
            patientCitizenId: '15099000000${index.toString().padLeft(2, '0')}',
            patientFname: 'ผู้ป่วยทดสอบคนที่ $index',
          );

          final sbpVal = 100.0 + (index * 5.0);
          final dbpVal = 65.0 + (index * 3.0);
          final sugarVal = 80.0 + (index * 8.0);
          final weightVal = 50.0 + (index * 2.5);

          final screening = Screening(
            screenId: 'SCR_CONCURRENT_${index.toString().padLeft(3, '0')}',
            patientId: patient.patientId,
            vhvId: baseVhv.vhvId,
            screeningDate: DateTime(2026, 8, 23),
            ageAtScreening: 40 + index,
            createdAt: DateTime(2026, 8, 23, 8, index),
            reviewStatus: index.isEven
                ? ReviewStatus.approved
                : ReviewStatus.pending,
            reviewedByNurseId: index.isEven ? baseNurse.nurseId : null,
            reviewedAt: index.isEven ? DateTime(2026, 8, 23, 10, index) : null,
            weight: weightVal,
            height: 165.0,
            bmi: NcdRiskCalculator.calculateBmi(weightVal, 165.0),
            waistCm: 75.0 + index,
            sbp: sbpVal,
            dbp: dbpVal,
            pulse: 70.0 + (index % 30),
            bloodSugar: sugarVal,
            results: NcdRiskCalculator.evaluateRisk(
              screeningId: 'SCR_CONCURRENT_$index',
              weight: weightVal,
              height: 165.0,
              bmi: NcdRiskCalculator.calculateBmi(weightVal, 165.0),
              waistCm: 75.0 + index,
              sbp: sbpVal,
              dbp: dbpVal,
              pulse: 70.0 + (index % 30),
              bloodSugar: sugarVal,
              gender: index.isEven ? 'ชาย' : 'หญิง',
            ),
          );

          return pdfService.generateScreeningReport(
            patient: patient,
            screening: screening,
            nurse: index.isEven ? baseNurse : null,
            vhv: baseVhv,
            village: baseVillage,
          );
        });

        final results = await Future.wait(futures);

        expect(results.length, equals(25));
        for (final bytes in results) {
          verifyPdfHeaderAndIntegrity(bytes);
        }
      },
    );
  });

  group('PDF Stress Test 5: Empty and Edge-Case String Permutations', () {
    test(
      'Completely empty and blank string fields in patient and village objects',
      () async {
        final blankPatient = Patient(
          patientId: '',
          patientCitizenId: '',
          patientTitle: '',
          patientFname: '',
          patientLname: '',
          patientGender: '',
          patientBirthDate: DateTime(1970, 1, 1),
          patientAddress: '',
          patientMobile: '',
          villageId: '',
        );

        final blankScreening = Screening(
          screenId: '',
          patientId: '',
          vhvId: '',
          screeningDate: DateTime(2026, 8, 23),
          ageAtScreening: 0,
          createdAt: DateTime(2026, 8, 23),
          reviewStatus: ReviewStatus.pending,
          weight: 0.0,
          height: 0.0,
          bmi: 0.0,
          waistCm: 0.0,
          sbp: 0.0,
          dbp: 0.0,
          pulse: 0.0,
          bloodSugar: 0.0,
          results: [
            const ScreeningResult(
              resultId: '',
              screeningId: '',
              diseaseName: '',
              diseaseCode: '',
              score: 0,
              riskLevel: RiskLevel.low,
              criteriaText: '',
              adviceText: '',
            ),
          ],
        );

        final bytes = await pdfService.generateScreeningReport(
          patient: blankPatient,
          screening: blankScreening,
          vhv: null,
          nurse: null,
          village: null,
        );

        verifyPdfHeaderAndIntegrity(bytes);
      },
    );
  });
}
