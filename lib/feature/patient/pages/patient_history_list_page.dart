import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/auth/session_flow.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/patient_screening_detail_page.dart';
import 'package:ncd_screening_mobile/feature/screening/bloc/screening_bloc.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

import 'package:ncd_screening_mobile/shared/widgets/patient_accessibility_floating_bubble.dart';

class PatientHistoryListPage extends StatefulWidget {
  final Patient patient;
  final Nurse? nurse;
  final VHV? vhv;

  const PatientHistoryListPage({
    super.key,
    required this.patient,
    this.nurse,
    this.vhv,
  });

  @override
  State<PatientHistoryListPage> createState() => _PatientHistoryListPageState();
}

class _PatientHistoryListPageState extends State<PatientHistoryListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ScreeningBloc>().add(
          ScreeningHistoryLoadRequested(widget.patient.patientId),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isPatientSelf = widget.nurse == null && widget.vhv == null;

    return Scaffold(
      backgroundColor: PColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: PColor.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            if (isPatientSelf) {
              signOut();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          isPatientSelf ? 'ประวัติการคัดกรองของฉัน' : 'ประวัติการคัดกรอง',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
          // Header Patient Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: PColor.primaryDark,
            child: Row(
              children: [
                const Icon(Icons.account_circle, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ผู้ป่วย: ${widget.patient.fullName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '(${widget.patient.patientCitizenId})',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Screenings History List
          Expanded(
            child: BlocBuilder<ScreeningBloc, ScreeningState>(
              builder: (context, state) {
                if (state.status == ScreeningStatus.loading && state.historyList.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: PColor.primaryColor));
                }

                if (state.historyList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_toggle_off_rounded, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'ไม่พบข้อมูลประวัติการคัดกรอง',
                          style: TextStyle(
                            fontSize: 16,
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
                    context.read<ScreeningBloc>().add(
                          ScreeningHistoryLoadRequested(widget.patient.patientId),
                        );
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.historyList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = state.historyList[index];
                      return _buildHistoryCard(context, item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      if (isPatientSelf) const PatientAccessibilityFloatingBubble(),
    ],
  ),
);
}

  Widget _buildHistoryCard(BuildContext context, Screening item) {
    final dateStr =
        '${item.screeningDate.year + 543}-${item.screeningDate.month.toString().padLeft(2, '0')}-${item.screeningDate.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${item.screeningDate.hour.toString().padLeft(2, '0')}:${item.screeningDate.minute.toString().padLeft(2, '0')}';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 1.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          context.read<ScreeningBloc>().add(ScreeningDetailSelected(item));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientScreeningDetailPage(
                patient: widget.patient,
                screening: item,
                nurse: widget.nurse,
                vhv: widget.vhv,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: PColor.primaryLight.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.assignment_outlined, color: PColor.primaryColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'วันที่คัดกรอง: $dateStr',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: PColor.contentColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'เวลา: $dateStr $timeStr',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: PColor.textNeutralColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFFBDBDBD),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
