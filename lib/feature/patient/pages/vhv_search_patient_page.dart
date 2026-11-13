import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/patient/bloc/patient_bloc.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/patient_detail_page.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

class VhvSearchPatientPage extends StatefulWidget {
  final VHV vhv;

  const VhvSearchPatientPage({super.key, required this.vhv});

  @override
  State<VhvSearchPatientPage> createState() => _VhvSearchPatientPageState();
}

class _VhvSearchPatientPageState extends State<VhvSearchPatientPage> {
  static const _debounce = Duration(milliseconds: 300);

  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _hasSearched = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Search while typing: wait until the user pauses so each keystroke does
  /// not trigger its own query.
  void _onQueryChanged(String _) {
    setState(() {}); // refresh the clear button
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, _runSearch);
  }

  void _runSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _clearSearch();
      return;
    }
    setState(() => _hasSearched = true);
    context.read<PatientBloc>().add(
          PatientSearchChanged(query, villageId: widget.vhv.villageId),
        );
  }

  void _searchNow() {
    _debounceTimer?.cancel();
    _runSearch();
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();
    setState(() => _hasSearched = false);
    context.read<PatientBloc>().add(
          PatientLoadRequested(villageId: widget.vhv.villageId),
        );
  }

  @override
  Widget build(BuildContext context) {
    // Leaving by any route (app bar, system back, swipe) puts the village
    // list back, so the patient list page never shows stale search results.
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          context.read<PatientBloc>().add(
                PatientLoadRequested(villageId: widget.vhv.villageId),
              );
        }
      },
      child: Scaffold(
        backgroundColor: PColor.backgroundColor,
        appBar: AppBar(
          title: const Text('ค้นหาผู้ป่วย'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(PSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PSpacing.gapVerticalMd,
                // Search Input Box
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(PRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: PColor.contentColor.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'ชื่อ นามสกุล เลขบัตร หรือบ้านเลขที่',
                      hintStyle: PTypography.bodyMuted,
                      prefixIcon: const Icon(Icons.search_rounded, color: PColor.primaryColor),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: PColor.textNeutralColor),
                              tooltip: 'ล้างคำค้นหา',
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: PSpacing.lg, vertical: PSpacing.lg),
                    ),
                    onChanged: _onQueryChanged,
                    onSubmitted: (_) => _searchNow(),
                  ),
                ),
                PSpacing.gapVerticalLg,
                // Search action
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: _searchNow,
                        icon: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                        label: const Text(
                          'ค้นหา',
                          style: PTypography.buttonOnPrimary,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PColor.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: PSpacing.lg),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(PRadius.md),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                PSpacing.gapVerticalXxl,

                // Results Section
                Expanded(
                  child: BlocBuilder<PatientBloc, PatientState>(
                    builder: (context, state) {
                      // Keep showing the previous results while a new query runs (no flicker).
                      if (state.status == PatientStatus.loading && state.patients.isEmpty) {
                        return const Center(child: CircularProgressIndicator(color: PColor.primaryColor));
                      }

                      if (_hasSearched && state.patients.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 64, color: PColor.borderStrong),
                              PSpacing.gapVerticalMd,
                              Text(
                                'ไม่พบข้อมูล',
                                style: PTypography.bodyMuted,
                              ),
                            ],
                          ),
                        );
                      }

                      if (!_hasSearched) {
                        return const Center(
                          child: Text(
                            'พิมพ์ชื่อ นามสกุล เลขบัตร หรือบ้านเลขที่เพื่อค้นหา',
                            style: PTypography.bodyMuted,
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: state.patients.length,
                        separatorBuilder: (_, __) => PSpacing.gapVerticalMd,
                        itemBuilder: (context, index) {
                          final patient = state.patients[index];
                          return _buildPatientResultCard(context, patient);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientResultCard(BuildContext context, Patient patient) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(PRadius.md),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(PRadius.md),
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
          padding: const EdgeInsets.all(PSpacing.lg),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: PColor.primaryLight.withValues(alpha: 0.15),
                child: const Icon(Icons.person, color: PColor.primaryColor, size: 30),
              ),
              PSpacing.gapHorizontalLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: PTypography.sectionHeader,
                    ),
                    PSpacing.gapVerticalXs,
                    Text(
                      'เลขบัตร: ${patient.patientCitizenId}',
                      style: PTypography.bodyMuted,
                    ),
                    Text(
                      'บ้านเลขที่: ${patient.patientAddress}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PTypography.bodyMuted,
                    ),
                    Text(
                      'อายุ: ${patient.age} ปี • เพศ: ${patient.patientGender}',
                      style: PTypography.caption,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: PColor.primaryColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
