import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/nurse/bloc/village_bloc.dart';
import 'package:ncd_screening_mobile/feature/nurse/pages/nurse_patient_list_page.dart';
import 'package:ncd_screening_mobile/feature/nurse/pages/nurse_vhv_list_page.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/widgets/app_feedback.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

class VillageManagementTab extends StatelessWidget {
  final Nurse nurse;

  const VillageManagementTab({super.key, required this.nurse});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VillageBloc, VillageState>(
      builder: (context, state) {
        if (state.status == VillageStatus.loading && state.villages.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: PColor.primaryColor),
          );
        }

        if (state.status == VillageStatus.failure && state.villages.isEmpty) {
          return ErrorStateView(
            message: state.errorMessage ?? 'กรุณาลองอีกครั้ง',
            onRetry: () => context.read<VillageBloc>().add(VillageListLoadRequested()),
          );
        }

        if (state.villages.isEmpty) {
          return const Center(child: Text('ไม่พบข้อมูลหมู่บ้าน'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(PSpacing.lg),
          itemCount: state.villages.length,
          separatorBuilder: (_, __) => PSpacing.gapVerticalMd,
          itemBuilder: (context, index) {
            final village = state.villages[index];
            return _buildVillageCard(context, village);
          },
        );
      },
    );
  }

  Widget _buildVillageCard(BuildContext context, Village village) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(PRadius.md),
          onTap: () => _showVillageActionSheet(context, village),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PSpacing.xl, vertical: PSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(PSpacing.md),
                  decoration: BoxDecoration(
                    color: PColor.primaryLight.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(PRadius.md),
                  ),
                  child: const Icon(
                    Icons.location_city_rounded,
                    color: PColor.primaryColor,
                    size: 24,
                  ),
                ),
                PSpacing.gapHorizontalLg,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'หมู่ ${village.villageNumber} ${village.villageName}',
                        style: PTypography.sectionHeader,
                      ),
                      PSpacing.gapVerticalXs,
                      const Text(
                        'กดเพื่อดูรายชื่อ อสม. หรือ ผู้ป่วยในหมู่บ้าน',
                        style: PTypography.caption,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: PColor.borderStrong,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showVillageActionSheet(BuildContext context, Village village) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(PRadius.xl)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PSpacing.xl, vertical: PSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'หมู่ ${village.villageNumber} ${village.villageName}',
                  style: PTypography.emphasisPrimary,
                  textAlign: TextAlign.center,
                ),
                PSpacing.gapVerticalXl,
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(PSpacing.sm),
                    decoration: BoxDecoration(
                      color: PColor.primaryLight.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(PRadius.sm),
                    ),
                    child: const Icon(Icons.volunteer_activism_rounded,
                        color: PColor.primaryColor),
                  ),
                  title: const Text('รายชื่อ อสม. ในหมู่บ้าน',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle:
                      const Text('ดูข้อมูลและจัดการ อสม. ประจำหมู่บ้านนี้'),
                  trailing:
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NurseVhvListPage(
                          nurse: nurse,
                          village: village,
                        ),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(PSpacing.sm),
                    decoration: BoxDecoration(
                      color: PColor.secondaryLight,
                      borderRadius: BorderRadius.circular(PRadius.sm),
                    ),
                    child: const Icon(Icons.people_outline_rounded,
                        color: PColor.secondaryColor),
                  ),
                  title: const Text('รายชื่อผู้ป่วยในหมู่บ้าน',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle:
                      const Text('ดูรายชื่อผู้ป่วยและผลการคัดกรองความเสี่ยง'),
                  trailing:
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NursePatientListPage(
                          nurse: nurse,
                          village: village,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
