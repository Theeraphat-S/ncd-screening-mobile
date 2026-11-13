import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/nurse/bloc/village_bloc.dart';
import 'package:ncd_screening_mobile/feature/nurse/pages/nurse_patient_list_page.dart';
import 'package:ncd_screening_mobile/feature/nurse/pages/nurse_vhv_list_page.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

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

        if (state.villages.isEmpty) {
          return const Center(child: Text('ไม่พบข้อมูลหมู่บ้าน'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.villages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
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
        borderRadius: BorderRadius.circular(14),
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
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showVillageActionSheet(context, village),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: PColor.primaryLight.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_city_rounded,
                    color: PColor.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'หมู่ ${village.villageNumber} ${village.villageName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: PColor.contentColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'กดเพื่อดูรายชื่อ อสม. หรือ ผู้ป่วยในหมู่บ้าน',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: PColor.textNeutralColor,
                        ),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'หมู่ ${village.villageNumber} ${village.villageName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: PColor.primaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: PColor.primaryLight.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: PColor.secondaryLight,
                      borderRadius: BorderRadius.circular(8),
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
