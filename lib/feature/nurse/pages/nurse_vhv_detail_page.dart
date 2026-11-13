import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/nurse/pages/nurse_add_edit_vhv_page.dart';
import 'package:ncd_screening_mobile/feature/nurse/pages/nurse_patient_list_page.dart';
import 'package:ncd_screening_mobile/feature/vhv/bloc/vhv_bloc.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

class NurseVhvDetailPage extends StatelessWidget {
  final Nurse nurse;
  final VHV vhv;
  final Village village;

  const NurseVhvDetailPage({
    super.key,
    required this.nurse,
    required this.vhv,
    required this.village,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VhvBloc, VhvState>(
      builder: (context, state) {
        final currentVhv = state.vhvs.firstWhere(
          (v) => v.vhvId == vhv.vhvId,
          orElse: () => vhv,
        );

        final birthStr =
            '${currentVhv.vhvBirthDate.year + 543}-${currentVhv.vhvBirthDate.month.toString().padLeft(2, '0')}-${currentVhv.vhvBirthDate.day.toString().padLeft(2, '0')}';

        return Scaffold(
          backgroundColor: PColor.backgroundColor,
          appBar: AppBar(
            title: const Text('รายละเอียด อสม.'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(PSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Card
                Container(
                  padding: const EdgeInsets.all(PSpacing.xl),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(PRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: PColor.contentColor.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: PColor.primaryLight.withValues(alpha: 0.15),
                        child: const Icon(
                          Icons.volunteer_activism_rounded,
                          size: 46,
                          color: PColor.primaryColor,
                        ),
                      ),
                      PSpacing.gapVerticalLg,
                      Text(
                        currentVhv.fullName,
                        style: PTypography.pageTitle,
                      ),
                      PSpacing.gapVerticalXs,
                      Text(
                        'หมู่ ${village.villageNumber} ${village.villageName}',
                        style: PTypography.caption,
                      ),
                    ],
                  ),
                ),
                PSpacing.gapVerticalLg,

                // Details Card
                Container(
                  padding: const EdgeInsets.all(PSpacing.xl),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(PRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: PColor.contentColor.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('เลขบัตร', currentVhv.vhvCitizenId),
                      const Divider(height: 22),
                      _buildInfoRow('เพศ', currentVhv.vhvGender),
                      const Divider(height: 22),
                      _buildInfoRow('วันเกิด', birthStr),
                      const Divider(height: 22),
                      _buildInfoRow('อีเมล', currentVhv.vhvEmail),
                      const Divider(height: 22),
                      _buildInfoRow('มือถือ', currentVhv.vhvMobile),
                    ],
                  ),
                ),
                PSpacing.gapVerticalXxl,

                // Button 1: View Patients in this village
                ElevatedButton.icon(
                  onPressed: () {
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
                  icon: const Icon(Icons.people_alt_outlined, color: Colors.white),
                  label: const Text(
                    'ดูรายชื่อผู้ป่วยในหมู่บ้านนี้',
                    style: PTypography.onPrimaryLabelLg,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PColor.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: PSpacing.lg),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PRadius.md)),
                    elevation: 2,
                  ),
                ),
                PSpacing.gapVerticalMd,

                // Button 2: Edit VHV
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NurseAddEditVhvPage(
                          nurse: nurse,
                          vhv: currentVhv,
                          villageId: village.villageId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined, color: PColor.primaryColor),
                  label: const Text(
                    'แก้ไขข้อมูล อสม.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: PColor.primaryColor,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: PSpacing.lg),
                    side: const BorderSide(color: PColor.primaryColor, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PRadius.md)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: PTypography.bodyMutedMedium,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: PTypography.labelSmall,
          ),
        ),
      ],
    );
  }
}
