import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/domain/models/village_analytics.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

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
                iconColor: PColor.roleNurse,
                bgColor: PColor.roleNurseBg,
              ),
            ),
            PSpacing.gapHorizontalMd,
            Expanded(
              child: _buildKpiCard(
                title: 'ความครอบคลุม',
                value: '${analytics.screeningCoveragePercentage}%',
                unit: '',
                subtitle:
                    'คัดกรอง ${analytics.screenedPatientsCount}/${analytics.totalPatients} คน',
                icon: Icons.fact_check_rounded,
                iconColor: PColor.secondaryColor,
                bgColor: PColor.secondaryLight,
              ),
            ),
          ],
        ),
        PSpacing.gapVerticalMd,
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
                bgColor: PColor.riskHighBg,
                isAlert: analytics.highRiskPatientsCount > 0,
              ),
            ),
            PSpacing.gapHorizontalMd,
            Expanded(
              child: _buildKpiCard(
                title: 'รอพยาบาลตรวจ',
                value: '${analytics.pendingReviewsCount}',
                unit: 'รายการ',
                subtitle: 'อนุมัติแล้ว ${analytics.approvedReviewsCount}',
                icon: Icons.pending_actions_rounded,
                iconColor: PColor.statusPending,
                bgColor: PColor.statusPendingBg,
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
      padding: const EdgeInsets.all(PSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PRadius.md),
        border: isAlert
            ? Border.all(color: PColor.errorColor.withValues(alpha: 0.4), width: 1.5)
            : Border.all(color: PColor.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: PColor.contentColor.withValues(alpha: 0.04),
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
                style: PTypography.captionLabelMuted,
              ),
              Container(
                padding: const EdgeInsets.all(PSpacing.sm),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(PRadius.sm),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          PSpacing.gapVerticalSm,
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
                PSpacing.gapHorizontalXs,
                Text(
                  unit,
                  style: PTypography.micro,
                ),
              ],
            ],
          ),
          PSpacing.gapVerticalXs,
          Text(
            subtitle,
            style: PTypography.micro,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
