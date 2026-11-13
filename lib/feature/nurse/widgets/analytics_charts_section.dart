import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/domain/models/village_analytics.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

class AnalyticsChartsSection extends StatelessWidget {
  final VillageAnalytics analytics;

  const AnalyticsChartsSection({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PRadius.lg),
        boxShadow: [
          BoxShadow(
            color: PColor.contentColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.monitor_heart_rounded,
                  color: PColor.primaryColor, size: 22),
              PSpacing.gapHorizontalSm,
              Text(
                'สถิติความเสี่ยงรายโรค NCDs (4 โรค)',
                style: PTypography.sectionHeader,
              ),
            ],
          ),
          PSpacing.gapVerticalXs,
          const Text(
            'ประเมินจากผลการคัดกรองล่าสุดของผู้ป่วยแต่ละราย',
            style: PTypography.micro,
          ),
          const Divider(height: 24),

          // 1. Diabetes
          if (analytics.diabetesBreakdown != null)
            _buildDiseaseRiskMeter(
              icon: Icons.bloodtype_outlined,
              breakdown: analytics.diabetesBreakdown!,
            ),
          PSpacing.gapVerticalLg,

          // 2. Hypertension
          if (analytics.hypertensionBreakdown != null)
            _buildDiseaseRiskMeter(
              icon: Icons.speed_rounded,
              breakdown: analytics.hypertensionBreakdown!,
            ),
          PSpacing.gapVerticalLg,

          // 3. CVD
          if (analytics.cvdBreakdown != null)
            _buildDiseaseRiskMeter(
              icon: Icons.favorite_border_rounded,
              breakdown: analytics.cvdBreakdown!,
            ),
          PSpacing.gapVerticalLg,

          // 4. Metabolic Obesity
          if (analytics.obesityBreakdown != null)
            _buildDiseaseRiskMeter(
              icon: Icons.accessibility_new_rounded,
              breakdown: analytics.obesityBreakdown!,
            ),
        ],
      ),
    );
  }

  Widget _buildDiseaseRiskMeter({
    required IconData icon,
    required NcdDiseaseBreakdown breakdown,
  }) {
    final total = breakdown.totalScreened;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 17, color: PColor.primaryColor),
                PSpacing.gapHorizontalSm,
                Text(
                  breakdown.diseaseName,
                  style: PTypography.bodyBold,
                ),
              ],
            ),
            Text(
              'คัดกรองแล้ว $total คน',
              style: PTypography.micro,
            ),
          ],
        ),
        PSpacing.gapVerticalSm,

        // Multi-segment horizontal progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(PRadius.sm),
          child: SizedBox(
            height: 12,
            child: total == 0
                ? Container(color: PColor.borderSubtle)
                : Row(
                    children: [
                      if (breakdown.lowCount > 0)
                        Expanded(
                          flex: breakdown.lowCount,
                          child: Container(
                            color: PColor.riskLow,
                          ),
                        ),
                      if (breakdown.moderateCount > 0)
                        Expanded(
                          flex: breakdown.moderateCount,
                          child: Container(
                            color: PColor.riskModerate,
                          ),
                        ),
                      if (breakdown.highCount > 0)
                        Expanded(
                          flex: breakdown.highCount,
                          child: Container(
                            color: PColor.riskHigh,
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        PSpacing.gapVerticalSm,

        // Legend with exact counts & percentages
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildRiskLegendItem(
              color: PColor.riskLow,
              label: 'ปกติ/ต่ำ',
              count: breakdown.lowCount,
              percentage: breakdown.lowPercentage,
            ),
            _buildRiskLegendItem(
              color: PColor.riskModerate,
              label: 'ปานกลาง',
              count: breakdown.moderateCount,
              percentage: breakdown.moderatePercentage,
            ),
            _buildRiskLegendItem(
              color: PColor.riskHigh,
              label: 'สูง',
              count: breakdown.highCount,
              percentage: breakdown.highPercentage,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRiskLegendItem({
    required Color color,
    required String label,
    required int count,
    required double percentage,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        PSpacing.gapHorizontalXs,
        Text(
          '$label: $count ($percentage%)',
          style: const TextStyle(
            fontSize: 12,
            color: PColor.contentColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
