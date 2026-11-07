import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/domain/models/village_analytics.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

class AnalyticsChartsSection extends StatelessWidget {
  final VillageAnalytics analytics;

  const AnalyticsChartsSection({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PColor.neutralColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              Icon(
                Icons.monitor_heart_rounded,
                color: PColor.primaryColor,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'สถิติความเสี่ยงรายโรค NCDs (4 โรค)',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: PColor.contentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'ประเมินจากผลการคัดกรองล่าสุดของผู้ป่วยแต่ละราย',
            style: TextStyle(fontSize: 12, color: PColor.textNeutralColor),
          ),
          const Divider(height: 24),

          // 1. Diabetes
          if (analytics.diabetesBreakdown != null)
            _buildDiseaseRiskMeter(
              icon: Icons.bloodtype_outlined,
              breakdown: analytics.diabetesBreakdown!,
            ),
          const SizedBox(height: 16),

          // 2. Hypertension
          if (analytics.hypertensionBreakdown != null)
            _buildDiseaseRiskMeter(
              icon: Icons.speed_rounded,
              breakdown: analytics.hypertensionBreakdown!,
            ),
          const SizedBox(height: 16),

          // 3. CVD
          if (analytics.cvdBreakdown != null)
            _buildDiseaseRiskMeter(
              icon: Icons.favorite_border_rounded,
              breakdown: analytics.cvdBreakdown!,
            ),
          const SizedBox(height: 16),

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
                const SizedBox(width: 6),
                Text(
                  breakdown.diseaseName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: PColor.contentColor,
                  ),
                ),
              ],
            ),
            Text(
              'คัดกรองแล้ว $total คน',
              style: const TextStyle(
                fontSize: 11.5,
                color: PColor.textNeutralColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Multi-segment horizontal progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 12,
            child: total == 0
                ? Container(color: Colors.grey.shade200)
                : Row(
                    children: [
                      if (breakdown.lowCount > 0)
                        Expanded(
                          flex: breakdown.lowCount,
                          child: Container(color: PColor.riskLow),
                        ),
                      if (breakdown.moderateCount > 0)
                        Expanded(
                          flex: breakdown.moderateCount,
                          child: Container(color: PColor.riskModerate),
                        ),
                      if (breakdown.highCount > 0)
                        Expanded(
                          flex: breakdown.highCount,
                          child: Container(color: PColor.riskHigh),
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),

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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $count ($percentage%)',
          style: const TextStyle(
            fontSize: 11,
            color: PColor.contentColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
