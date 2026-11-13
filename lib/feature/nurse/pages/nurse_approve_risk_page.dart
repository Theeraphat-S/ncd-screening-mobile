import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/screening/bloc/screening_bloc.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/widgets/app_feedback.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

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
    AppSnackBar.success(context, 'อนุมัติผลการประเมินความเสี่ยงสำเร็จ');
    Navigator.pop(context);
  }

  void _showChangeConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PRadius.xl)),
          contentPadding: const EdgeInsets.symmetric(horizontal: PSpacing.xxl, vertical: PSpacing.xxl),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(PSpacing.lg),
                decoration: const BoxDecoration(
                  color: PColor.statusPendingBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.help_outline_rounded, size: 44, color: PColor.statusPending),
              ),
              PSpacing.gapVerticalLg,
              const Text(
                'ยืนยันการเปลี่ยนระดับความเสี่ยง',
                style: PTypography.headingMd,
                textAlign: TextAlign.center,
              ),
              PSpacing.gapVerticalSm,
              const Text(
                'คุณแน่ใจที่จะปรับเปลี่ยนระดับความเสี่ยงตามที่เลือกไว้ และทำการอนุมัติผลการประเมินใช่หรือไม่?',
                style: TextStyle(
                  fontSize: 13,
                  color: PColor.textNeutralColor,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              PSpacing.gapVerticalXxl,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: PSpacing.md),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PRadius.md)),
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(color: PColor.textNeutralColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  PSpacing.gapHorizontalMd,
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PColor.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: PSpacing.md),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PRadius.md)),
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
        title: const Text('ยืนยันผลการประเมิน'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(PSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Patient Avatar & Name Header
              Container(
                padding: const EdgeInsets.all(PSpacing.xl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(PRadius.lg),
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
                    PSpacing.gapVerticalMd,
                    Text(
                      widget.patient.fullName,
                      style: PTypography.headingMd,
                    ),
                    PSpacing.gapVerticalXs,
                    Text(
                      'วันที่รับการคัดกรอง : $dateStr',
                      style: PTypography.caption,
                    ),
                  ],
                ),
              ),
              PSpacing.gapVerticalLg,

              // Original Evaluation Results (4 Diseases)
              Container(
                padding: const EdgeInsets.all(PSpacing.xl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(PRadius.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ผลการประเมินเดิม (4 โรค)',
                      style: PTypography.cardTitleAccent,
                    ),
                    const Divider(height: 20),
                    ...widget.screening.results.map((res) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: PSpacing.xs),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              res.diseaseName,
                              style: PTypography.body,
                            ),
                            Text(
                              res.riskLevel.labelTh,
                              style: TextStyle(
                                fontSize: 14,
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
              PSpacing.gapVerticalLg,

              // Edit Risk Levels Card
              Container(
                padding: const EdgeInsets.all(PSpacing.xl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(PRadius.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'แก้ไขระดับความเสี่ยง (เลือกได้: ต่ำ/ปานกลาง/สูง)',
                      style: PTypography.cardTitleAccent,
                    ),
                    const Divider(height: 20),

                    // 1. Diabetes
                    _buildRiskDropdown(
                      label: 'โรคเบาหวาน',
                      currentValue: _dmRisk,
                      onChanged: (val) => setState(() => _dmRisk = val!),
                    ),
                    PSpacing.gapVerticalLg,

                    // 2. Hypertension
                    _buildRiskDropdown(
                      label: 'โรคความดันโลหิตสูง',
                      currentValue: _htRisk,
                      onChanged: (val) => setState(() => _htRisk = val!),
                    ),
                    PSpacing.gapVerticalLg,

                    // 3. CVD
                    _buildRiskDropdown(
                      label: 'โรคหลอดเลือดหัวใจ',
                      currentValue: _cvdRisk,
                      onChanged: (val) => setState(() => _cvdRisk = val!),
                    ),
                    PSpacing.gapVerticalLg,

                    // 4. Obesity
                    _buildRiskDropdown(
                      label: 'โรคอ้วนลงพุง',
                      currentValue: _obesityRisk,
                      onChanged: (val) => setState(() => _obesityRisk = val!),
                    ),
                  ],
                ),
              ),
              PSpacing.gapVerticalXxl,

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PColor.statusApprovedDark,
                        padding: const EdgeInsets.symmetric(vertical: PSpacing.lg),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PRadius.md)),
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
                  PSpacing.gapHorizontalMd,
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: PSpacing.lg),
                        side: const BorderSide(color: PColor.riskHigh),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PRadius.md)),
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
              PSpacing.gapVerticalXl,
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
          style: PTypography.captionSemibold,
        ),
        PSpacing.gapVerticalSm,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: PSpacing.lg),
          decoration: BoxDecoration(
            border: Border.all(color: PColor.borderStrong),
            borderRadius: BorderRadius.circular(PRadius.md),
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
                            PSpacing.gapHorizontalSm,
                            Text(r.labelTh, style: const TextStyle(fontSize: 14)),
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
