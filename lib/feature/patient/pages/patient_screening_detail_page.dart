import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/clinical_triage_service.dart';
import 'package:ncd_screening_mobile/feature/patient/widgets/screening_detail/screening_detail_widgets.dart';
import 'package:ncd_screening_mobile/feature/screening/bloc/screening_bloc.dart';
import 'package:ncd_screening_mobile/feature/screening/pages/pdf_preview_page.dart';
import 'package:ncd_screening_mobile/shared/tokens/tokens.dart';
import 'package:ncd_screening_mobile/shared/widgets/elderly_bento_advice_card.dart';
import 'package:ncd_screening_mobile/shared/widgets/emergency_hospital_card.dart';
import 'package:ncd_screening_mobile/shared/widgets/patient_accessibility_floating_bubble.dart';

/// Clean, composable detail page for reviewing individual patient NCD screening outcomes.
class PatientScreeningDetailPage extends StatelessWidget {
  final Patient patient;
  final Screening screening;
  final Nurse? nurse;
  final VHV? vhv;

  const PatientScreeningDetailPage({
    super.key,
    required this.patient,
    required this.screening,
    this.nurse,
    this.vhv,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScreeningBloc, ScreeningState>(
      builder: (context, state) {
        final currentScreening = state.historyList.firstWhere(
          (s) => s.screenId == screening.screenId,
          orElse: () => (state.currentScreening?.screenId == screening.screenId
              ? state.currentScreening!
              : screening),
        );

        return Scaffold(
          backgroundColor: PColor.backgroundColor,
          appBar: _buildAppBar(context, currentScreening),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: PSpacing.edgeInsetsScreen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Emergency Hospital Card if Triage Alert
                    EmergencyHospitalCard(
                      triage: ClinicalTriageService.assess(
                        screening: currentScreening,
                        results: currentScreening.results,
                      ),
                    ),
                    PSpacing.gapVerticalMd,

                    // Review Status Banner
                    ScreeningStatusBanner(
                      reviewStatus: currentScreening.reviewStatus,
                      screeningDate: currentScreening.screeningDate,
                    ),
                    PSpacing.gapVerticalLg,

                    // 4 NCDs Risk Evaluation Summary Cards
                    ScreeningRiskSummarySection(
                      results: currentScreening.results,
                    ),
                    PSpacing.gapVerticalMd,

                    // Personalized Plain-Thai Lifestyle Guidance Bento Cards
                    ScreeningLifestyleGuidanceSection(
                      screening: currentScreening,
                    ),
                    PSpacing.gapVerticalMd,

                    // Clinical Vitals Card
                    ScreeningVitalsCard(screening: currentScreening),
                    PSpacing.gapVerticalMd,

                    // Action Buttons (PDF Preview & Nurse Approve)
                    ScreeningDetailActionButtons(
                      patient: patient,
                      screening: currentScreening,
                      vhv: vhv,
                      nurse: nurse,
                    ),
                  ],
                ),
              ),
              const PatientAccessibilityFloatingBubble(),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, Screening currentScreening) {
    return AppBar(
      backgroundColor: PColor.primaryColor,
      elevation: 0,
      leading: IconButton(
        tooltip: 'ย้อนกลับ',
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: PColor.neutralColor,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'ผลคัดกรอง: ${patient.patientFname} ${patient.patientLname}',
        style: PTypography.appBarTitle,
      ),
      centerTitle: true,
      actions: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: AccessibilityScaleToggle(),
        ),
        IconButton(
          icon: const Icon(
            Icons.picture_as_pdf_outlined,
            color: PColor.neutralColor,
          ),
          tooltip: 'ส่งออก/พิมพ์รายงาน PDF',
          onPressed: () => PdfPreviewPage.open(
            context,
            patient: patient,
            screening: currentScreening,
            vhv: vhv,
            nurse: nurse,
          ),
        ),
      ],
    );
  }
}
