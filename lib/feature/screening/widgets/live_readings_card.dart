import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/domain/services/screening_validator.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

/// BMI and blood-pressure level calculated while the VHV is still typing, so
/// an obviously wrong entry is noticed before saving.
class LiveReadingsCard extends StatelessWidget {
  final double? bmi;
  final BpLevel? bpLevel;

  const LiveReadingsCard({super.key, required this.bmi, required this.bpLevel});

  Color _bpColor(BpLevel level) => switch (level) {
        BpLevel.normal => PColor.riskLow,
        BpLevel.elevated => PColor.riskModerate,
        BpLevel.high => PColor.riskHigh,
        BpLevel.crisis => PColor.riskHigh,
      };

  @override
  Widget build(BuildContext context) {
    if (bmi == null && bpLevel == null) return const SizedBox.shrink();
    return Container(
      key: const Key('live_readings_card'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: PSpacing.md),
      padding: const EdgeInsets.all(PSpacing.lg),
      decoration: BoxDecoration(
        color: PColor.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(PRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bmi != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('BMI (คำนวณอัตโนมัติ)', style: PTypography.bodyBold),
                Text(
                  '$bmi · ${ScreeningValidator.bmiCategory(bmi!)}',
                  key: const Key('live_bmi'),
                  style: PTypography.cardTitle.copyWith(color: PColor.primaryDark),
                ),
              ],
            ),
          if (bmi != null && bpLevel != null) PSpacing.gapVerticalSm,
          if (bpLevel != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ระดับความดัน', style: PTypography.bodyBold),
                Container(
                  key: const Key('live_bp'),
                  padding:
                      const EdgeInsets.symmetric(horizontal: PSpacing.md, vertical: PSpacing.xs),
                  decoration: BoxDecoration(
                    color: _bpColor(bpLevel!),
                    borderRadius: BorderRadius.circular(PRadius.xl),
                  ),
                  child: Text(
                    ScreeningValidator.bpLabel(bpLevel!),
                    style: PTypography.badge,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
