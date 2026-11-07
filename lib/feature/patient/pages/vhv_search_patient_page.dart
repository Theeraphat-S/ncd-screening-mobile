import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/patient/bloc/patient_bloc.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/id_card_scanner_page.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/patient_detail_page.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

class VhvSearchPatientPage extends StatefulWidget {
  final VHV vhv;

  const VhvSearchPatientPage({super.key, required this.vhv});

  @override
  State<VhvSearchPatientPage> createState() => _VhvSearchPatientPageState();
}

class _VhvSearchPatientPageState extends State<VhvSearchPatientPage> {
  final _searchController = TextEditingController();
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกเลขบัตรประชาชนในการค้นหา'),
          backgroundColor: PColor.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _hasSearched = true);
    context.read<PatientBloc>().add(
      PatientSearchChanged(query, villageId: widget.vhv.villageId),
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: PColor.neutralColor,
          ),
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
                  color: PColor.neutralColor,
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
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'เลขบัตรประชาชนผู้ป่วย (13 หลัก)',
                    hintStyle: const TextStyle(
                      color: PColor.textNeutralColor,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.badge_outlined,
                      color: PColor.primaryColor,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            tooltip: 'ล้างข้อความ',
                            icon: const Icon(
                              Icons.clear_rounded,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _hasSearched = false);
                              context.read<PatientBloc>().add(
                                PatientLoadRequested(
                                  villageId: widget.vhv.villageId,
                                ),
                              );
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onSubmitted: (_) => _onSearch(),
                ),
              ),
              const SizedBox(height: 16),
              // Actions Row (Search + OCR Scan)
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: _onSearch,
                      icon: const Icon(
                        Icons.search_rounded,
                        color: PColor.neutralColor,
                        size: 20,
                      ),
                      label: const Text(
                        'ค้นหา',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: PColor.neutralColor,
                        ),
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
                      icon: const Icon(
                        Icons.document_scanner_rounded,
                        color: PColor.primaryColor,
                        size: 19,
                      ),
                      label: const Text(
                        'สแกน OCR',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: PColor.primaryColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: PColor.primaryColor,
                          width: 1.5,
                        ),
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
                    if (state.status == PatientStatus.loading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: PColor.primaryColor,
                        ),
                      );
                    }

                    if (_hasSearched && state.patients.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'ไม่พบข้อมูล',
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

                    if (!_hasSearched) {
                      return const Center(
                        child: Text(
                          'กรอกเลขบัตรประชาชน 13 หลักเพื่อค้นหา',
                          style: TextStyle(
                            color: PColor.textNeutralColor,
                            fontSize: 14,
                          ),
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
      color: PColor.neutralColor,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          context.read<PatientBloc>().add(PatientSelected(patient));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PatientDetailPage(patient: patient, vhv: widget.vhv),
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
                child: const Icon(
                  Icons.person,
                  color: PColor.primaryColor,
                  size: 30,
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: PColor.contentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'เลขบัตร: ${patient.patientCitizenId}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: PColor.textNeutralColor,
                      ),
                    ),
                    Text(
                      'อายุ: ${patient.age} ปี • เพศ: ${patient.patientGender}',
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
