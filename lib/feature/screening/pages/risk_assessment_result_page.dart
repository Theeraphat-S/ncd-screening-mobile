import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/clinical_triage_service.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_lifestyle_advisor.dart';
import 'package:ncd_screening_mobile/feature/patient/bloc/patient_bloc.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/vhv_patient_list_page.dart';
import 'package:ncd_screening_mobile/feature/screening/pages/pdf_preview_page.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/widgets/elderly_bento_advice_card.dart';
import 'package:ncd_screening_mobile/shared/widgets/emergency_hospital_card.dart';

import 'package:ncd_screening_mobile/shared/widgets/patient_accessibility_floating_bubble.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

class RiskAssessmentResultPage extends StatelessWidget {
  final Patient patient;
  final Screening screening;
  final VHV? vhv;

  const RiskAssessmentResultPage({
    super.key,
    required this.patient,
    required this.screening,
    this.vhv,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColor.backgroundColor,
      appBar: AppBar(
        title: const Text('แนวโน้มความเสี่ยง'),
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: PSpacing.md, horizontal: PSpacing.xs),
            child: AccessibilityScaleToggle(),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
            tooltip: 'ส่งออก/พิมพ์รายงาน PDF',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PdfPreviewPage(
                    patient: patient,
                    screening: screening,
                    vhv: vhv,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: PSpacing.xl, vertical: PSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              // Emergency Hospital Card if Triage Alert
              EmergencyHospitalCard(
                triage: ClinicalTriageService.assess(
                  screening: screening,
                  results: screening.results,
                ),
              ),

              // Step Indicator
              _buildStepIndicator(),
              PSpacing.gapVerticalLg,

              // Patient Header Card
              Container(
                padding: const EdgeInsets.all(PSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(PRadius.lg),
                  border: Border.all(color: PColor.borderSubtle),
                  boxShadow: PShadow.card,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: PColor.primaryLight,
                        borderRadius: BorderRadius.circular(PRadius.md),
                      ),
                      child: Center(
                        child: Text(
                          patient.patientFname.isNotEmpty ? patient.patientFname.substring(0, 1) : 'P',
                          style: PTypography.emphasisPrimary,
                        ),
                      ),
                    ),
                    PSpacing.gapHorizontalLg,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ผู้ป่วย: ${patient.fullName}',
                            style: PTypography.sectionHeader,
                          ),
                          PSpacing.gapVerticalXs,
                          Text(
                            'เลขบัตร: ${patient.patientCitizenId} • อายุ ${screening.ageAtScreening} ปี',
                            style: PTypography.captionSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              PSpacing.gapVerticalXl,

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: PSpacing.xs, vertical: PSpacing.xs),
                child: Text(
                  'มีแนวโน้มความเสี่ยงที่จะเป็น',
                  style: PTypography.sectionHeader,
                ),
              ),
              PSpacing.gapVerticalSm,

              // 4 Disease Risk Cards
              ...screening.results.map(_buildDiseaseCard),

              PSpacing.gapVerticalXl,

              // Plain Thai Lifestyle Guidance Header (Elderly Friendly)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(PSpacing.sm),
                    decoration: BoxDecoration(
                      color: PColor.primaryLight,
                      borderRadius: BorderRadius.circular(PRadius.sm),
                    ),
                    child: const Icon(Icons.tips_and_updates_rounded, color: PColor.primaryDark, size: 18),
                  ),
                  PSpacing.gapHorizontalSm,
                  const Expanded(
                    child: Text(
                      'คำแนะนำสุขภาพและการปฏิบัติตัวเฉพาะบุคคล',
                      style: PTypography.sectionHeader,
                    ),
                  ),
                ],
              ),
              PSpacing.gapVerticalMd,

              // Plain Thai Bento Cards
              ...NcdLifestyleAdvisor.generateAdviceList(
                screening: screening,
                results: screening.results,
              ).map((adv) => ElderlyBentoAdviceCard(advice: adv)),

              PSpacing.gapVerticalMd,

              // PDF Export Action Button
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PdfPreviewPage(
                          patient: patient,
                          screening: screening,
                          vhv: vhv,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf_outlined, color: PColor.primaryColor, size: 20),
                  label: const Text(
                    'ดูตัวอย่างและพิมพ์รายงาน PDF (Export PDF)',
                    style: PTypography.actionPrimary,
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: PColor.primaryColor, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(PRadius.md),
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              PSpacing.gapVerticalMd,

              // Back to Patient List Button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (vhv != null) {
                      context.read<PatientBloc>().add(
                            PatientLoadRequested(villageId: vhv!.villageId),
                          );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VhvPatientListPage(vhv: vhv!),
                        ),
                        (route) => route.isFirst,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PColor.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(PRadius.md),
                    ),
                  ),
                  child: const Text(
                    'กลับไปหน้ารายชื่อผู้ป่วย',
                    style: PTypography.buttonOnPrimary,
                  ),
                ),
              ),
              PSpacing.gapVerticalXl,
            ],
          ),
        ),
      ),
      const PatientAccessibilityFloatingBubble(),
    ],
  ),
);
}

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: PSpacing.lg, horizontal: PSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PRadius.lg),
        border: Border.all(color: PColor.borderSubtle),
        boxShadow: PShadow.card,
      ),
      child: Semantics(
        label: 'ขั้นตอนที่ 3 จาก 3 เสร็จสิ้น แสดงผลการประเมิน',
        excludeSemantics: true,
        // Progress strip, not content: clamp so three labels fit a narrow
        // phone at maximum system text size.
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepItem(number: '1', label: 'ข้อมูลผู้ป่วย', isDone: true),
              _buildStepLine(isActive: true),
              _buildStepItem(number: '2', label: 'แบบคัดกรอง', isDone: true),
              _buildStepLine(isActive: true),
              _buildStepItem(number: '3', label: 'ผลการประเมิน', isDone: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required String number,
    required String label,
    bool isDone = false,
  }) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? PColor.primaryColor : PColor.surfaceSubtle,
            border: Border.all(
              color: isDone ? PColor.primaryColor : PColor.borderSubtle,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    number,
                    style: PTypography.captionStrong,
                  ),
          ),
        ),
        PSpacing.gapVerticalXs,
        Text(
          label,
          style: PTypography.captionBold,
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: PSpacing.xl),
        color: PColor.primaryColor,
      ),
    );
  }

  Widget _buildDiseaseCard(ScreeningResult result) {
    Color badgeColor;
    Color badgeBg;
    IconData diseaseIcon;

    switch (result.riskLevel) {
      case RiskLevel.high:
        badgeColor = PColor.riskHigh;
        badgeBg = PColor.riskHighBg;
        break;
      case RiskLevel.moderate:
        badgeColor = PColor.riskModerate;
        badgeBg = PColor.riskModerateBg;
        break;
      case RiskLevel.low:
        badgeColor = PColor.riskLow;
        badgeBg = PColor.riskLowBg;
        break;
    }
    // A missing measurement is not "low risk": show it as neutral/unknown.
    if (result.isIncomplete) {
      badgeColor = PColor.textNeutralColor;
      badgeBg = PColor.surfaceSubtle;
    }

    if (result.diseaseName.contains('เบาหวาน')) {
      diseaseIcon = Icons.water_drop_outlined;
    } else if (result.diseaseName.contains('ความดัน')) {
      diseaseIcon = Icons.speed_rounded;
    } else if (result.diseaseName.contains('หลอดเลือดหัวใจ')) {
      diseaseIcon = Icons.favorite_rounded;
    } else {
      diseaseIcon = Icons.monitor_weight_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: PSpacing.md),
      padding: const EdgeInsets.all(PSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PRadius.lg),
        border: Border.all(color: PColor.borderSubtle),
        boxShadow: PShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(PSpacing.sm),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(PRadius.md),
                ),
                child: Icon(diseaseIcon, color: badgeColor, size: 20),
              ),
              PSpacing.gapHorizontalMd,
              Expanded(
                child: Text(
                  result.diseaseName,
                  style: PTypography.sectionHeader,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: PSpacing.md, vertical: PSpacing.xs),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(PRadius.xl),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  result.isIncomplete
                      ? 'ข้อมูลไม่ครบ'
                      : 'ความเสี่ยง${result.riskLevel.labelTh}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          PSpacing.gapVerticalMd,
          Text(
            result.criteriaText,
            style: PTypography.captionSecondary,
          ),
          if (result.adviceText.isNotEmpty) ...[
            PSpacing.gapVerticalMd,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: PSpacing.md, vertical: PSpacing.md),
              decoration: BoxDecoration(
                color: PColor.surfaceSubtle,
                borderRadius: BorderRadius.circular(PRadius.md),
                border: Border.all(color: PColor.borderSubtle),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: PColor.primaryColor),
                  PSpacing.gapHorizontalSm,
                  Expanded(
                    child: Text(
                      'คำแนะนำ: ${result.adviceText}',
                      style: PTypography.captionContent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
