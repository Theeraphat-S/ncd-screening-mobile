import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/id_generator.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_risk_calculator.dart';
import 'package:ncd_screening_mobile/domain/services/screening_validator.dart';

/// The VHV's answers to the four history questions.
class ScreeningAnswers {
  final String personalNcd; // Q1: มี / ไม่มี / ไม่ทราบ
  final List<String> personalNcdDiseases; // detail when Q1 == มี
  final String drugAllergy; // Q2
  final String foodAllergy; // Q3
  final String familyNcd; // Q4

  const ScreeningAnswers({
    required this.personalNcd,
    this.personalNcdDiseases = const [],
    required this.drugAllergy,
    required this.foodAllergy,
    required this.familyNcd,
  });
}

/// Turns validated form input into a [Screening] with its histories and the
/// risk assessment. Pure logic so it can be tested without a widget.
class ScreeningBuilder {
  const ScreeningBuilder._();

  static Screening build({
    required ScreeningMeasurements measurements,
    required ScreeningAnswers answers,
    required Patient patient,
    required VHV vhv,
    String? screeningId,
    DateTime? now,
  }) {
    final id = screeningId ?? generateId();
    final timestamp = now ?? DateTime.now();
    final m = measurements;
    final bmi = NcdRiskCalculator.calculateBmi(m.weight, m.height);
    final hasPersonalNcd = answers.personalNcd == 'มี';
    final diseaseDetail = answers.personalNcdDiseases.join(', ');

    ScreeningHistory history(int n, String text, String answer) =>
        ScreeningHistory(
          historyId: '${id}_H$n',
          screeningId: id,
          questionId: 'Q00$n',
          questionText: text,
          answerText: answer,
        );

    final histories = [
      history(
        1,
        '1) ประวัติเจ็บป่วย/พบแพทย์ด้วยโรค NCDs',
        hasPersonalNcd ? 'มี ($diseaseDetail)' : answers.personalNcd,
      ),
      history(2, '2) ประวัติแพ้ยา', answers.drugAllergy),
      history(3, '3) ประวัติแพ้อาหาร', answers.foodAllergy),
      history(
        4,
        '4) ญาติตรงสาย (พ่อ/แม่/พี่/น้อง) ป่วยเป็นโรค NCDs',
        answers.familyNcd,
      ),
    ];

    final results = NcdRiskCalculator.evaluateRisk(
      screeningId: id,
      weight: m.weight,
      height: m.height,
      bmi: bmi,
      waistCm: m.waist,
      sbp: m.sbp,
      dbp: m.dbp,
      pulse: m.pulse,
      bloodSugar: m.bloodSugar,
      gender: patient.patientGender,
      hasDirectFamilyNcd: answers.familyNcd == 'มี',
      hasPersonalNcd: hasPersonalNcd,
      personalNcdDetail: diseaseDetail,
    );

    return Screening(
      screenId: id,
      patientId: patient.patientId,
      vhvId: vhv.vhvId,
      screeningDate: timestamp,
      ageAtScreening: patient.age,
      createdAt: timestamp,
      reviewStatus: ReviewStatus.pending,
      weight: m.weight,
      height: m.height,
      bmi: bmi,
      waistCm: m.waist,
      sbp: m.sbp,
      dbp: m.dbp,
      pulse: m.pulse,
      bloodSugar: m.bloodSugar,
      histories: histories,
      results: results,
    );
  }
}
