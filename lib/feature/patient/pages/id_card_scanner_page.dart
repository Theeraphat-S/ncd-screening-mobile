import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/services/id_card_ocr_parser.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/add_edit_patient_page.dart';
import 'package:ncd_screening_mobile/feature/screening/pages/screening_form_page.dart';
import 'package:ncd_screening_mobile/locator.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

class IdCardScannerPage extends StatefulWidget {
  final VHV vhv;

  const IdCardScannerPage({super.key, required this.vhv});

  @override
  State<IdCardScannerPage> createState() => _IdCardScannerPageState();
}

class _IdCardScannerPageState extends State<IdCardScannerPage> {
  bool _isProcessing = false;
  final TextEditingController _manualIdController = TextEditingController();

  @override
  void dispose() {
    _manualIdController.dispose();
    super.dispose();
  }

  Future<void> _processOcrText(String rawOcrText) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final parsed = IdCardOcrParser.parse(rawOcrText);
      final citizenId = parsed.citizenId;

      if (citizenId == null || citizenId.length != 13) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'ไม่พบเลขบัตรประชาชน 13 หลักที่ถูกต้อง กรุณาลองใหม่อีกครั้ง',
              ),
              backgroundColor: PColor.riskHigh,
            ),
          );
        }
        return;
      }

      final repo = locator<NcdRepositoryInterface>();
      final existingPatient = await repo.getPatientByCitizenId(citizenId);

      if (!mounted) return;

      if (existingPatient != null) {
        // Matched! Show confirmation snackbar and navigate to screening form
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: PColor.neutralColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'พบข้อมูล: ${existingPatient.fullName} (ดึงข้อมูลเรียบร้อย)',
                  ),
                ),
              ],
            ),
            backgroundColor: PColor.riskLow,
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ScreeningFormPage(patient: existingPatient, vhv: widget.vhv),
          ),
        );
      } else {
        // Not found, navigate to AddEditPatientPage with pre-filled fields
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.person_add_alt_1_rounded,
                  color: PColor.neutralColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ไม่พบประวัติเดิม - ระบบเติมข้อมูลลงทะเบียนใหม่ให้อัตโนมัติ',
                  ),
                ),
              ],
            ),
            backgroundColor: PColor.primaryDark,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AddEditPatientPage(
              vhv: widget.vhv,
              villageId: widget.vhv.villageId,
              initialCitizenId: parsed.citizenId,
              initialTitle: parsed.prefix,
              initialFname: parsed.firstName,
              initialLname: parsed.lastName,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showManualInputDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.edit_note_rounded, color: PColor.primaryColor),
            SizedBox(width: 8),
            Text(
              'ระบุเลขบัตรประชาชน',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: TextField(
          controller: _manualIdController,
          keyboardType: TextInputType.number,
          maxLength: 13,
          decoration: const InputDecoration(
            hintText: 'เลขบัตร 13 หลัก',
            prefixIcon: Icon(Icons.credit_card_rounded),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PColor.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final text = _manualIdController.text.trim();
              Navigator.pop(ctx);
              _processOcrText('เลขประจำตัวประชาชน $text');
            },
            child: const Text(
              'ตรวจสอบ',
              style: TextStyle(color: PColor.neutralColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        elevation: 0,
        leading: IconButton(
          tooltip: 'ย้อนกลับ',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: PColor.neutralColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'สแกนบัตรประชาชน (OCR)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: PColor.neutralColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'กรอกเลขบัตรด้วยตนเอง',
            icon: const Icon(
              Icons.keyboard_alt_outlined,
              color: PColor.neutralColor,
            ),
            onPressed: _showManualInputDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Viewport Simulation & Scanning Reticle
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.88,
                  height: MediaQuery.of(context).size.width * 0.58,
                  decoration: BoxDecoration(
                    border: Border.all(color: PColor.primaryLight, width: 2.5),
                    borderRadius: BorderRadius.circular(16),
                    color: PColor.neutralColor.withValues(alpha: 0.06),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.amber.shade300.withValues(
                                  alpha: 0.6,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'THAILAND',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: Text(
                          _isProcessing
                              ? 'กำลังประมวลผล OCR...'
                              : 'วางบัตรประชาชนให้อยู่ในกรอบ',
                          style: const TextStyle(
                            color: PColor.neutralColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ระบบจะอ่านเลข 13 หลักและชื่อผู้ป่วยอัตโนมัติ',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          // Bottom Action Bar & Fast Simulation Controls
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isProcessing)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: CircularProgressIndicator(
                      color: PColor.primaryLight,
                    ),
                  ),
                // Test shortcuts with sample OCR text; debug builds only.
                if (kDebugMode)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: PColor.neutralColor,
                            side: const BorderSide(color: Colors.white38),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(
                            Icons.person_search_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'ทดสอบผู้ป่วยเดิม',
                            style: TextStyle(fontSize: 13),
                          ),
                          onPressed: _isProcessing
                              ? null
                              : () {
                                  _processOcrText('''
บัตรประจำตัวประชาชน Thai National ID Card
เลขประจำตัวประชาชน 1500200000010
ชื่อ นาย สมชาย ใจดี
                                ''');
                                },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: PColor.neutralColor,
                            side: const BorderSide(color: Colors.white38),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.person_add_rounded, size: 18),
                          label: const Text(
                            'ทดสอบคนใหม่',
                            style: TextStyle(fontSize: 13),
                          ),
                          onPressed: _isProcessing
                              ? null
                              : () {
                                  _processOcrText('''
เลขประจำตัวประชาชน 1500299988877
ชื่อ นาง วันเพ็ญ สดใส
                                ''');
                                },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
