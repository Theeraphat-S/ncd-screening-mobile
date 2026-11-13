import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/village_analytics.dart';
import 'package:ncd_screening_mobile/feature/nurse/bloc/village_analytics_bloc.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

class AnalyticsFilterBar extends StatelessWidget {
  final VillageAnalyticsState state;

  const AnalyticsFilterBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: PSpacing.lg, vertical: PSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PRadius.md),
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
          // Village Dropdown
          Row(
            children: [
              const Icon(Icons.filter_alt_rounded,
                  color: PColor.primaryColor, size: 20),
              PSpacing.gapHorizontalSm,
              const Text(
                'เลือกพื้นที่:',
                style: PTypography.bodyBold,
              ),
              PSpacing.gapHorizontalSm,
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: PSpacing.md, vertical: PSpacing.xs),
                  decoration: BoxDecoration(
                    color: PColor.backgroundColor,
                    borderRadius: BorderRadius.circular(PRadius.md),
                    border: Border.all(color: PColor.borderStrong),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: state.selectedVillageId ?? 'ALL',
                      icon: const Icon(Icons.arrow_drop_down_rounded,
                          color: PColor.primaryColor),
                      style: PTypography.labelSmall,
                      onChanged: (val) {
                        context.read<VillageAnalyticsBloc>().add(
                              VillageAnalyticsFilterChanged(
                                val == 'ALL' ? null : val,
                              ),
                            );
                      },
                      items: [
                        DropdownMenuItem<String>(
                          value: 'ALL',
                          child: Text(
                            'ทุกหมู่บ้าน (${state.villages.length} หมู่บ้าน)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ...state.villages.map(
                          (v) => DropdownMenuItem<String>(
                            value: v.villageId,
                            child: Text(
                              'หมู่ ${v.villageNumber} ${v.villageName}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          PSpacing.gapVerticalMd,

          // Sort Order Selector
          Row(
            children: [
              const Icon(Icons.sort_rounded,
                  color: PColor.textNeutralColor, size: 20),
              PSpacing.gapHorizontalSm,
              const Text(
                'เรียงลำดับ:',
                style: PTypography.captionLabelMuted,
              ),
              PSpacing.gapHorizontalSm,
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: PSpacing.md, vertical: PSpacing.xs),
                  decoration: BoxDecoration(
                    color: PColor.backgroundColor,
                    borderRadius: BorderRadius.circular(PRadius.md),
                    border: Border.all(color: PColor.borderStrong),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<AnalyticsSortOrder>(
                      isExpanded: true,
                      value: state.sortOrder,
                      icon: const Icon(Icons.arrow_drop_down_rounded,
                          color: PColor.textNeutralColor),
                      style: PTypography.captionContent,
                      onChanged: (order) {
                        if (order != null) {
                          context.read<VillageAnalyticsBloc>().add(
                                VillageAnalyticsSortOrderChanged(order),
                              );
                        }
                      },
                      items: AnalyticsSortOrder.values.map((order) {
                        return DropdownMenuItem<AnalyticsSortOrder>(
                          value: order,
                          child: Text(order.labelTh,
                              overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
