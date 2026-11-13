import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/patient/bloc/patient_bloc.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/id_card_scanner_page.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/patient_detail_page.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';

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
    return Scaffold(
      backgroundColor: PColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: PColor.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            // Restore village patients on exit
            context.read<PatientBloc>().add(
                  PatientLoadRequested(villageId: widget.vhv.villageId),
                );
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'ค้นหาผู้ป่วย',
          style: PTypography.appBarTitle,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // Search Input Box
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
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
                            icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                            tooltip: 'ล้างคำค้นหา',
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  onChanged: _onQueryChanged,
                  onSubmitted: (_) => _searchNow(),
                ),
              ),
              const SizedBox(height: 16),
              // Actions Row (Search + OCR Scan)
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IdCardScannerPage(vhv: widget.vhv),
                          ),
                        );
                      },
                      icon: const Icon(Icons.document_scanner_rounded, color: PColor.primaryColor, size: 19),
                      label: const Text(
                        'สแกน OCR',
                        style: PTypography.actionPrimary,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: PColor.primaryColor, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Results Section
              Expanded(
                child: BlocBuilder<PatientBloc, PatientState>(
                  builder: (context, state) {
                    // Keep showing the previous results while a new query runs (no flicker).
                    if (state.status == PatientStatus.loading && state.patients.isEmpty) {
                      return const Center(child: CircularProgressIndicator(color: PColor.primaryColor));
                    }

                    if (_hasSearched && state.patients.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
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
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
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
    );
  }

  Widget _buildPatientResultCard(BuildContext context, Patient patient) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: PColor.primaryLight.withValues(alpha: 0.15),
                child: const Icon(Icons.person, color: PColor.primaryColor, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: PTypography.sectionHeader,
                    ),
                    const SizedBox(height: 4),
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
