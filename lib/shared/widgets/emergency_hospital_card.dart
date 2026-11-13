import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/domain/services/clinical_triage_service.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

class EmergencyHospitalCard extends StatelessWidget {
  final ClinicalTriageAssessment triage;
  final String hospitalPhone;
  final String hospitalName;

  const EmergencyHospitalCard({
    super.key,
    required this.triage,
    this.hospitalPhone = ClinicalTriageService.defaultHospitalPhone,
    this.hospitalName = 'รพ.สต.แม่อาย',
  });

  @override
  Widget build(BuildContext context) {
    if (!triage.requiresImmediateVisit) {
      return const SizedBox.shrink();
    }

    const cardColor = PColor.riskHigh;
    const bgColor = PColor.riskHighBg;

    return Container(
      margin: const EdgeInsets.only(bottom: PSpacing.xl),
      padding: const EdgeInsets.all(PSpacing.xl),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(PRadius.xl),
        border: Border.all(color: cardColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(PSpacing.sm),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(PRadius.md),
                ),
                child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 24),
              ),
              PSpacing.gapHorizontalMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'การแจ้งเตือนเคสเร่งด่วน',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: cardColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      triage.urgencyLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: PColor.contentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          PSpacing.gapVerticalMd,

          // Clinical Rationale
          Text(
            triage.clinicalRationale,
            style: const TextStyle(
              fontSize: 14,
              color: PColor.contentColor,
              height: 1.35,
            ),
          ),
          PSpacing.gapVerticalSm,

          // Recommended Action
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(PSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(PRadius.md),
              border: Border.all(color: cardColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.health_and_safety_rounded, color: cardColor, size: 18),
                PSpacing.gapHorizontalSm,
                Expanded(
                  child: Text(
                    triage.recommendedAction,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: cardColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PSpacing.gapVerticalLg,

          // Action Call Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cardColor,
                    padding: const EdgeInsets.symmetric(vertical: PSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PRadius.md)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 18),
                  label: Text(
                    'โทร $hospitalName\n($hospitalPhone)',
                    textAlign: TextAlign.center,
                    style: PTypography.onPrimaryLabel,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('กำลังต่อสายโทรออก: $hospitalPhone ($hospitalName)'),
                        backgroundColor: cardColor,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              PSpacing.gapHorizontalMd,
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cardColor,
                    side: const BorderSide(color: cardColor, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: PSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PRadius.md)),
                    backgroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.support_agent_rounded, size: 18),
                  label: const Text(
                    'สายด่วนกู้ชีพ\n(1669)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('กำลังต่อสายโทรออก: 1669 (ศูนย์รับแจ้งเหตุฉุกเฉิน)'),
                        backgroundColor: PColor.riskHigh,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
