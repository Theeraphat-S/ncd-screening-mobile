import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';

class NcdRiskCalculator {
  /// Calculate BMI = weight (kg) / (height (m) ^ 2)
  static double calculateBmi(double weightKg, double heightCm) {
    if (heightCm <= 0) return 0.0;
    final heightM = heightCm / 100.0;
    final bmi = weightKg / (heightM * heightM);
    return double.parse(bmi.toStringAsFixed(1));
  }

  /// Assess 4 NCDs risk based on biometrics and questionnaires
  static List<ScreeningResult> evaluateRisk({
    required String screeningId,
    required double weight,
    required double height,
    required double bmi,
    required double waistCm,
    required double sbp,
    required double dbp,
    required double pulse,
    double? bloodSugar,
    required String gender,
    bool hasDirectFamilyNcd = false,
    bool hasPersonalNcd = false,
    String? personalNcdDetail,
  }) {
    final results = <ScreeningResult>[];

    // 1. โรคเบาหวาน (Diabetes)
    RiskLevel dmRisk;
    String dmCriteria;
    String dmAdvice;
    int dmScore = 0;

    final hasDiabetesHistory =
        hasPersonalNcd && (personalNcdDetail?.contains('เบาหวาน') ?? false);

    if (bloodSugar == null && !hasDiabetesHistory) {
      // No glucose reading and no known diabetes: do not call it "low risk".
      dmRisk = RiskLevel.low;
      dmCriteria =
          'ข้อมูลไม่ครบ: ไม่ได้ตรวจระดับน้ำตาลในเลือด จึงประเมินเบาหวานจากค่าตรวจไม่ได้';
      dmAdvice = 'ควรตรวจระดับน้ำตาลในเลือด (FBS) เพื่อประเมินความเสี่ยงเบาหวานให้ครบถ้วน';
      dmScore = 0;
    } else if (bloodSugar == null) {
      dmRisk = RiskLevel.high;
      dmCriteria =
          'มีประวัติเป็นโรคเบาหวาน (ไม่ได้ตรวจระดับน้ำตาลในเลือดครั้งนี้ ประเมินจากประวัติ)';
      dmAdvice = 'มีประวัติเบาหวาน ควรพบแพทย์เพื่อติดตามการรักษาและตรวจระดับน้ำตาล';
      dmScore = 3;
    } else if (bloodSugar >= 126 || hasDiabetesHistory) {
      dmRisk = RiskLevel.high;
      dmCriteria = 'ค่าน้ำตาลในเลือด ≥ 126 mg/dL (ปัจจุบัน ${bloodSugar.toStringAsFixed(0)} mg/dL)';
      dmAdvice = 'สงสัยโรคเบาหวาน ควรพบแพทย์เพื่อตรวจยืนยันและรับการรักษา';
      dmScore = 3;
    } else if (bloodSugar >= 100) {
      dmRisk = RiskLevel.moderate;
      dmCriteria = 'ค่าน้ำตาลในเลือด 100–125 mg/dL (ปัจจุบัน ${bloodSugar.toStringAsFixed(0)} mg/dL)';
      dmAdvice = 'กลุ่มเสี่ยงเบาหวาน แนะนำลดอาหารหวานมันเค็ม ติดตามระดับน้ำตาลสม่ำเสมอ';
      dmScore = 2;
    } else {
      dmRisk = RiskLevel.low;
      dmCriteria = 'ค่าน้ำตาลในเลือด < 100 mg/dL (ปัจจุบัน ${bloodSugar.toStringAsFixed(0)} mg/dL)';
      dmAdvice = 'ค่าน้ำตาลในเลือดอยู่ในเกณฑ์ปกติ รักษาสุขภาพและรับประทานอาหารที่มีประโยชน์';
      dmScore = 1;
    }

    results.add(ScreeningResult(
      resultId: '${screeningId}_DM',
      screeningId: screeningId,
      diseaseName: 'โรคเบาหวาน',
      diseaseCode: 'DIABETES',
      score: dmScore,
      riskLevel: dmRisk,
      adviceText: dmAdvice,
      criteriaText: dmCriteria,
    ));

    // 2. โรคความดันโลหิตสูง (Hypertension)
    RiskLevel htRisk;
    String htCriteria;
    String htAdvice;
    int htScore = 0;

    if (sbp >= 140 || dbp >= 90) {
      htRisk = RiskLevel.high;
      htCriteria = 'เกณฑ์: SBP ≥ 140 หรือ DBP ≥ 90 (ค่าที่วัดได้: $sbp/$dbp mmHg)';
      htAdvice = 'ความดันโลหิตสูง ควรพบแพทย์หรือเจ้าหน้าที่สาธารณสุขเพื่อประเมินซ้ำ';
      htScore = 3;
    } else if (sbp >= 120 || dbp >= 80) {
      htRisk = RiskLevel.moderate;
      htCriteria = 'เกณฑ์: SBP 120–139 หรือ DBP 80–89 mmHg (ค่าที่วัดได้: $sbp/$dbp mmHg)';
      htAdvice = 'กลุ่มเสี่ยงความดันโลหิตสูง (Pre-hypertension) ควรปรับพฤติกรรม ลดการบริโภคโซเดียม';
      htScore = 2;
    } else {
      htRisk = RiskLevel.low;
      htCriteria = 'เกณฑ์: SBP < 120 และ DBP < 80 mmHg (ค่าที่วัดได้: $sbp/$dbp mmHg)';
      htAdvice = 'ความดันโลหิตอยู่ในเกณฑ์ปกติ รักษาวิถีชีวิตสุขภาพดีต่อเนื่อง';
      htScore = 1;
    }

    results.add(ScreeningResult(
      resultId: '${screeningId}_HT',
      screeningId: screeningId,
      diseaseName: 'โรคความดันโลหิตสูง',
      diseaseCode: 'HYPERTENSION',
      score: htScore,
      riskLevel: htRisk,
      adviceText: htAdvice,
      criteriaText: htCriteria,
    ));

    // 3. โรคอ้วนลงพุง (Metabolic Syndrome / Obesity)
    RiskLevel obesityRisk;
    String obesityCriteria;
    String obesityAdvice;
    int obesityScore = 0;

    final isMale = gender.contains('ชาย');
    final waistThreshold = isMale ? 90.0 : 80.0;
    final isWaistOver = waistCm >= waistThreshold;
    final isBmiOver = bmi >= 25.0;

    if (isWaistOver || isBmiOver) {
      obesityRisk = RiskLevel.high;
      obesityCriteria = 'เข้าเกณฑ์ (BMI ≥ 25 หรือ รอบเอว ≥ $waistThreshold ซม.) (ปัจจุบัน BMI $bmi, รอบเอว $waistCm ซม.)';
      obesityAdvice = 'เข้าเกณฑ์อ้วนลงพุง แนะนำควบคุมอาหาร ลดของทอด ของหวาน และออกกำลังกายสม่ำเสมอ';
      obesityScore = 3;
    } else if (bmi >= 23.0) {
      obesityRisk = RiskLevel.moderate;
      obesityCriteria = 'น้ำหนักเกินเกณฑ์มาตรฐานเอเชีย (BMI 23.0–24.9) (ปัจจุบัน BMI $bmi)';
      obesityAdvice = 'เริ่มมีน้ำหนักเกินเกณฑ์ ควรเพิ่มกิจกรรมทางกายและควบคุมปริมาณแคลอรี';
      obesityScore = 2;
    } else {
      obesityRisk = RiskLevel.low;
      obesityCriteria = 'รอบเอวไม่เกินเกณฑ์ ($waistCm ซม.) และ BMI < 23 ($bmi kg/m²)';
      obesityAdvice = 'ยังไม่เข้าเกณฑ์อ้วนลงพุง รักษาระดับน้ำหนักและดัชนีมวลกายให้สมดุล';
      obesityScore = 1;
    }

    results.add(ScreeningResult(
      resultId: '${screeningId}_OBESITY',
      screeningId: screeningId,
      diseaseName: 'โรคอ้วนลงพุง',
      diseaseCode: 'METABOLIC_OBESITY',
      score: obesityScore,
      riskLevel: obesityRisk,
      adviceText: obesityAdvice,
      criteriaText: obesityCriteria,
    ));

    // 4. โรคหลอดเลือดหัวใจ (Cardiovascular Disease - CVD)
    int cvdRiskCount = 0;
    if (sbp >= 140 || dbp >= 90) cvdRiskCount++;
    if ((bloodSugar ?? 0) >= 126) cvdRiskCount++;
    if (isWaistOver || isBmiOver) cvdRiskCount++;
    if (pulse > 100 || pulse < 60) cvdRiskCount++;
    if (hasDirectFamilyNcd) cvdRiskCount++;
    if (hasPersonalNcd) cvdRiskCount++;

    RiskLevel cvdRisk;
    String cvdCriteria;
    String cvdAdvice;

    if (cvdRiskCount >= 3) {
      cvdRisk = RiskLevel.high;
      cvdCriteria = 'มีปัจจัยเสี่ยง $cvdRiskCount ข้อ (BP $sbp/$dbp, น้ำตาล ${bloodSugar ?? 'ไม่ได้ตรวจ'} mg/dL, ชีพจร $pulse bpm)';
      cvdAdvice = 'มีความเสี่ยงสูงต่อโรคหลอดเลือดหัวใจ แนะนำให้พบแพทย์ตรวจระบบหัวใจและหลอดเลือดอย่างละเอียด';
    } else if (cvdRiskCount >= 2) {
      cvdRisk = RiskLevel.moderate;
      cvdCriteria = 'มีปัจจัยเสี่ยง $cvdRiskCount ข้อ (BP $sbp/$dbp, รอบเอว $waistCm ซม.)';
      cvdAdvice = 'มีความเสี่ยงปานกลาง ควรควบคุมปัจจัยเสี่ยงหลัก เช่น ความดันและระดับน้ำตาล';
    } else {
      cvdRisk = RiskLevel.low;
      cvdCriteria = 'มีปัจจัยเสี่ยงน้อยกว่า 2 ข้อ (BP $sbp/$dbp, ชีพจร $pulse bpm)';
      cvdAdvice = 'ยังไม่พบความเสี่ยงสูงต่อโรคหลอดเลือดหัวใจ ออกกำลังกายและตรวจสุขภาพประจำปี';
    }

    results.add(ScreeningResult(
      resultId: '${screeningId}_CVD',
      screeningId: screeningId,
      diseaseName: 'โรคหลอดเลือดหัวใจ',
      diseaseCode: 'CVD',
      score: cvdRiskCount,
      riskLevel: cvdRisk,
      adviceText: cvdAdvice,
      criteriaText: cvdCriteria,
    ));

    return results;
  }
}
