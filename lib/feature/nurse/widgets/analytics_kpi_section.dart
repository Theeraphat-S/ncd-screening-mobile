import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/domain/models/village_analytics.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

class AnalyticsKpiSection extends StatelessWidget {
  final VillageAnalytics analytics;

  const AnalyticsKpiSection({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                title: 'ประชากรทั้งหมด',
                value: '${analytics.totalPatients}',
                unit: 'คน',
                subtitle: 'ลงทะเบียนในระบบ',
                icon: Icons.people_alt_rounded,
                iconColor: const Color(0xFF6366F1),
                bgColor: const Color(0xFFEEF2FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                title: 'ความครอบคลุม',
                value: '${analytics.screeningCoveragePercentage}%',
                unit: '',
                subtitle:
                    'คัดกรอง ${analytics.screenedPatientsCount}/${analytics.totalPatients} คน',
                icon: Icons.fact_check_rounded,
                iconColor: const Color(0xFF0EA5E9),
                bgColor: const Color(0xFFE0F2FE),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                title: 'กลุ่มเสี่ยงสูง',
                value: '${analytics.highRiskPatientsCount}',
                unit: 'คน',
                subtitle: 'ต้องติดตามเร่งด่วน',
                icon: Icons.warning_amber_rounded,
                iconColor: PColor.errorColor,
                bgColor: const Color(0xFFFEE2E2),
                isAlert: analytics.highRiskPatientsCount > 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                title: 'รอพยาบาลตรวจ',
                value: '${analytics.pendingReviewsCount}',
                unit: 'รายการ',
                subtitle: 'อนุมัติแล้ว ${analytics.approvedReviewsCount}',
                icon: Icons.pending_actions_rounded,
                iconColor: PColor.riskModerate,
                bgColor: const Color(0xFFFEF3C7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String unit,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    bool isAlert = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PColor.neutralColor,
        borderRadius: BorderRadius.circular(14),
        border: isAlert
            ? Border.all(
                color: PColor.errorColor.withValues(alpha: 0.4),
                width: 1.5,
              )
            : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: PColor.textNeutralColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isAlert ? PColor.errorColor : PColor.contentColor,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: PColor.textNeutralColor,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: PColor.textNeutralColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
