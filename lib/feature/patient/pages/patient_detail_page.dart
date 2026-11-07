import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/patient/bloc/patient_bloc.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/add_edit_patient_page.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/patient_history_list_page.dart';
import 'package:ncd_screening_mobile/feature/screening/pages/screening_form_page.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/widgets/patient_accessibility_floating_bubble.dart';

class PatientDetailPage extends StatelessWidget {
  final Patient patient;
  final VHV? vhv;
  final Nurse? nurse;

  const PatientDetailPage({
    super.key,
    required this.patient,
    this.vhv,
    this.nurse,
  });

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 28,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'ต้องการลบผู้ป่วยรายนี้ไหม?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: PColor.contentColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                patient.fullName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: PColor.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'ข้อมูลจะถูกลบออกจากระบบอย่างถาวร',
                style: TextStyle(
                  fontSize: 12.5,
                  color: PColor.textNeutralColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(
                          color: PColor.textNeutralColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PColor.errorColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        context.read<PatientBloc>().add(
                          PatientDeleteRequested(patient.patientId),
                        );
                        Navigator.pop(dialogContext); // Close dialog
                        Navigator.pop(context); // Close detail page
                      },
                      child: const Text(
                        'ยืนยันลบ',
                        style: TextStyle(
                          color: PColor.neutralColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientBloc, PatientState>(
      builder: (context, state) {
        // Fetch most up-to-date patient object if available in state
        final currentPatient = state.patients.firstWhere(
          (p) => p.patientId == patient.patientId,
          orElse: () => patient,
        );

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
              'รายละเอียดผู้ป่วย',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: PColor.neutralColor,
              ),
            ),
            centerTitle: true,
            actions: [
              if (vhv != null) ...[
                IconButton(
                  tooltip: 'แก้ไข',
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: PColor.neutralColor,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditPatientPage(
                          vhv: vhv,
                          patient: currentPatient,
                          villageId: currentPatient.villageId,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'ลบ',
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: PColor.neutralColor,
                  ),
                  onPressed: () => _showDeleteConfirmation(context),
                ),
              ],
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Card with Avatar & Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: PColor.neutralColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: PColor.borderSubtle),
                        boxShadow: PShadow.card,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: PColor.primaryLight,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: PColor.primaryColor.withValues(
                                  alpha: 0.2,
                                ),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                currentPatient.patientFname.isNotEmpty
                                    ? currentPatient.patientFname.substring(
                                        0,
                                        1,
                                      )
                                    : 'P',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: PColor.primaryDark,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            currentPatient.fullName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: PColor.contentColor,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: PColor.surfaceSubtle,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: PColor.borderSubtle),
                            ),
                            child: Text(
                              'HN: ${currentPatient.patientId} • หมู่ ${currentPatient.villageId.replaceAll('V', '')}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: PColor.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Patient Information Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: PColor.neutralColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: PColor.borderSubtle),
                        boxShadow: PShadow.card,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ข้อมูลประจำตัวผู้ป่วย',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: PColor.contentColor,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildInfoRow(
                            'เลขบัตรประชาชน',
                            currentPatient.patientCitizenId,
                          ),
                          const Divider(height: 20, color: PColor.borderSubtle),
                          _buildInfoRow('เพศ', currentPatient.patientGender),
                          const Divider(height: 20, color: PColor.borderSubtle),
                          _buildInfoRow('อายุ', '${currentPatient.age} ปี'),
                          const Divider(height: 20, color: PColor.borderSubtle),
                          _buildInfoRow(
                            'วันเกิด',
                            '${currentPatient.patientBirthDate.day.toString().padLeft(2, '0')}/${currentPatient.patientBirthDate.month.toString().padLeft(2, '0')}/${currentPatient.patientBirthDate.year + 543}',
                          ),
                          const Divider(height: 20, color: PColor.borderSubtle),
                          _buildInfoRow(
                            'ที่อยู่',
                            currentPatient.patientAddress,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action 1: Start Screening (If VHV is logged in)
                    if (vhv != null) ...[
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ScreeningFormPage(
                                  patient: currentPatient,
                                  vhv: vhv!,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.assignment_add,
                            color: PColor.neutralColor,
                            size: 20,
                          ),
                          label: const Text(
                            'เริ่มคัดกรอง / ประเมินความเสี่ยง',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: PColor.neutralColor,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PColor.primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Action 2: View Screening History
                    SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PatientHistoryListPage(
                                patient: currentPatient,
                                nurse: nurse,
                                vhv: vhv,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.history_rounded,
                          color: PColor.primaryColor,
                          size: 20,
                        ),
                        label: const Text(
                          'ดูประวัติการคัดกรองสุขภาพ',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: PColor.primaryColor,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: PColor.primaryColor,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const PatientAccessibilityFloatingBubble(),
            ],
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
          width: 120,
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
