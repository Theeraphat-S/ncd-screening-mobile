import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/models/village_analytics.dart';
import 'package:ncd_screening_mobile/domain/services/village_analytics_calculator.dart';

void main() {
  group('VillageAnalyticsCalculator Unit Tests', () {
    late List<Village> sampleVillages;
    late List<Patient> samplePatients;
    late List<Screening> sampleScreenings;

    setUp(() {
      sampleVillages = [
        const Village(
          villageId: 'V001',
          villageName: 'บ้านท่าตอน',
          villageNumber: '1',
        ),
        const Village(
          villageId: 'V002',
          villageName: 'บ้านใหม่หมอกจ๋าม',
          villageNumber: '2',
        ),
        const Village(
          villageId: 'V003',
          villageName: 'บ้านห้วยปู',
          villageNumber: '3',
        ),
      ];

      samplePatients = [
        Patient(
          patientId: 'P001',
          patientCitizenId: '1000000000001',
          patientTitle: 'นาย',
          patientFname: 'สมชาย',
          patientLname: 'ใจดี',
          patientGender: 'ชาย',
          patientBirthDate: DateTime(1980, 5, 10), // Age ~46 (35-59)
          patientAddress: '1 หมู่ 1',
          villageId: 'V001',
        ),
        Patient(
          patientId: 'P002',
          patientCitizenId: '1000000000002',
          patientTitle: 'นาง',
          patientFname: 'สมศรี',
          patientLname: 'มีสุข',
          patientGender: 'หญิง',
          patientBirthDate: DateTime(1955, 1, 15), // Age ~71 (>=60)
          patientAddress: '2 หมู่ 1',
          villageId: 'V001',
        ),
        Patient(
          patientId: 'P003',
          patientCitizenId: '1000000000003',
          patientTitle: 'นาย',
          patientFname: 'กิตติ',
          patientLname: 'วัยใส',
          patientGender: 'ชาย',
          patientBirthDate: DateTime(2005, 3, 20), // Age ~21 (<35)
          patientAddress: '3 หมู่ 1',
          villageId: 'V001',
        ),
        Patient(
          patientId: 'P004',
          patientCitizenId: '1000000000004',
          patientTitle: 'นางสาว',
          patientFname: 'มาลี',
          patientLname: 'สวยงาม',
          patientGender: 'หญิง',
          patientBirthDate: DateTime(1990, 8, 12), // Age ~36 (35-59)
          patientAddress: '10 หมู่ 2',
          villageId: 'V002',
        ),
        Patient(
          patientId: 'P005',
          patientCitizenId: '1000000000005',
          patientTitle: 'นาย',
          patientFname: 'ประสิทธิ์',
          patientLname: 'มั่นคง',
          patientGender: 'ชาย',
          patientBirthDate: DateTime(1960, 11, 5), // Age ~65 (>=60)
          patientAddress: '11 หมู่ 2',
          villageId: 'V002',
        ),
        Patient(
          patientId: 'P006',
          patientCitizenId: '1000000000006',
          patientTitle: 'นาย',
          patientFname: 'เอก',
          patientLname: 'ไร้การคัดกรอง',
          patientGender: 'ชาย',
          patientBirthDate: DateTime(1998, 2, 2), // Age ~28 (<35)
          patientAddress: '20 หมู่ 3',
          villageId: 'V003',
        ),
      ];

      // Screenings:
      // P001 has 2 screenings (S001 older, S002 latest). S002 has high DM & high HT
      // P002 has 1 screening (S003). Low DM, mod HT, mod CVD
      // P004 has 1 screening (S004). High CVD, High Obesity
      // P005 has 1 screening (S005). Low all
      // P003 and P006 have no screenings.
      sampleScreenings = [
        Screening(
          screenId: 'S001',
          patientId: 'P001',
          vhvId: 'VHV001',
          screeningDate: DateTime(2026, 1, 10),
          ageAtScreening: 45,
          createdAt: DateTime(2026, 1, 10),
          reviewStatus: ReviewStatus.approved,
          weight: 65,
          height: 170,
          bmi: 22.5,
          waistCm: 80,
          sbp: 118,
          dbp: 75,
          pulse: 72,
          bloodSugar: 95,
          results: const [
            ScreeningResult(
              resultId: 'R1_DM',
              screeningId: 'S001',
              diseaseName: 'โรคเบาหวาน',
              diseaseCode: 'DIABETES',
              score: 1,
              riskLevel: RiskLevel.low,
              adviceText: 'ปกติ',
            ),
          ],
        ),
        Screening(
          screenId: 'S002',
          patientId: 'P001',
          vhvId: 'VHV001',
          screeningDate: DateTime(2026, 2, 15),
          ageAtScreening: 46,
          createdAt: DateTime(2026, 2, 15),
          reviewStatus: ReviewStatus.pending,
          weight: 70,
          height: 170,
          bmi: 24.2,
          waistCm: 88,
          sbp: 145,
          dbp: 95,
          pulse: 75,
          bloodSugar: 140,
          results: const [
            ScreeningResult(
              resultId: 'R2_DM',
              screeningId: 'S002',
              diseaseName: 'โรคเบาหวาน',
              diseaseCode: 'DIABETES',
              score: 3,
              riskLevel: RiskLevel.high,
              adviceText: 'เสี่ยงสูง',
            ),
            ScreeningResult(
              resultId: 'R2_HT',
              screeningId: 'S002',
              diseaseName: 'โรคความดันโลหิตสูง',
              diseaseCode: 'HYPERTENSION',
              score: 3,
              riskLevel: RiskLevel.high,
              adviceText: 'เสี่ยงสูง',
            ),
            ScreeningResult(
              resultId: 'R2_CVD',
              screeningId: 'S002',
              diseaseName: 'โรคหลอดเลือดหัวใจ',
              diseaseCode: 'CVD',
              score: 1,
              riskLevel: RiskLevel.low,
              adviceText: 'ปกติ',
            ),
            ScreeningResult(
              resultId: 'R2_OB',
              screeningId: 'S002',
              diseaseName: 'โรคอ้วนลงพุง',
              diseaseCode: 'METABOLIC_OBESITY',
              score: 1,
              riskLevel: RiskLevel.low,
              adviceText: 'ปกติ',
            ),
          ],
        ),
        Screening(
          screenId: 'S003',
          patientId: 'P002',
          vhvId: 'VHV001',
          screeningDate: DateTime(2026, 2, 10),
          ageAtScreening: 71,
          createdAt: DateTime(2026, 2, 10),
          reviewStatus: ReviewStatus.approved,
          weight: 55,
          height: 155,
          bmi: 22.9,
          waistCm: 76,
          sbp: 128,
          dbp: 84,
          pulse: 70,
          bloodSugar: 90,
          results: const [
            ScreeningResult(
              resultId: 'R3_DM',
              screeningId: 'S003',
              diseaseName: 'โรคเบาหวาน',
              diseaseCode: 'DIABETES',
              score: 1,
              riskLevel: RiskLevel.low,
              adviceText: 'ปกติ',
            ),
            ScreeningResult(
              resultId: 'R3_HT',
              screeningId: 'S003',
              diseaseName: 'โรคความดันโลหิตสูง',
              diseaseCode: 'HYPERTENSION',
              score: 2,
              riskLevel: RiskLevel.moderate,
              adviceText: 'เสี่ยงปานกลาง',
            ),
            ScreeningResult(
              resultId: 'R3_CVD',
              screeningId: 'S003',
              diseaseName: 'โรคหลอดเลือดหัวใจ',
              diseaseCode: 'CVD',
              score: 2,
              riskLevel: RiskLevel.moderate,
              adviceText: 'เสี่ยงปานกลาง',
            ),
            ScreeningResult(
              resultId: 'R3_OB',
              screeningId: 'S003',
              diseaseName: 'โรคอ้วนลงพุง',
              diseaseCode: 'METABOLIC_OBESITY',
              score: 1,
              riskLevel: RiskLevel.low,
              adviceText: 'ปกติ',
            ),
          ],
        ),
        Screening(
          screenId: 'S004',
          patientId: 'P004',
          vhvId: 'VHV002',
          screeningDate: DateTime(2026, 2, 12),
          ageAtScreening: 36,
          createdAt: DateTime(2026, 2, 12),
          reviewStatus: ReviewStatus.pending,
          weight: 80,
          height: 160,
          bmi: 31.2,
          waistCm: 95,
          sbp: 130,
          dbp: 85,
          pulse: 82,
          bloodSugar: 110,
          results: const [
            ScreeningResult(
              resultId: 'R4_DM',
              screeningId: 'S004',
              diseaseName: 'โรคเบาหวาน',
              diseaseCode: 'DIABETES',
              score: 2,
              riskLevel: RiskLevel.moderate,
              adviceText: 'เสี่ยงปานกลาง',
            ),
            ScreeningResult(
              resultId: 'R4_HT',
              screeningId: 'S004',
              diseaseName: 'โรคความดันโลหิตสูง',
              diseaseCode: 'HYPERTENSION',
              score: 2,
              riskLevel: RiskLevel.moderate,
              adviceText: 'เสี่ยงปานกลาง',
            ),
            ScreeningResult(
              resultId: 'R4_CVD',
              screeningId: 'S004',
              diseaseName: 'โรคหลอดเลือดหัวใจ',
              diseaseCode: 'CVD',
              score: 3,
              riskLevel: RiskLevel.high,
              adviceText: 'เสี่ยงสูง',
            ),
            ScreeningResult(
              resultId: 'R4_OB',
              screeningId: 'S004',
              diseaseName: 'โรคอ้วนลงพุง',
              diseaseCode: 'METABOLIC_OBESITY',
              score: 3,
              riskLevel: RiskLevel.high,
              adviceText: 'เสี่ยงสูง',
            ),
          ],
        ),
        Screening(
          screenId: 'S005',
          patientId: 'P005',
          vhvId: 'VHV002',
          screeningDate: DateTime(2026, 2, 8),
          ageAtScreening: 65,
          createdAt: DateTime(2026, 2, 8),
          reviewStatus: ReviewStatus.approved,
          weight: 62,
          height: 168,
          bmi: 22.0,
          waistCm: 80,
          sbp: 115,
          dbp: 75,
          pulse: 68,
          bloodSugar: 92,
          results: const [
            ScreeningResult(
              resultId: 'R5_DM',
              screeningId: 'S005',
              diseaseName: 'โรคเบาหวาน',
              diseaseCode: 'DIABETES',
              score: 1,
              riskLevel: RiskLevel.low,
              adviceText: 'ปกติ',
            ),
            ScreeningResult(
              resultId: 'R5_HT',
              screeningId: 'S005',
              diseaseName: 'โรคความดันโลหิตสูง',
              diseaseCode: 'HYPERTENSION',
              score: 1,
              riskLevel: RiskLevel.low,
              adviceText: 'ปกติ',
            ),
            ScreeningResult(
              resultId: 'R5_CVD',
              screeningId: 'S005',
              diseaseName: 'โรคหลอดเลือดหัวใจ',
              diseaseCode: 'CVD',
              score: 1,
              riskLevel: RiskLevel.low,
              adviceText: 'ปกติ',
            ),
            ScreeningResult(
              resultId: 'R5_OB',
              screeningId: 'S005',
              diseaseName: 'โรคอ้วนลงพุง',
              diseaseCode: 'METABOLIC_OBESITY',
              score: 1,
              riskLevel: RiskLevel.low,
              adviceText: 'ปกติ',
            ),
          ],
        ),
      ];
    });

    test('Computes aggregate KPIs accurately across All Villages', () {
      final analytics = VillageAnalyticsCalculator.compute(
        villages: sampleVillages,
        patients: samplePatients,
        screenings: sampleScreenings,
      );

      expect(analytics.isAllVillages, isTrue);
      expect(analytics.totalVillagesCount, equals(3));
      expect(analytics.totalPatients, equals(6));
      expect(
        analytics.screenedPatientsCount,
        equals(4),
      ); // P001, P002, P004, P005
      expect(analytics.totalScreeningsCount, equals(5));
      // Coverage = 4 / 6 * 100 = 66.7%
      expect(analytics.screeningCoveragePercentage, equals(66.7));
      expect(analytics.pendingReviewsCount, equals(2)); // S002, S004
      expect(analytics.approvedReviewsCount, equals(3)); // S001, S003, S005
      expect(
        analytics.highRiskPatientsCount,
        equals(2),
      ); // P001 (DM, HT), P004 (CVD, OB)
    });

    test('Computes 4 NCD risk breakdowns from latest screenings correctly', () {
      final analytics = VillageAnalyticsCalculator.compute(
        villages: sampleVillages,
        patients: samplePatients,
        screenings: sampleScreenings,
      );

      // 4 screened patients: P001 (S002), P002 (S003), P004 (S004), P005 (S005)
      // Diabetes: P001(High), P002(Low), P004(Mod), P005(Low) -> Low:2, Mod:1, High:1
      final dm = analytics.diabetesBreakdown!;
      expect(dm.totalScreened, equals(4));
      expect(dm.lowCount, equals(2));
      expect(dm.moderateCount, equals(1));
      expect(dm.highCount, equals(1));
      expect(dm.lowPercentage, equals(50.0));
      expect(dm.moderatePercentage, equals(25.0));
      expect(dm.highPercentage, equals(25.0));

      // Hypertension: P001(High), P002(Mod), P004(Mod), P005(Low) -> Low:1, Mod:2, High:1
      final ht = analytics.hypertensionBreakdown!;
      expect(ht.totalScreened, equals(4));
      expect(ht.lowCount, equals(1));
      expect(ht.moderateCount, equals(2));
      expect(ht.highCount, equals(1));
      expect(ht.lowPercentage, equals(25.0));
      expect(ht.moderatePercentage, equals(50.0));
      expect(ht.highPercentage, equals(25.0));

      // CVD: P001(Low), P002(Mod), P004(High), P005(Low) -> Low:2, Mod:1, High:1
      final cvd = analytics.cvdBreakdown!;
      expect(cvd.lowCount, equals(2));
      expect(cvd.moderateCount, equals(1));
      expect(cvd.highCount, equals(1));

      // Obesity: P001(Low), P002(Low), P004(High), P005(Low) -> Low:3, Mod:0, High:1
      final ob = analytics.obesityBreakdown!;
      expect(ob.lowCount, equals(3));
      expect(ob.moderateCount, equals(0));
      expect(ob.highCount, equals(1));
      expect(ob.lowPercentage, equals(75.0));
      expect(ob.highPercentage, equals(25.0));
    });

    test('Computes demographic gender and age distributions accurately', () {
      final analytics = VillageAnalyticsCalculator.compute(
        villages: sampleVillages,
        patients: samplePatients,
        screenings: sampleScreenings,
      );

      final demo = analytics.demographics;
      // 4 Male (P001, P003, P005, P006), 2 Female (P002, P004) -> Total 6
      expect(demo.totalPatients, equals(6));
      expect(demo.maleCount, equals(4));
      expect(demo.femaleCount, equals(2));
      expect(demo.maleRatio, equals(66.7));
      expect(demo.femaleRatio, equals(33.3));

      // Age brackets:
      // < 35: P003 (21), P006 (28) -> 2
      // 35-59: P001 (46), P004 (36) -> 2
      // >= 60: P002 (71), P005 (65) -> 2
      expect(demo.ageUnder35Count, equals(2));
      expect(demo.age35To59Count, equals(2));
      expect(demo.age60AndAboveCount, equals(2));
      expect(demo.ageUnder35Ratio, equals(33.3));
      expect(demo.age35To59Ratio, equals(33.3));
      expect(demo.age60AndAboveRatio, equals(33.3));
    });

    test('Filters metrics accurately for a specific village', () {
      final analytics = VillageAnalyticsCalculator.compute(
        villages: sampleVillages,
        patients: samplePatients,
        screenings: sampleScreenings,
        selectedVillageId: 'V001',
      );

      expect(analytics.isAllVillages, isFalse);
      expect(analytics.selectedVillageId, equals('V001'));
      expect(analytics.selectedVillageName, equals('หมู่ 1 บ้านท่าตอน'));
      expect(analytics.totalPatients, equals(3)); // P001, P002, P003
      expect(analytics.screenedPatientsCount, equals(2)); // P001, P002
      expect(analytics.totalScreeningsCount, equals(3)); // S001, S002, S003
      // Coverage = 2 / 3 * 100 = 66.7%
      expect(analytics.screeningCoveragePercentage, equals(66.7));
      expect(analytics.pendingReviewsCount, equals(1)); // S002
      expect(analytics.approvedReviewsCount, equals(2)); // S001, S003
      expect(analytics.highRiskPatientsCount, equals(1)); // P001
    });

    test('Constructs high risk priority queue and orders properly', () {
      final analytics = VillageAnalyticsCalculator.compute(
        villages: sampleVillages,
        patients: samplePatients,
        screenings: sampleScreenings,
      );

      final queue = analytics.highRiskPriorityQueue;
      expect(queue.length, equals(2));

      // Both P001 (DM, HT = 2 conditions) and P004 (CVD, OB = 2 conditions)
      // S002 (P001) is on Feb 15, S004 (P004) is on Feb 12 -> S002 first due to date tiebreaker
      expect(queue[0].patient.patientId, equals('P001'));
      expect(
        queue[0].highRiskDiseases,
        containsAll(['โรคเบาหวาน', 'โรคความดันโลหิตสูง']),
      );
      expect(queue[0].highRiskCount, equals(2));

      expect(queue[1].patient.patientId, equals('P004'));
      expect(
        queue[1].highRiskDiseases,
        containsAll(['โรคหลอดเลือดหัวใจ', 'โรคอ้วนลงพุง']),
      );
      expect(queue[1].highRiskCount, equals(2));
    });

    test('Sorts village comparisons according to sort order options', () {
      // 1. highRiskDesc: V001 (1 high risk) & V002 (1 high risk) > V003 (0 high risk)
      final byHighRisk = VillageAnalyticsCalculator.compute(
        villages: sampleVillages,
        patients: samplePatients,
        screenings: sampleScreenings,
        sortOrder: AnalyticsSortOrder.highRiskDesc,
      );
      expect(
        byHighRisk.villageComparisons.last.village.villageId,
        equals('V003'),
      );

      // 2. screeningCoverageDesc: V002 (2/2 = 100%) > V001 (2/3 = 66.7%) > V003 (0/1 = 0%)
      final byCoverage = VillageAnalyticsCalculator.compute(
        villages: sampleVillages,
        patients: samplePatients,
        screenings: sampleScreenings,
        sortOrder: AnalyticsSortOrder.screeningCoverageDesc,
      );
      expect(
        byCoverage.villageComparisons[0].village.villageId,
        equals('V002'),
      );
      expect(
        byCoverage.villageComparisons[0].screeningCoveragePercentage,
        equals(100.0),
      );
      expect(
        byCoverage.villageComparisons[1].village.villageId,
        equals('V001'),
      );
      expect(
        byCoverage.villageComparisons[2].village.villageId,
        equals('V003'),
      );

      // 3. patientCountDesc: V001 (3) > V002 (2) > V003 (1)
      final byPatients = VillageAnalyticsCalculator.compute(
        villages: sampleVillages,
        patients: samplePatients,
        screenings: sampleScreenings,
        sortOrder: AnalyticsSortOrder.patientCountDesc,
      );
      expect(
        byPatients.villageComparisons[0].village.villageId,
        equals('V001'),
      );
      expect(
        byPatients.villageComparisons[1].village.villageId,
        equals('V002'),
      );
      expect(
        byPatients.villageComparisons[2].village.villageId,
        equals('V003'),
      );

      // 4. villageNumberAsc: V001 (1) -> V002 (2) -> V003 (3)
      final byNum = VillageAnalyticsCalculator.compute(
        villages: sampleVillages,
        patients: samplePatients,
        screenings: sampleScreenings,
        sortOrder: AnalyticsSortOrder.villageNumberAsc,
      );
      expect(
        byNum.villageComparisons.map((c) => c.village.villageId).toList(),
        equals(['V001', 'V002', 'V003']),
      );
    });

    test(
      'Handles empty datasets without runtime exceptions or divide by zero',
      () {
        final analytics = VillageAnalyticsCalculator.compute(
          villages: [],
          patients: [],
          screenings: [],
        );

        expect(analytics.totalVillagesCount, equals(0));
        expect(analytics.totalPatients, equals(0));
        expect(analytics.screenedPatientsCount, equals(0));
        expect(analytics.totalScreeningsCount, equals(0));
        expect(analytics.screeningCoveragePercentage, equals(0.0));
        expect(analytics.highRiskPatientsCount, equals(0));
        expect(analytics.pendingReviewsCount, equals(0));
        expect(analytics.approvedReviewsCount, equals(0));
        expect(analytics.highRiskPriorityQueue, isEmpty);
        expect(analytics.villageComparisons, isEmpty);

        final demo = analytics.demographics;
        expect(demo.maleRatio, equals(0.0));
        expect(demo.femaleRatio, equals(0.0));
        expect(demo.ageUnder35Ratio, equals(0.0));

        final dm = analytics.diabetesBreakdown!;
        expect(dm.totalScreened, equals(0));
        expect(dm.lowPercentage, equals(0.0));
        expect(dm.moderatePercentage, equals(0.0));
        expect(dm.highPercentage, equals(0.0));
      },
    );
  });
}
