import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/domain/models/village_analytics.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

class DemographicsSection extends StatelessWidget {
  final DemographicDistribution demographics;

  const DemographicsSection({super.key, required this.demographics});

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
              Icon(Icons.pie_chart_outline_rounded,
                  color: PColor.primaryColor, size: 22),
              PSpacing.gapHorizontalSm,
              Text(
                'การกระจายตัวของประชากร',
                style: PTypography.sectionHeader,
              ),
            ],
          ),
          PSpacing.gapVerticalLg,

          // Gender Ratio
          const Text(
            'สัดส่วนเพศ (Gender Ratio)',
            style: PTypography.captionSemibold,
          ),
          PSpacing.gapVerticalSm,
          ClipRRect(
            borderRadius: BorderRadius.circular(PRadius.sm),
            child: SizedBox(
              height: 12,
              child: demographics.totalPatients == 0
                  ? Container(color: PColor.borderSubtle)
                  : Row(
                      children: [
                        if (demographics.maleCount > 0)
                          Expanded(
                            flex: demographics.maleCount,
                            child: Container(color: PColor.chartMale),
                          ),
                        if (demographics.femaleCount > 0)
                          Expanded(
                            flex: demographics.femaleCount,
                            child: Container(color: PColor.chartFemale),
                          ),
                      ],
                    ),
            ),
          ),
          PSpacing.gapVerticalSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: PColor.chartMale,
                      shape: BoxShape.circle,
                    ),
                  ),
                  PSpacing.gapHorizontalXs,
                  Text(
                    'ชาย: ${demographics.maleCount} คน (${demographics.maleRatio}%)',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: PColor.chartFemale,
                      shape: BoxShape.circle,
                    ),
                  ),
                  PSpacing.gapHorizontalXs,
                  Text(
                    'หญิง: ${demographics.femaleCount} คน (${demographics.femaleRatio}%)',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),

          // Age Brackets
          const Text(
            'กลุ่มช่วงอายุ (Age Groups)',
            style: PTypography.captionSemibold,
          ),
          PSpacing.gapVerticalMd,
          Row(
            children: [
              Expanded(
                child: _buildAgeBracketCard(
                  label: '< 35 ปี',
                  desc: 'วัยหนุ่มสาว',
                  count: demographics.ageUnder35Count,
                  percentage: demographics.ageUnder35Ratio,
                  color: PColor.chartAgeYoung,
                ),
              ),
              PSpacing.gapHorizontalSm,
              Expanded(
                child: _buildAgeBracketCard(
                  label: '35–59 ปี',
                  desc: 'วัยทำงาน',
                  count: demographics.age35To59Count,
                  percentage: demographics.age35To59Ratio,
                  color: PColor.chartAgeMid,
                ),
              ),
              PSpacing.gapHorizontalSm,
              Expanded(
                child: _buildAgeBracketCard(
                  label: '≥ 60 ปี',
                  desc: 'ผู้สูงอายุ',
                  count: demographics.age60AndAboveCount,
                  percentage: demographics.age60AndAboveRatio,
                  color: PColor.chartAgeOld,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgeBracketCard({
    required String label,
    required String desc,
    required int count,
    required double percentage,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: PSpacing.md, vertical: PSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(PRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          PSpacing.gapVerticalXs,
          Text(
            desc,
            style: PTypography.micro,
          ),
          PSpacing.gapVerticalSm,
          Text(
            '$count คน',
            style: PTypography.bodyBold,
          ),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
