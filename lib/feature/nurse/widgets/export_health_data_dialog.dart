import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/services/health_data_export_service.dart';
import 'package:ncd_screening_mobile/locator.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/widgets/app_feedback.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

class ExportHealthDataDialog extends StatefulWidget {
  final Nurse nurse;

  const ExportHealthDataDialog({super.key, required this.nurse});

  static Future<void> show(BuildContext context, {required Nurse nurse}) {
    return showDialog(
      context: context,
      builder: (_) => ExportHealthDataDialog(nurse: nurse),
    );
  }

  @override
  State<ExportHealthDataDialog> createState() => _ExportHealthDataDialogState();
}

class _ExportHealthDataDialogState extends State<ExportHealthDataDialog> {
  ExportPrivacyMode _selectedMode = ExportPrivacyMode.anonymized;
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _exportData() async {
    if (_selectedMode == ExportPrivacyMode.clinicalFull) {
      if (_passwordController.text.trim() != widget.nurse.nursePassword) {
        setState(() => _errorMessage = 'รหัสผ่านพยาบาลไม่ถูกต้อง');
        return;
      }
    }

    final repo = locator<NcdRepositoryInterface>();
    final patients = await repo.getPatients();
    final screenings = await repo.getAllScreenings();
    final villages = await repo.getVillages();

    final csvData = HealthDataExportService.generateCsv(
      patients: patients,
      screenings: screenings,
      villages: villages,
      mode: _selectedMode,
    );

    await Clipboard.setData(ClipboardData(text: csvData));

    if (!mounted) return;
    Navigator.pop(context);
    AppSnackBar.success(context, 'ส่งออกข้อมูล ${screenings.length} รายการเรียบร้อยแล้ว (คัดลอกลง Clipboard แล้ว)');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PRadius.xl)),
      title: const Row(
        children: [
          Icon(Icons.file_download_rounded, color: PColor.primaryColor),
          PSpacing.gapHorizontalSm,
          Text(
            'ส่งออกข้อมูลสุขภาพ (Excel/CSV)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'เลือกรูปแบบความเป็นส่วนตัวตามมาตรฐานสาธารณสุข:',
              style: PTypography.bodySecondary,
            ),
            PSpacing.gapVerticalMd,
            RadioGroup<ExportPrivacyMode>(
              groupValue: _selectedMode,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedMode = val;
                    _errorMessage = null;
                  });
                }
              },
              child: const Column(
                children: [
                  RadioListTile<ExportPrivacyMode>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'โหมดนิรนาม สถิติวิจัย (PDPA)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'ซ่อนเลขบัตร ปชช. (1-5002-XXXXX-XX-0) และย่อชื่อผู้ป่วย',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: ExportPrivacyMode.anonymized,
                    activeColor: PColor.primaryColor,
                  ),
                  RadioListTile<ExportPrivacyMode>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'โหมดเวชระเบียนเต็ม (Full HIS)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'แสดงเลขและชื่อเต็มเพื่อนำเข้า JHCIS/HOSxP (ต้องใส่รหัสพยาบาล)',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: ExportPrivacyMode.clinicalFull,
                    activeColor: PColor.primaryColor,
                  ),
                ],
              ),
            ),
            if (_selectedMode == ExportPrivacyMode.clinicalFull) ...[
              PSpacing.gapVerticalMd,
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'กรอกรหัสผ่านพยาบาลเพื่อยืนยันสิทธิ์',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(PRadius.md),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: PSpacing.md,
                    vertical: PSpacing.md,
                  ),
                ),
              ),
            ],
            if (_errorMessage != null) ...[
              PSpacing.gapVerticalSm,
              Text(
                _errorMessage!,
                style: const TextStyle(color: PColor.riskHigh, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: PColor.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PRadius.md),
            ),
          ),
          icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 16),
          label: const Text(
            'ส่งออกและคัดลอก CSV',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          onPressed: _exportData,
        ),
      ],
    );
  }
}
