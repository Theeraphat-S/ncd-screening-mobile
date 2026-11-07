import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/nurse/pages/nurse_add_edit_vhv_page.dart';
import 'package:ncd_screening_mobile/feature/nurse/pages/nurse_patient_list_page.dart';
import 'package:ncd_screening_mobile/feature/vhv/bloc/vhv_bloc.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

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
            backgroundColor: PColor.primaryColor,
            elevation: 0,
            leading: IconButton(
              tooltip: 'ย้อนกลับ',
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: PColor.neutralColor,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'รายละเอียด อสม.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PColor.neutralColor,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: PColor.neutralColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: PColor.primaryLight.withValues(
                          alpha: 0.15,
                        ),
                        child: const Icon(
                          Icons.volunteer_activism_rounded,
                          size: 46,
                          color: PColor.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        currentVhv.fullName,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: PColor.contentColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'หมู่ ${village.villageNumber} ${village.villageName}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: PColor.textNeutralColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Details Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: PColor.neutralColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
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
                const SizedBox(height: 24),

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
                  icon: const Icon(
                    Icons.people_alt_outlined,
                    color: PColor.neutralColor,
                  ),
                  label: const Text(
                    'ดูรายชื่อผู้ป่วยในหมู่บ้านนี้',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: PColor.neutralColor,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PColor.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
                const SizedBox(height: 12),

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
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: PColor.primaryColor,
                  ),
                  label: const Text(
                    'แก้ไขข้อมูล อสม.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: PColor.primaryColor,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(
                      color: PColor.primaryColor,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
            style: const TextStyle(
              fontSize: 13.5,
              color: PColor.textNeutralColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: PColor.contentColor,
            ),
          ),
        ),
      ],
    );
  }
}
