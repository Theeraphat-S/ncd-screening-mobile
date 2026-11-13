import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/shared/tokens/tokens.dart';

extension RiskLevelVisualExtension on RiskLevel {
  Color get color {
    switch (this) {
      case RiskLevel.high:
        return PColor.riskHigh;
      case RiskLevel.moderate:
        return PColor.riskModerate;
      case RiskLevel.low:
        return PColor.riskLow;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case RiskLevel.high:
        return PColor.riskHighBg;
      case RiskLevel.moderate:
        return PColor.riskModerateBg;
      case RiskLevel.low:
        return PColor.riskLowBg;
    }
  }
}

/// Section widget displaying summary cards for the 4 NCD risk evaluation results.
class ScreeningRiskSummarySection extends StatelessWidget {
  final List<ScreeningResult> results;

  const ScreeningRiskSummarySection({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'ผลการประเมินความเสี่ยง 4 โรค',
          style: PTypography.sectionHeader,
        ),
        PSpacing.gapVerticalSm,
        ...results.map(
          (res) => Container(
            margin: const EdgeInsets.only(bottom: PSpacing.sm),
            padding: PSpacing.edgeInsetsAllLg,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: PRadius.borderCard,
              border: Border.all(color: PColor.borderSubtle),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: res.riskLevel.backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: res.riskLevel.color,
                    size: 22,
                  ),
                ),
                PSpacing.gapHorizontalLg,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        res.diseaseName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: PColor.contentColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'คะแนน: ${res.score} คะแนน',
                        style: const TextStyle(
                          fontSize: 14,
                          color: PColor.textNeutralColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: res.riskLevel.color,
                    borderRadius: PRadius.borderXl,
                  ),
                  child: Text(res.riskLevel.labelTh, style: PTypography.badge),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
