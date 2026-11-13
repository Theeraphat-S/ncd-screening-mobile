import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/screening/bloc/screening_bloc.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

class NurseApproveRiskPage extends StatefulWidget {
  final Nurse nurse;
  final Patient patient;
  final Screening screening;

  const NurseApproveRiskPage({
    super.key,
    required this.nurse,
    required this.patient,
    required this.screening,
  });

  @override
  State<NurseApproveRiskPage> createState() => _NurseApproveRiskPageState();
}

class _NurseApproveRiskPageState extends State<NurseApproveRiskPage> {
  late RiskLevel _dmRisk;
  late RiskLevel _htRisk;
  late RiskLevel _cvdRisk;
  late RiskLevel _obesityRisk;

  @override
  void initState() {
    super.initState();
    _initRiskValues();
  }

  void _initRiskValues() {
    _dmRisk = _findRisk('DIABETES');
    _htRisk = _findRisk('HYPERTENSION');
    _cvdRisk = _findRisk('CVD');
    _obesityRisk = _findRisk('METABOLIC_OBESITY');
  }

  RiskLevel _findRisk(String code) {
    try {
      final match = widget.screening.results.firstWhere((r) => r.diseaseCode == code);
      return match.riskLevel;
    } catch (_) {
      return RiskLevel.low;
    }
  }

  bool get _hasChanges {
    return _dmRisk != _findRisk('DIABETES') ||
        _htRisk != _findRisk('HYPERTENSION') ||
        _cvdRisk != _findRisk('CVD') ||
        _obesityRisk != _findRisk('METABOLIC_OBESITY');
  }

  List<ScreeningResult> _buildUpdatedResults() {
    return widget.screening.results.map((res) {
      if (res.diseaseCode == 'DIABETES') {
        return res.copyWith(riskLevel: _dmRisk);
      } else if (res.diseaseCode == 'HYPERTENSION') {
        return res.copyWith(riskLevel: _htRisk);
      } else if (res.diseaseCode == 'CVD') {
        return res.copyWith(riskLevel: _cvdRisk);
      } else if (res.diseaseCode == 'METABOLIC_OBESITY') {
        return res.copyWith(riskLevel: _obesityRisk);
      }
      return res;
    }).toList();
  }

  void _onApproveDirect() {
    context.read<ScreeningBloc>().add(
          ScreeningApproveRequested(
            screeningId: widget.screening.screenId,
            status: ReviewStatus.approved,
            nurseId: widget.nurse.nurseId,
            updatedResults: _buildUpdatedResults(),
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('อนุมัติผลการประเมินความเสี่ยงสำเร็จ'),
        backgroundColor: PColor.primaryDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  void _showChangeConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: PColor.statusPendingBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.help_outline_rounded, size: 44, color: PColor.statusPending),
              ),
              const SizedBox(height: 16),
              const Text(
                'ยืนยันการเปลี่ยนระดับความเสี่ยง',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: PColor.contentColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'คุณแน่ใจที่จะปรับเปลี่ยนระดับความเสี่ยงตามที่เลือกไว้ และทำการอนุมัติผลการประเมินใช่หรือไม่?',
                style: TextStyle(
                  fontSize: 13,
                  color: PColor.textNeutralColor,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(color: PColor.textNeutralColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PColor.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _onApproveDirect();
                      },
                      child: const Text(
                        'ยืนยัน',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
    final dateStr =
        '${widget.screening.screeningDate.day.toString().padLeft(2, '0')}/${widget.screening.screeningDate.month.toString().padLeft(2, '0')}/${widget.screening.screeningDate.year + 543}';

    return Scaffold(
      backgroundColor: PColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: PColor.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ยืนยันผลการประเมิน',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Patient Avatar & Name Header
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                      radius: 34,
                      backgroundColor: PColor.primaryLight.withValues(alpha: 0.15),
                      child: const Icon(Icons.person, size: 38, color: PColor.primaryColor),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.patient.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: PColor.contentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'วันที่รับการคัดกรอง : $dateStr',
                      style: const TextStyle(fontSize: 13, color: PColor.textNeutralColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Original Evaluation Results (4 Diseases)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ผลการประเมินเดิม (4 โรค)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: PColor.primaryDark,
                      ),
                    ),
                    const Divider(height: 20),
                    ...widget.screening.results.map((res) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              res.diseaseName,
                              style: const TextStyle(fontSize: 13.5, color: PColor.contentColor),
                            ),
                            Text(
                              res.riskLevel.labelTh,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: PColor.getRiskColor(res.riskLevel.labelTh),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Edit Risk Levels Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'แก้ไขระดับความเสี่ยง (เลือกได้: ต่ำ/ปานกลาง/สูง)',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: PColor.primaryDark,
                      ),
                    ),
                    const Divider(height: 20),

                    // 1. Diabetes
                    _buildRiskDropdown(
                      label: 'โรคเบาหวาน',
                      currentValue: _dmRisk,
                      onChanged: (val) => setState(() => _dmRisk = val!),
                    ),
                    const SizedBox(height: 14),

                    // 2. Hypertension
                    _buildRiskDropdown(
                      label: 'โรคความดันโลหิตสูง',
                      currentValue: _htRisk,
                      onChanged: (val) => setState(() => _htRisk = val!),
                    ),
                    const SizedBox(height: 14),

                    // 3. CVD
                    _buildRiskDropdown(
                      label: 'โรคหลอดเลือดหัวใจ',
                      currentValue: _cvdRisk,
                      onChanged: (val) => setState(() => _cvdRisk = val!),
                    ),
                    const SizedBox(height: 14),

                    // 4. Obesity
                    _buildRiskDropdown(
                      label: 'โรคอ้วนลงพุง',
                      currentValue: _obesityRisk,
                      onChanged: (val) => setState(() => _obesityRisk = val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PColor.statusApprovedDark,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (_hasChanges) {
                          _showChangeConfirmationDialog();
                        } else {
                          _onApproveDirect();
                        }
                      },
                      child: const Text(
                        'ยอมรับ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: PColor.riskHigh),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (_hasChanges) {
                          _showChangeConfirmationDialog();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        _hasChanges ? 'ปรับระดับความเสี่ยง' : 'ไม่ยอมรับ',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: PColor.riskHighDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskDropdown({
    required String label,
    required RiskLevel currentValue,
    required ValueChanged<RiskLevel?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: PColor.contentColor),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(color: PColor.borderStrong),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<RiskLevel>(
              value: currentValue,
              isExpanded: true,
              items: RiskLevel.values
                  .map((r) => DropdownMenuItem(
                        value: r,
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: PColor.getRiskColor(r.labelTh),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(r.labelTh, style: const TextStyle(fontSize: 13.5)),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
