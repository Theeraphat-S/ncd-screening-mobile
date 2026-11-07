import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/village_analytics.dart';
import 'package:ncd_screening_mobile/feature/nurse/bloc/village_analytics_bloc.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

class AnalyticsFilterBar extends StatelessWidget {
  final VillageAnalyticsState state;

  const AnalyticsFilterBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: PColor.neutralColor,
        borderRadius: BorderRadius.circular(14),
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
          // Village Dropdown
          Row(
            children: [
              const Icon(
                Icons.filter_alt_rounded,
                color: PColor.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'เลือกพื้นที่:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: PColor.contentColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: PColor.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: state.selectedVillageId ?? 'ALL',
                      icon: const Icon(
                        Icons.arrow_drop_down_rounded,
                        color: PColor.primaryColor,
                      ),
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: PColor.contentColor,
                        fontWeight: FontWeight.w600,
                      ),
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
          const SizedBox(height: 12),

          // Sort Order Selector
          Row(
            children: [
              const Icon(
                Icons.sort_rounded,
                color: PColor.textNeutralColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'เรียงลำดับ:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: PColor.textNeutralColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: PColor.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<AnalyticsSortOrder>(
                      isExpanded: true,
                      value: state.sortOrder,
                      icon: const Icon(
                        Icons.arrow_drop_down_rounded,
                        color: PColor.textNeutralColor,
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        color: PColor.contentColor,
                      ),
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
                          child: Text(
                            order.labelTh,
                            overflow: TextOverflow.ellipsis,
                          ),
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
