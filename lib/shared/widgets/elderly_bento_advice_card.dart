import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_lifestyle_advisor.dart';
import 'package:ncd_screening_mobile/shared/bloc/accessibility/accessibility_cubit.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

class AccessibilityScaleToggle extends StatelessWidget {
  const AccessibilityScaleToggle({super.key});

  @override
  Widget build(BuildContext context) {
    AccessibilityCubit? cubit;
    try {
      cubit = context.read<AccessibilityCubit>();
    } catch (_) {
      cubit = null;
    }

    if (cubit == null) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<AccessibilityCubit, AccessibilityState>(
      builder: (context, state) {
        return InkWell(
          borderRadius: BorderRadius.circular(PRadius.xl),
          onTap: () => context.read<AccessibilityCubit>().toggleElderlyMode(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: PSpacing.md, vertical: PSpacing.xs),
            decoration: BoxDecoration(
              color: state.isElderlyMode ? PColor.riskModerate : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(PRadius.xl),
              border: Border.all(
                color: state.isElderlyMode ? PColor.riskModerate : Colors.white54,
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.text_fields_rounded,
                  size: 16,
                  color: state.isElderlyMode ? Colors.white : Colors.white,
                ),
                PSpacing.gapHorizontalXs,
                Text(
                  state.isElderlyMode ? 'โหมดตัวโต (เปิด)' : 'โหมดตัวโต',
                  style: PTypography.onPrimaryLabel,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ElderlyBentoAdviceCard extends StatelessWidget {
  final PlainHealthAdvice advice;

  const ElderlyBentoAdviceCard({super.key, required this.advice});

  Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return PColor.riskLow;
      case RiskLevel.moderate:
        return PColor.riskModerate;
      case RiskLevel.high:
        return PColor.riskHigh;
    }
  }

  Color _getRiskBgColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return PColor.riskLowBg;
      case RiskLevel.moderate:
        return PColor.riskModerateBg;
      case RiskLevel.high:
        return PColor.riskHighBg;
    }
  }

  IconData _getRiskIcon(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return Icons.check_circle_rounded;
      case RiskLevel.moderate:
        return Icons.warning_amber_rounded;
      case RiskLevel.high:
        return Icons.error_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    AccessibilityCubit? cubit;
    try {
      cubit = context.read<AccessibilityCubit>();
    } catch (_) {
      cubit = null;
    }

    if (cubit != null) {
      return BlocBuilder<AccessibilityCubit, AccessibilityState>(
        builder: (context, accState) => _buildCard(context, accState.textScaleFactor),
      );
    }

    return _buildCard(context, 1.0);
  }

  Widget _buildCard(BuildContext context, double scale) {
    final riskColor = _getRiskColor(advice.riskLevel);
    final riskBg = _getRiskBgColor(advice.riskLevel);

        return Container(
          margin: const EdgeInsets.only(bottom: PSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(PRadius.xl),
            border: Border.all(color: riskColor.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: PColor.contentColor.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: PSpacing.lg, vertical: PSpacing.md),
                decoration: BoxDecoration(
                  color: riskBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(PRadius.lg)),
                ),
                child: Row(
                  children: [
                    Icon(_getRiskIcon(advice.riskLevel), color: riskColor, size: 22 * scale),
                    PSpacing.gapHorizontalMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            advice.diseaseName,
                            style: TextStyle(
                              fontSize: 15 * scale,
                              fontWeight: FontWeight.bold,
                              color: PColor.contentColor,
                            ),
                          ),
                          Text(
                            advice.conditionSummary,
                            style: TextStyle(
                              fontSize: 13 * scale,
                              color: PColor.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PSpacing.gapHorizontalSm,
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: PSpacing.md, vertical: PSpacing.xs),
                        decoration: BoxDecoration(
                          color: riskColor,
                          borderRadius: BorderRadius.circular(PRadius.md),
                        ),
                        child: Text(
                          advice.riskLabelThai,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Body Bento Sections
              Padding(
                padding: const EdgeInsets.all(PSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAdviceRow(
                      icon: Icons.restaurant_rounded,
                      iconColor: PColor.riskLow,
                      label: 'อาหารที่ควรกิน: ',
                      labelColor: PColor.riskLow,
                      content: advice.goodFoods.join(', '),
                      scale: scale,
                    ),
                    PSpacing.gapVerticalMd,
                    _buildAdviceRow(
                      icon: Icons.do_not_disturb_alt_rounded,
                      iconColor: PColor.riskHigh,
                      label: 'สิ่งที่ควรเลี่ยง: ',
                      labelColor: PColor.riskHigh,
                      content: advice.avoidFoods.join(', '),
                      scale: scale,
                    ),
                    PSpacing.gapVerticalMd,
                    _buildAdviceRow(
                      icon: Icons.directions_walk_rounded,
                      iconColor: PColor.primaryDark,
                      label: 'การออกกำลังกาย: ',
                      labelColor: PColor.primaryDark,
                      content: advice.exerciseTip,
                      scale: scale,
                    ),
                    PSpacing.gapVerticalMd,

                    // Followup Schedule
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(PSpacing.md),
                      decoration: BoxDecoration(
                        color: PColor.surfaceSubtle,
                        borderRadius: BorderRadius.circular(PRadius.md),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, size: 16, color: PColor.textNeutralColor),
                          PSpacing.gapHorizontalSm,
                          Expanded(
                            child: Text(
                              'นัดติดตาม: ${advice.followUpSchedule}',
                              style: TextStyle(
                                fontSize: 13 * scale,
                                fontWeight: FontWeight.w600,
                                color: PColor.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildAdviceRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color labelColor,
    required String content,
    required double scale,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 18),
        PSpacing.gapHorizontalSm,
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14 * scale,
                color: PColor.contentColor,
                fontFamily: 'Sarabun',
              ),
              children: [
                TextSpan(
                  text: label,
                  style: TextStyle(fontWeight: FontWeight.bold, color: labelColor),
                ),
                TextSpan(text: content),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
