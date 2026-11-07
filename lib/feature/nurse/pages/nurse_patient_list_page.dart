import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/patient/bloc/patient_bloc.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/patient_detail_page.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

class NursePatientListPage extends StatefulWidget {
  final Nurse nurse;
  final Village village;

  const NursePatientListPage({
    super.key,
    required this.nurse,
    required this.village,
  });

  @override
  State<NursePatientListPage> createState() => _NursePatientListPageState();
}

class _NursePatientListPageState extends State<NursePatientListPage> {
  @override
  void initState() {
    super.initState();
    context.read<PatientBloc>().add(
      PatientLoadRequested(villageId: widget.village.villageId),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'ผู้ป่วยในหมู่ ${widget.village.villageNumber}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: PColor.neutralColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: PColor.primaryDark,
            child: Text(
              '${widget.village.villageName} • อ.แม่อาย จ.เชียงใหม่',
              style: const TextStyle(
                color: PColor.neutralColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<PatientBloc, PatientState>(
              builder: (context, state) {
                if (state.status == PatientStatus.loading &&
                    state.patients.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: PColor.primaryColor,
                    ),
                  );
                }

                if (state.patients.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'ไม่พบข้อมูลผู้ป่วยในหมู่บ้านนี้',
                          style: TextStyle(
                            fontSize: 15,
                            color: PColor.textNeutralColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: PColor.primaryColor,
                  onRefresh: () async {
                    context.read<PatientBloc>().add(
                      PatientLoadRequested(villageId: widget.village.villageId),
                    );
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.patients.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final patient = state.patients[index];
                      return _buildPatientCard(context, patient);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, Patient patient) {
    final initials = patient.patientFname.isNotEmpty
        ? patient.patientFname.substring(0, 1)
        : 'P';
    return Container(
      decoration: BoxDecoration(
        color: PColor.neutralColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PColor.borderSubtle),
        boxShadow: PShadow.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.read<PatientBloc>().add(PatientSelected(patient));
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PatientDetailPage(patient: patient, nurse: widget.nurse),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: PColor.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: PColor.primaryDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.fullName,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: PColor.contentColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'เลขบัตร: ${patient.patientCitizenId} • อายุ ${patient.age} ปี',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: PColor.textSecondary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: PColor.surfaceSubtle,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: PColor.textNeutralColor,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
