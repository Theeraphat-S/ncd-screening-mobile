import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/domain/models/village_analytics.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';

class DemographicsSection extends StatelessWidget {
  final DemographicDistribution demographics;

  const DemographicsSection({super.key, required this.demographics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              SizedBox(width: 8),
              Text(
                'การกระจายตัวของประชากร',
                style: PTypography.sectionHeader,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Gender Ratio
          const Text(
            'สัดส่วนเพศ (Gender Ratio)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: PColor.contentColor,
            ),
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 8),
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
                  const SizedBox(width: 4),
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
                  const SizedBox(width: 4),
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
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: PColor.contentColor,
            ),
          ),
          const SizedBox(height: 10),
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
              const SizedBox(width: 8),
              Expanded(
                child: _buildAgeBracketCard(
                  label: '35–59 ปี',
                  desc: 'วัยทำงาน',
                  count: demographics.age35To59Count,
                  percentage: demographics.age35To59Ratio,
                  color: PColor.chartAgeMid,
                ),
              ),
              const SizedBox(width: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
          const SizedBox(height: 2),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 12,
              color: PColor.textNeutralColor,
            ),
          ),
          const SizedBox(height: 6),
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
