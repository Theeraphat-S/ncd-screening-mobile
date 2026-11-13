import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/village_analytics.dart';
import 'package:ncd_screening_mobile/feature/nurse/bloc/village_analytics_bloc.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

class VillageComparisonTable extends StatelessWidget {
  final VillageAnalytics analytics;

  const VillageComparisonTable({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  SizedBox(width: 8),
                  Text(
                    'การเปรียบเทียบสถิติรายหมู่บ้าน',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: PColor.contentColor,
                    ),
                  ),
                ],
              ),
              Text(
                '${analytics.villageComparisons.length} หมู่บ้าน',
                style: const TextStyle(
                  fontSize: 12,
                  color: PColor.textNeutralColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'กดที่หมู่บ้านเพื่อดูรายละเอียดเฉพาะพื้นที่ (Drill-down)',
            style: TextStyle(fontSize: 11.5, color: PColor.textNeutralColor),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: analytics.villageComparisons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
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
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        context.read<VillageAnalyticsBloc>().add(
              VillageAnalyticsFilterChanged(summary.village.villageId),
            );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: PColor.backgroundColor,
          borderRadius: BorderRadius.circular(12),
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
            const SizedBox(width: 12),

            // Village Info & Coverage
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'หมู่ ${summary.village.villageNumber} ${summary.village.villageName}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: PColor.contentColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
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
                      const SizedBox(width: 8),
                      Text(
                        '${summary.screeningCoveragePercentage}%',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: PColor.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'คัดกรอง ${summary.screenedPatientsCount}/${summary.totalPatients} คน',
                    style: const TextStyle(
                      fontSize: 11,
                      color: PColor.textNeutralColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // High Risk & Pending Badges
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (summary.highRiskPatientsCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: PColor.riskHighBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: PColor.errorColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            size: 13, color: PColor.errorColor),
                        const SizedBox(width: 3),
                        Text(
                          'เสี่ยงสูง ${summary.highRiskPatientsCount}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: PColor.errorColor,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: PColor.riskLowBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'ไม่มีเสี่ยงสูง',
                      style: TextStyle(
                        fontSize: 11,
                        color: PColor.riskLow,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                if (summary.pendingReviewCount > 0)
                  Text(
                    'รอตรวจ ${summary.pendingReviewCount}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: PColor.riskModerate,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 4),
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
