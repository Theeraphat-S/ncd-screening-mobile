import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/pdf_report_service.dart';
import 'package:ncd_screening_mobile/locator.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:printing/printing.dart';

class PdfPreviewPage extends StatelessWidget {
  final Patient patient;
  final Screening screening;
  final VHV? vhv;
  final Nurse? nurse;
  final Village? village;
  final PdfReportServiceInterface? pdfReportService;

  const PdfPreviewPage({
    super.key,
    required this.patient,
    required this.screening,
    this.vhv,
    this.nurse,
    this.village,
    this.pdfReportService,
  });

  static Future<void> open(
    BuildContext context, {
    required Patient patient,
    required Screening screening,
    VHV? vhv,
    Nurse? nurse,
    Village? village,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfPreviewPage(
          patient: patient,
          screening: screening,
          vhv: vhv,
          nurse: nurse,
          village: village,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportService =
        pdfReportService ??
        (locator.isRegistered<PdfReportServiceInterface>()
            ? locator<PdfReportServiceInterface>()
            : PdfReportService());

    final fileName =
        'NCD_Report_${patient.patientCitizenId}_${screening.screenId}.pdf';

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
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'ตัวอย่างรายงาน PDF',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: PColor.neutralColor,
              ),
            ),
            Text(
              '${patient.fullName} • ${screening.screenId}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: PdfPreview(
        build: (format) => reportService.generateScreeningReport(
          patient: patient,
          screening: screening,
          vhv: vhv,
          nurse: nurse,
          village: village,
        ),
        pdfFileName: fileName,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        allowPrinting: true,
        allowSharing: true,
        loadingWidget: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: PColor.primaryColor),
              SizedBox(height: 12),
              Text(
                'กำลังสร้างเอกสารรายงาน PDF...',
                style: TextStyle(color: PColor.textNeutralColor, fontSize: 13),
              ),
            ],
          ),
        ),
        onError: (context, error) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'เกิดข้อผิดพลาดในการสร้างเอกสาร PDF',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: PColor.contentColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: PColor.textNeutralColor,
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
