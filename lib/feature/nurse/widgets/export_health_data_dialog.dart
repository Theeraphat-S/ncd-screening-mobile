import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/services/health_data_export_service.dart';
import 'package:ncd_screening_mobile/locator.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

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

  /// Writes the CSV to the app cache and opens the system share sheet.
  /// The file is left in the cache directory for the OS to purge.
  Future<void> _shareClinicalCsv(String csv) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/ncd_export_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await file.writeAsString(csv, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        subject: 'NCD clinical export',
      ),
    );
  }

  Future<void> _exportData() async {
    if (_selectedMode == ExportPrivacyMode.clinicalFull) {
      final verified = await locator<NcdRepositoryInterface>()
          .verifyNursePassword(
            nurseId: widget.nurse.nurseId,
            password: _passwordController.text,
          );
      if (!mounted) return;
      if (!verified) {
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

    final isClinical = _selectedMode == ExportPrivacyMode.clinicalFull;
    if (isClinical) {
      // Identifiable data stays out of the clipboard, which any app can read.
      await _shareClinicalCsv(csvData);
    } else {
      await Clipboard.setData(ClipboardData(text: csvData));
    }

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isClinical
              ? 'ส่งออกข้อมูล ${screenings.length} รายการเรียบร้อยแล้ว (เปิดหน้าต่างแชร์ไฟล์)'
              : 'ส่งออกข้อมูล ${screenings.length} รายการเรียบร้อยแล้ว (คัดลอกลง Clipboard แล้ว)',
        ),
        backgroundColor: PColor.riskLow,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.file_download_rounded, color: PColor.primaryColor),
          SizedBox(width: 8),
          Text(
            'ส่งออกข้อมูลสุขภาพ (Excel/CSV)',
            style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
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
              style: TextStyle(fontSize: 13.5, color: PColor.textSecondary),
            ),
            const SizedBox(height: 12),
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
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
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'กรอกรหัสผ่านพยาบาลเพื่อยืนยันสิทธิ์',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
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
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(
            _selectedMode == ExportPrivacyMode.clinicalFull
                ? Icons.ios_share_rounded
                : Icons.copy_rounded,
            color: PColor.neutralColor,
            size: 16,
          ),
          label: Text(
            _selectedMode == ExportPrivacyMode.clinicalFull
                ? 'ส่งออกไฟล์ CSV'
                : 'ส่งออกและคัดลอก CSV',
            style: const TextStyle(
              color: PColor.neutralColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: _exportData,
        ),
      ],
    );
  }
}
