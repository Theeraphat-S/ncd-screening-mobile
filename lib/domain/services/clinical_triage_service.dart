import 'package:equatable/equatable.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';

enum TriageUrgencyLevel {
  routine,
  moderate,
  urgent,
  emergency,
}

class ClinicalTriageAssessment extends Equatable {
  final TriageUrgencyLevel urgencyLevel;
  final bool requiresImmediateVisit;
  final String urgencyLabel;
  final String clinicalRationale;
  final String recommendedAction;

  const ClinicalTriageAssessment({
    required this.urgencyLevel,
    required this.requiresImmediateVisit,
    required this.urgencyLabel,
    required this.clinicalRationale,
    required this.recommendedAction,
  });

  @override
  List<Object?> get props => [
        urgencyLevel,
        requiresImmediateVisit,
        urgencyLabel,
        clinicalRationale,
        recommendedAction,
      ];
}

class ClinicalTriageService {
  static const String defaultHospitalPhone = '053-459034';
  static const String emergencyHotline = '1669';

  /// Evaluate screening metrics to classify clinical triage urgency.
  static ClinicalTriageAssessment assess({
    required Screening screening,
    required List<ScreeningResult> results,
  }) {
    final sbp = screening.sbp;
    final dbp = screening.dbp;
    final bs = screening.bloodSugar;
    final highRiskCount = results.where((r) => r.riskLevel == RiskLevel.high).length;

    // 1. Emergency: Hypertensive Crisis or Severe Hyperglycemia with symptoms
    if (sbp >= 180 || dbp >= 110) {
      return ClinicalTriageAssessment(
        urgencyLevel: TriageUrgencyLevel.emergency,
        requiresImmediateVisit: true,
        urgencyLabel: 'ภาวะวิกฤตความดันโลหิตสูง (Hypertensive Crisis)',
        clinicalRationale: 'ความดันโลหิต ${sbp.toInt()}/${dbp.toInt()} มม.ปรอท สูงเกินเกณฑ์อันตราย เสี่ยงหลอดเลือดสมองแตก',
        recommendedAction: 'ส่งตัวพบแพทย์ รพ.สต. หรือ รพ.แม่อาย ทันที และพยาบาลลงเยี่ยมบ้านด่วน',
      );
    }

    if (bs != null && bs >= 250) {
      return ClinicalTriageAssessment(
        urgencyLevel: TriageUrgencyLevel.emergency,
        requiresImmediateVisit: true,
        urgencyLabel: 'ภาวะน้ำตาลในเลือดสูงวิกฤต (Severe Hyperglycemia)',
        clinicalRationale: 'ค่าน้ำตาลในเลือด $bs มก./ดล. สูงผิดปกติ เสี่ยงต่อภาวะเลือดเป็นกรด',
        recommendedAction: 'นำส่ง รพ.สต. เพื่อตรวจยืนยันและรับการรักษาทันที',
      );
    }

    // 2. Urgent: Multi-NCD High Risk (>= 2 high risk diseases)
    if (highRiskCount >= 2) {
      return ClinicalTriageAssessment(
        urgencyLevel: TriageUrgencyLevel.urgent,
        requiresImmediateVisit: true,
        urgencyLabel: 'กลุ่มเสี่ยงสูงหลายโรคพร้อมกัน (Multi-NCD High Risk)',
        clinicalRationale: 'พบความเสี่ยงระดับสูง $highRiskCount โรคพร้อมกัน',
        recommendedAction: 'จัดเข้าคิวพยาบาลลงตรวจเยี่ยมบ้านภายใน 3-7 วัน',
      );
    }

    // 3. Moderate: Single High Risk or Elevated Vitals
    if (highRiskCount == 1 || sbp >= 140 || dbp >= 90 || (bs != null && bs >= 126)) {
      return const ClinicalTriageAssessment(
        urgencyLevel: TriageUrgencyLevel.moderate,
        requiresImmediateVisit: false,
        urgencyLabel: 'กลุ่มเสี่ยงระดับสูงรายโรค (High Risk)',
        clinicalRationale: 'พบความเสี่ยงโรคเรื้อรังสูง 1 โรค ควรได้รับการตรวจยืนยัน',
        recommendedAction: 'นัดหมายตรวจซ้ำที่ รพ.สต. ภายใน 2 สัปดาห์',
      );
    }

    // 4. Routine
    return const ClinicalTriageAssessment(
      urgencyLevel: TriageUrgencyLevel.routine,
      requiresImmediateVisit: false,
      urgencyLabel: 'กลุ่มปกติ / เสี่ยงต่ำ (Routine)',
      clinicalRationale: 'สัญญาณชีพและผลการประเมินอยู่ในเกณฑ์ควบคุมได้',
      recommendedAction: 'ติดตามตรวจคัดกรองประจำปีตามรอบ อสม.',
    );
  }

  /// Generate JSON payload formatted for LINE Notify / Health Center Webhook dispatch.
  static Map<String, dynamic> generateLineWebhookPayload({
    required Patient patient,
    required Screening screening,
    required ClinicalTriageAssessment triage,
  }) {
    return {
      'event': 'CLINICAL_TRIAGE_ALERT',
      'timestamp': DateTime.now().toIso8601String(),
      'hospital': 'รพ.สต.แม่อาย',
      'urgency': triage.urgencyLevel.name,
      'patient': {
        'id': patient.patientId,
        'name': patient.fullName,
        'citizenId': patient.patientCitizenId,
        'villageId': patient.villageId,
        'mobile': patient.patientMobile,
      },
      'vitals': {
        'sbp': screening.sbp,
        'dbp': screening.dbp,
        'bloodSugar': screening.bloodSugar,
        'bmi': screening.bmi,
      },
      'triage': {
        'label': triage.urgencyLabel,
        'rationale': triage.clinicalRationale,
        'action': triage.recommendedAction,
        'requiresImmediateVisit': triage.requiresImmediateVisit,
      },
      'message': '🚨 [แจ้งเตือนเคสด่วน] ${triage.urgencyLabel}\nผู้ป่วย: ${patient.fullName} (หมู่ ${patient.villageId})\nBP: ${screening.sbp.toInt()}/${screening.dbp.toInt()} mmHg, Sugar: ${screening.bloodSugar ?? 'ไม่ได้ตรวจ'} mg/dL\nการดำเนินการ: ${triage.recommendedAction}',
    };
  }
}
