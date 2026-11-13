import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/patient/bloc/patient_bloc.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/patient_detail_page.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/widgets/app_feedback.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

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
        title: Text('ผู้ป่วยในหมู่ ${widget.village.villageNumber}'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: PSpacing.xl, vertical: PSpacing.md),
            color: PColor.primaryDark,
            child: Text(
              '${widget.village.villageName} • อ.แม่อาย จ.เชียงใหม่',
              style: PTypography.onPrimarySemibold,
            ),
          ),
          Expanded(
            child: BlocBuilder<PatientBloc, PatientState>(
              builder: (context, state) {
                if (state.status == PatientStatus.loading && state.patients.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: PColor.primaryColor));
                }

                if (state.status == PatientStatus.failure && state.patients.isEmpty) {
                  return ErrorStateView(
                    message: state.errorMessage ?? 'กรุณาลองอีกครั้ง',
                    onRetry: () => context.read<PatientBloc>().add(
                          PatientLoadRequested(villageId: widget.village.villageId),
                        ),
                  );
                }

                if (state.patients.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_outlined, size: 64, color: PColor.primaryTint),
                        PSpacing.gapVerticalMd,
                        Text(
                          'ไม่พบข้อมูลผู้ป่วยในหมู่บ้านนี้',
                          style: PTypography.bodyLargeMuted,
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
                    padding: const EdgeInsets.all(PSpacing.lg),
                    itemCount: state.patients.length,
                    separatorBuilder: (_, __) => PSpacing.gapVerticalMd,
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
    final initials = patient.patientFname.isNotEmpty ? patient.patientFname.substring(0, 1) : 'P';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PRadius.lg),
        border: Border.all(color: PColor.borderSubtle),
        boxShadow: PShadow.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(PRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(PRadius.lg),
          onTap: () {
            context.read<PatientBloc>().add(PatientSelected(patient));
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PatientDetailPage(
                  patient: patient,
                  nurse: widget.nurse,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PSpacing.lg, vertical: PSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: PColor.primaryLight,
                    borderRadius: BorderRadius.circular(PRadius.md),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: PTypography.emphasisPrimary,
                    ),
                  ),
                ),
                PSpacing.gapHorizontalLg,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: PColor.contentColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      PSpacing.gapVerticalXs,
                      Text(
                        'เลขบัตร: ${patient.patientCitizenId} • อายุ ${patient.age} ปี',
                        style: const TextStyle(
                          fontSize: 13,
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
