import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/village_analytics.dart';
import 'package:ncd_screening_mobile/feature/nurse/bloc/village_analytics_bloc.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

class VillageComparisonTable extends StatelessWidget {
  final VillageAnalytics analytics;

  const VillageComparisonTable({super.key, required this.analytics});

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.leaderboard_rounded,
                      color: PColor.primaryColor, size: 22),
                  PSpacing.gapHorizontalSm,
                  Text(
                    'การเปรียบเทียบสถิติรายหมู่บ้าน',
                    style: PTypography.sectionHeader,
                  ),
                ],
              ),
              Text(
                '${analytics.villageComparisons.length} หมู่บ้าน',
                style: PTypography.micro,
              ),
            ],
          ),
          PSpacing.gapVerticalXs,
          const Text(
            'กดที่หมู่บ้านเพื่อดูรายละเอียดเฉพาะพื้นที่ (Drill-down)',
            style: PTypography.micro,
          ),
          PSpacing.gapVerticalMd,
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: analytics.villageComparisons.length,
            separatorBuilder: (_, __) => PSpacing.gapVerticalMd,
            itemBuilder: (context, index) {
              final item = analytics.villageComparisons[index];
              return _buildVillageComparisonCard(context, item, index + 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVillageComparisonCard(
    BuildContext context,
    VillageComparisonSummary summary,
    int rank,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(PRadius.md),
      onTap: () {
        context.read<VillageAnalyticsBloc>().add(
              VillageAnalyticsFilterChanged(summary.village.villageId),
            );
      },
      child: Container(
        padding: const EdgeInsets.all(PSpacing.md),
        decoration: BoxDecoration(
          color: PColor.backgroundColor,
          borderRadius: BorderRadius.circular(PRadius.md),
          border: Border.all(color: PColor.borderSubtle),
        ),
        child: Row(
          children: [
            // Rank Badge
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: rank == 1
                    ? const Color(0xFFF59E0B)
                    : PColor.primaryLight.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: rank == 1 ? Colors.white : PColor.primaryColor,
                ),
              ),
            ),
            PSpacing.gapHorizontalMd,

            // Village Info & Coverage
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'หมู่ ${summary.village.villageNumber} ${summary.village.villageName}',
                    style: PTypography.bodyBold,
                  ),
                  PSpacing.gapVerticalXs,
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(PRadius.xs),
                          child: LinearProgressIndicator(
                            value: summary.totalPatients == 0
                                ? 0.0
                                : summary.screenedPatientsCount /
                                    summary.totalPatients,
                            backgroundColor: PColor.borderStrong,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              PColor.primaryColor,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      PSpacing.gapHorizontalSm,
                      Text(
                        '${summary.screeningCoveragePercentage}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: PColor.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  PSpacing.gapVerticalXs,
                  Text(
                    'คัดกรอง ${summary.screenedPatientsCount}/${summary.totalPatients} คน',
                    style: PTypography.micro,
                  ),
                ],
              ),
            ),
            PSpacing.gapHorizontalMd,

            // High Risk & Pending Badges
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (summary.highRiskPatientsCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: PSpacing.sm, vertical: PSpacing.xs),
                    decoration: BoxDecoration(
                      color: PColor.riskHighBg,
                      borderRadius: BorderRadius.circular(PRadius.md),
                      border: Border.all(
                        color: PColor.errorColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            size: 13, color: PColor.errorColor),
                        PSpacing.gapHorizontalXs,
                        Text(
                          'เสี่ยงสูง ${summary.highRiskPatientsCount}',
                          style: PTypography.microError,
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: PSpacing.sm, vertical: PSpacing.xs),
                    decoration: BoxDecoration(
                      color: PColor.riskLowBg,
                      borderRadius: BorderRadius.circular(PRadius.md),
                    ),
                    child: const Text(
                      'ไม่มีเสี่ยงสูง',
                      style: TextStyle(
                        fontSize: 12,
                        color: PColor.riskLow,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                PSpacing.gapVerticalXs,
                if (summary.pendingReviewCount > 0)
                  Text(
                    'รอตรวจ ${summary.pendingReviewCount}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: PColor.riskModerate,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            PSpacing.gapHorizontalXs,
            const Icon(
              Icons.chevron_right_rounded,
              color: PColor.textNeutralColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
