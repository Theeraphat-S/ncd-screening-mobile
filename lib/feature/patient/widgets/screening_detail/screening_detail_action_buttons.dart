import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/nurse/pages/nurse_approve_risk_page.dart';
import 'package:ncd_screening_mobile/feature/screening/pages/pdf_preview_page.dart';
import 'package:ncd_screening_mobile/shared/tokens/tokens.dart';

/// Action buttons container for PDF Preview and Nurse Review.
class ScreeningDetailActionButtons extends StatelessWidget {
  final Patient patient;
  final Screening screening;
  final VHV? vhv;
  final Nurse? nurse;

  const ScreeningDetailActionButtons({
    super.key,
    required this.patient,
    required this.screening,
    this.vhv,
    this.nurse,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Export PDF Button
        OutlinedButton.icon(
          onPressed: () => PdfPreviewPage.open(
            context,
            patient: patient,
            screening: screening,
            vhv: vhv,
            nurse: nurse,
          ),
          icon: const Icon(
            Icons.picture_as_pdf_outlined,
            color: PColor.primaryColor,
          ),
          label: const Text(
            'ดูตัวอย่าง / พิมพ์เอกสารสรุปผล (PDF)',
            style: PTypography.actionPrimary,
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: PColor.primaryColor, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: PRadius.borderCard),
            backgroundColor: Colors.white,
          ),
        ),
        PSpacing.gapVerticalMd,

        // Nurse Action Button
        if (nurse != null) ...[
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NurseApproveRiskPage(
                    nurse: nurse!,
                    patient: patient,
                    screening: screening,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PColor.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: PRadius.borderCard),
              elevation: 2,
            ),
            child: const Text(
              'ประเมินและยืนยันผล (Submit)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          PSpacing.gapVerticalXl,
        ],
      ],
    );
  }
}
