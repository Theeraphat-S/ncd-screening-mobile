import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_risk_calculator.dart';

void main() {
  group('NcdRiskCalculator - BMI Calculation', () {
    test('calculates BMI correctly with standard weight and height', () {
      // 60 kg, 175 cm -> 60 / (1.75 * 1.75) = 19.5918... -> 19.6
      final bmi = NcdRiskCalculator.calculateBmi(60, 175);
      expect(bmi, equals(19.6));
    });

    test('calculates BMI for overweight scenario', () {
      // 80 kg, 160 cm -> 80 / (1.6 * 1.6) = 31.25 -> 31.2 or 31.3
      final bmi = NcdRiskCalculator.calculateBmi(80, 160);
      expect(bmi, isIn([31.2, 31.3]));
    });

    test('returns 0.0 when height is 0 or negative', () {
      expect(NcdRiskCalculator.calculateBmi(70, 0), equals(0.0));
      expect(NcdRiskCalculator.calculateBmi(70, -150), equals(0.0));
    });
  });

  group('NcdRiskCalculator - Diabetes (DM) Risk Assessment', () {
    test('blood sugar < 100 mg/dL should evaluate to Low risk (Score 1)', () {
      final results = NcdRiskCalculator.evaluateRisk(
        screeningId: 'test_dm_low',
        weight: 60,
        height: 170,
        bmi: 20.8,
        waistCm: 75,
        sbp: 115,
        dbp: 75,
        pulse: 72,
        bloodSugar: 95,
        gender: 'ชาย',
      );

      final dmResult = results.firstWhere((r) => r.diseaseCode == 'DIABETES');
      expect(dmResult.riskLevel, equals(RiskLevel.low));
      expect(dmResult.score, equals(1));
      expect(dmResult.criteriaText, contains('< 100 mg/dL'));
    });

    test(
      'blood sugar 100–125 mg/dL should evaluate to Moderate risk (Score 2)',
      () {
        final resultsBoundary100 = NcdRiskCalculator.evaluateRisk(
          screeningId: 'test_dm_mod_100',
          weight: 60,
          height: 170,
          bmi: 20.8,
          waistCm: 75,
          sbp: 115,
          dbp: 75,
          pulse: 72,
          bloodSugar: 100,
          gender: 'หญิง',
        );
        final dmMod100 = resultsBoundary100.firstWhere(
          (r) => r.diseaseCode == 'DIABETES',
        );
        expect(dmMod100.riskLevel, equals(RiskLevel.moderate));
        expect(dmMod100.score, equals(2));

        final resultsBoundary125 = NcdRiskCalculator.evaluateRisk(
          screeningId: 'test_dm_mod_125',
          weight: 60,
          height: 170,
          bmi: 20.8,
          waistCm: 75,
          sbp: 115,
          dbp: 75,
          pulse: 72,
          bloodSugar: 125,
          gender: 'หญิง',
        );
        final dmMod125 = resultsBoundary125.firstWhere(
          (r) => r.diseaseCode == 'DIABETES',
        );
        expect(dmMod125.riskLevel, equals(RiskLevel.moderate));
        expect(dmMod125.score, equals(2));
      },
    );

    test('blood sugar >= 126 mg/dL should evaluate to High risk (Score 3)', () {
      final results = NcdRiskCalculator.evaluateRisk(
        screeningId: 'test_dm_high',
        weight: 60,
        height: 170,
        bmi: 20.8,
        waistCm: 75,
        sbp: 115,
        dbp: 75,
        pulse: 72,
        bloodSugar: 126,
        gender: 'ชาย',
      );

      final dmResult = results.firstWhere((r) => r.diseaseCode == 'DIABETES');
      expect(dmResult.riskLevel, equals(RiskLevel.high));
      expect(dmResult.score, equals(3));
    });

    test(
      'patient with known personal history of Diabetes is evaluated as High risk even if blood sugar is normal',
      () {
        final results = NcdRiskCalculator.evaluateRisk(
          screeningId: 'test_dm_history',
          weight: 60,
          height: 170,
          bmi: 20.8,
          waistCm: 75,
          sbp: 115,
          dbp: 75,
          pulse: 72,
          bloodSugar: 90,
          gender: 'ชาย',
          hasPersonalNcd: true,
          personalNcdDetail: 'เบาหวาน',
        );

        final dmResult = results.firstWhere((r) => r.diseaseCode == 'DIABETES');
        expect(dmResult.riskLevel, equals(RiskLevel.high));
        expect(dmResult.score, equals(3));
      },
    );
  });

  group('NcdRiskCalculator - Hypertension (HT) Risk Assessment', () {
    test('SBP < 120 and DBP < 80 should evaluate to Low risk (Score 1)', () {
      final results = NcdRiskCalculator.evaluateRisk(
        screeningId: 'test_ht_low',
        weight: 60,
        height: 170,
        bmi: 20.8,
        waistCm: 75,
        sbp: 118,
        dbp: 78,
        pulse: 72,
        bloodSugar: 90,
        gender: 'ชาย',
      );

      final htResult = results.firstWhere(
        (r) => r.diseaseCode == 'HYPERTENSION',
      );
      expect(htResult.riskLevel, equals(RiskLevel.low));
      expect(htResult.score, equals(1));
    });

    test(
      'SBP 120-139 or DBP 80-89 should evaluate to Moderate risk (Pre-HT, Score 2)',
      () {
        // SBP in range, DBP normal
        final results1 = NcdRiskCalculator.evaluateRisk(
          screeningId: 'test_ht_mod_1',
          weight: 60,
          height: 170,
          bmi: 20.8,
          waistCm: 75,
          sbp: 125,
          dbp: 75,
          pulse: 72,
          bloodSugar: 90,
          gender: 'ชาย',
        );
        final ht1 = results1.firstWhere((r) => r.diseaseCode == 'HYPERTENSION');
        expect(ht1.riskLevel, equals(RiskLevel.moderate));
        expect(ht1.score, equals(2));

        // SBP normal, DBP in range
        final results2 = NcdRiskCalculator.evaluateRisk(
          screeningId: 'test_ht_mod_2',
          weight: 60,
          height: 170,
          bmi: 20.8,
          waistCm: 75,
          sbp: 115,
          dbp: 85,
          pulse: 72,
          bloodSugar: 90,
          gender: 'ชาย',
        );
        final ht2 = results2.firstWhere((r) => r.diseaseCode == 'HYPERTENSION');
        expect(ht2.riskLevel, equals(RiskLevel.moderate));
        expect(ht2.score, equals(2));
      },
    );

    test('SBP >= 140 or DBP >= 90 should evaluate to High risk (Score 3)', () {
      final resultsSbpHigh = NcdRiskCalculator.evaluateRisk(
        screeningId: 'test_ht_high_sbp',
        weight: 60,
        height: 170,
        bmi: 20.8,
        waistCm: 75,
        sbp: 140,
        dbp: 80,
        pulse: 72,
        bloodSugar: 90,
        gender: 'หญิง',
      );
      final htSbp = resultsSbpHigh.firstWhere(
        (r) => r.diseaseCode == 'HYPERTENSION',
      );
      expect(htSbp.riskLevel, equals(RiskLevel.high));
      expect(htSbp.score, equals(3));

      final resultsDbpHigh = NcdRiskCalculator.evaluateRisk(
        screeningId: 'test_ht_high_dbp',
        weight: 60,
        height: 170,
        bmi: 20.8,
        waistCm: 75,
        sbp: 130,
        dbp: 92,
        pulse: 72,
        bloodSugar: 90,
        gender: 'หญิง',
      );
      final htDbp = resultsDbpHigh.firstWhere(
        (r) => r.diseaseCode == 'HYPERTENSION',
      );
      expect(htDbp.riskLevel, equals(RiskLevel.high));
      expect(htDbp.score, equals(3));
    });
  });

  group('NcdRiskCalculator - Metabolic Obesity Risk Assessment', () {
    test('Male: waist >= 90 cm or BMI >= 25 -> High risk (Score 3)', () {
      // High waist
      final resWaist = NcdRiskCalculator.evaluateRisk(
        screeningId: 'test_ob_male_waist',
        weight: 65,
        height: 170,
        bmi: 22.5,
        waistCm: 90,
        sbp: 110,
        dbp: 70,
        pulse: 70,
        bloodSugar: 90,
        gender: 'ชาย',
      );
      final obWaist = resWaist.firstWhere(
        (r) => r.diseaseCode == 'METABOLIC_OBESITY',
      );
      expect(obWaist.riskLevel, equals(RiskLevel.high));
      expect(obWaist.score, equals(3));

      // High BMI
      final resBmi = NcdRiskCalculator.evaluateRisk(
        screeningId: 'test_ob_male_bmi',
        weight: 80,
        height: 170,
        bmi: 27.7,
        waistCm: 85,
        sbp: 110,
        dbp: 70,
        pulse: 70,
        bloodSugar: 90,
        gender: 'ชาย',
      );
      final obBmi = resBmi.firstWhere(
        (r) => r.diseaseCode == 'METABOLIC_OBESITY',
      );
      expect(obBmi.riskLevel, equals(RiskLevel.high));
      expect(obBmi.score, equals(3));
    });

    test('Female: waist >= 80 cm or BMI >= 25 -> High risk (Score 3)', () {
      final resWaist = NcdRiskCalculator.evaluateRisk(
        screeningId: 'test_ob_female_waist',
        weight: 55,
        height: 160,
        bmi: 21.5,
        waistCm: 80,
        sbp: 110,
        dbp: 70,
        pulse: 70,
        bloodSugar: 90,
        gender: 'หญิง',
      );
      final obWaist = resWaist.firstWhere(
        (r) => r.diseaseCode == 'METABOLIC_OBESITY',
      );
      expect(obWaist.riskLevel, equals(RiskLevel.high));
      expect(obWaist.score, equals(3));
    });

    test('BMI 23.0–24.9 with normal waist -> Moderate risk (Score 2)', () {
      final res = NcdRiskCalculator.evaluateRisk(
        screeningId: 'test_ob_mod',
        weight: 65,
        height: 166,
        bmi: 23.6,
        waistCm: 76,
        sbp: 110,
        dbp: 70,
        pulse: 70,
        bloodSugar: 90,
        gender: 'หญิง',
      );
      final ob = res.firstWhere((r) => r.diseaseCode == 'METABOLIC_OBESITY');
      expect(ob.riskLevel, equals(RiskLevel.moderate));
      expect(ob.score, equals(2));
    });

    test('Normal BMI (< 23) and normal waist -> Low risk (Score 1)', () {
      final res = NcdRiskCalculator.evaluateRisk(
        screeningId: 'test_ob_low',
        weight: 50,
        height: 160,
        bmi: 19.5,
        waistCm: 68,
        sbp: 110,
        dbp: 70,
        pulse: 70,
        bloodSugar: 90,
        gender: 'หญิง',
      );
      final ob = res.firstWhere((r) => r.diseaseCode == 'METABOLIC_OBESITY');
      expect(ob.riskLevel, equals(RiskLevel.low));
      expect(ob.score, equals(1));
    });
  });

  group('NcdRiskCalculator - Cardiovascular Disease (CVD) Risk Assessment', () {
    test('0 or 1 risk factor -> Low risk', () {
      // 0 risk factors
      final res0 = NcdRiskCalculator.evaluateRisk(
        screeningId: 'test_cvd_0',
        weight: 55,
        height: 165,
        bmi: 20.2,
        waistCm: 70,
        sbp: 110,
        dbp: 70,
        pulse: 72,
        bloodSugar: 90,
        gender: 'ชาย',
      );
      final cvd0 = res0.firstWhere((r) => r.diseaseCode == 'CVD');
      expect(cvd0.riskLevel, equals(RiskLevel.low));
      expect(cvd0.score, equals(0));

      // 1 risk factor (Abnormal pulse > 100)
      final res1 = NcdRiskCalculator.evaluateRisk(
        screeningId: 'test_cvd_1',
        weight: 55,
        height: 165,
        bmi: 20.2,
        waistCm: 70,
        sbp: 110,
        dbp: 70,
        pulse: 105,
        bloodSugar: 90,
        gender: 'ชาย',
      );
      final cvd1 = res1.firstWhere((r) => r.diseaseCode == 'CVD');
      expect(cvd1.riskLevel, equals(RiskLevel.low));
      expect(cvd1.score, equals(1));
    });

    test('2 risk factors -> Moderate risk', () {
      // 2 risk factors: HT (SBP 145) and Fasting Blood Sugar (130)
      final res = NcdRiskCalculator.evaluateRisk(
        screeningId: 'test_cvd_2',
        weight: 55,
        height: 165,
        bmi: 20.2,
        waistCm: 70,
        sbp: 145,
        dbp: 80,
        pulse: 75,
        bloodSugar: 130,
        gender: 'ชาย',
      );
      final cvd = res.firstWhere((r) => r.diseaseCode == 'CVD');
      expect(cvd.riskLevel, equals(RiskLevel.moderate));
      expect(cvd.score, equals(2));
    });

    test('>= 3 risk factors -> High risk', () {
      // 4+ risk factors: SBP 145, Blood Sugar 140, Waist >= 90, Family NCD history, Personal NCD
      final res = NcdRiskCalculator.evaluateRisk(
        screeningId: 'test_cvd_high',
        weight: 80,
        height: 170,
        bmi: 27.7,
        waistCm: 92,
        sbp: 145,
        dbp: 95,
        pulse: 108,
        bloodSugar: 140,
        gender: 'ชาย',
        hasDirectFamilyNcd: true,
        hasPersonalNcd: true,
      );
      final cvd = res.firstWhere((r) => r.diseaseCode == 'CVD');
      expect(cvd.riskLevel, equals(RiskLevel.high));
      expect(cvd.score, greaterThanOrEqualTo(3));
    });
  });
}
