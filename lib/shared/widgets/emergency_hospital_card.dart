import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/domain/services/clinical_triage_service.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

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
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emergency_rounded,
                  color: PColor.neutralColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'การแจ้งเตือนเคสเร่งด่วน',
                      style: TextStyle(
                        fontSize: 13,
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
          const SizedBox(height: 12),

          // Clinical Rationale
          Text(
            triage.clinicalRationale,
            style: const TextStyle(
              fontSize: 14,
              color: PColor.contentColor,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),

          // Recommended Action
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PColor.neutralColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cardColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.health_and_safety_rounded,
                  color: cardColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    triage.recommendedAction,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: cardColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action Call Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cardColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(
                    Icons.phone_in_talk_rounded,
                    color: PColor.neutralColor,
                    size: 18,
                  ),
                  label: Text(
                    'โทร $hospitalName\n($hospitalPhone)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: PColor.neutralColor,
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'กำลังต่อสายโทรออก: $hospitalPhone ($hospitalName)',
                        ),
                        backgroundColor: cardColor,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cardColor,
                    side: const BorderSide(color: cardColor, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: PColor.neutralColor,
                  ),
                  icon: const Icon(Icons.support_agent_rounded, size: 18),
                  label: const Text(
                    'สายด่วนกู้ชีพ\n(1669)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'กำลังต่อสายโทรออก: 1669 (ศูนย์รับแจ้งเหตุฉุกเฉิน)',
                        ),
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
