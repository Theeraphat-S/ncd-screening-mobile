import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/auth/session_flow.dart';
import 'package:ncd_screening_mobile/feature/patient/bloc/patient_bloc.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/add_edit_patient_page.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/patient_detail_page.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/vhv_search_patient_page.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/widgets/sync_badge_widget.dart';
import 'package:ncd_screening_mobile/shared/widgets/app_feedback.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

class VhvPatientListPage extends StatefulWidget {
  final VHV vhv;

  const VhvPatientListPage({super.key, required this.vhv});

  @override
  State<VhvPatientListPage> createState() => _VhvPatientListPageState();
}

class _VhvPatientListPageState extends State<VhvPatientListPage> {
  @override
  void initState() {
    super.initState();
    context.read<PatientBloc>().add(
          PatientLoadRequested(villageId: widget.vhv.villageId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColor.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'ออกจากระบบ',
          icon: const Icon(Icons.logout_rounded),
          onPressed: () => requestSignOut(context),
        ),
        title: const Text('รายชื่อผู้ป่วย'),
        actions: [
          const SyncBadgeWidget(),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VhvSearchPatientPage(vhv: widget.vhv),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Subheader Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: PSpacing.xl, vertical: PSpacing.md),
            decoration: const BoxDecoration(
              color: PColor.primaryDark,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(PSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(PRadius.sm),
                  ),
                  child: const Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 18),
                ),
                PSpacing.gapHorizontalMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'อสม. ${widget.vhv.fullName}',
                        style: PTypography.onPrimaryLabel,
                      ),
                      Text(
                        'พื้นที่รับผิดชอบ: หมู่ที่ ${widget.vhv.villageId.replaceAll('V', '')} รพ.สต.แม่อาย',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Patient List
          Expanded(
            child: BlocConsumer<PatientBloc, PatientState>(
              listener: (context, state) {
                if (state.message != null) {
                  AppSnackBar.success(context, state.message!);
                } else if (state.status == PatientStatus.failure &&
                    state.errorMessage != null &&
                    (ModalRoute.of(context)?.isCurrent ?? true)) {
                  // A form on top reports its own save failure in place.
                  AppSnackBar.error(context, state.errorMessage!);
                }
              },
              builder: (context, state) {
                if (state.status == PatientStatus.loading && state.patients.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: PColor.primaryColor));
                }

                if (state.status == PatientStatus.failure && state.patients.isEmpty) {
                  return ErrorStateView(
                    message: state.errorMessage ?? 'กรุณาลองอีกครั้ง',
                    onRetry: () => context.read<PatientBloc>().add(
                          PatientLoadRequested(villageId: widget.vhv.villageId),
                        ),
                  );
                }

                if (state.patients.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(PSpacing.xxxl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: PColor.surfaceSubtle,
                              shape: BoxShape.circle,
                              border: Border.all(color: PColor.borderSubtle),
                            ),
                            child: const Icon(Icons.person_search_rounded, size: 40, color: PColor.textNeutralColor),
                          ),
                          PSpacing.gapVerticalLg,
                          const Text(
                            'ยังไม่มีรายชื่อผู้ป่วยในหมู่บ้านนี้',
                            style: TextStyle(
                              fontSize: 16,
                              color: PColor.contentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          PSpacing.gapVerticalSm,
                          const Text(
                            'กดปุ่ม "เพิ่มผู้ป่วย" ด้านล่างเพื่อเริ่มบันทึกข้อมูล',
                            style: PTypography.bodyMuted,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: PColor.primaryColor,
                  onRefresh: () async {
                    context.read<PatientBloc>().add(
                          PatientLoadRequested(villageId: widget.vhv.villageId),
                        );
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: PSpacing.lg, vertical: PSpacing.lg),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: PColor.primaryColor,
        elevation: 2,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
        label: const Text(
          'เพิ่มผู้ป่วยใหม่',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: -0.2,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditPatientPage(
                vhv: widget.vhv,
                villageId: widget.vhv.villageId,
              ),
            ),
          );
        },
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
                  vhv: widget.vhv,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PSpacing.lg, vertical: PSpacing.lg),
            child: Row(
              children: [
                // Initials Avatar
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
                // Info
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
                      Row(
                        children: [
                          const Icon(Icons.credit_card_outlined, size: 14, color: PColor.textNeutralColor),
                          PSpacing.gapHorizontalXs,
                          Text(
                            patient.patientCitizenId,
                            style: const TextStyle(
                              fontSize: 14,
                              color: PColor.textSecondary,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
