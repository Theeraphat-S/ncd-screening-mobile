import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/pdf_report_service.dart';
import 'package:ncd_screening_mobile/locator.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:printing/printing.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'ตัวอย่างรายงาน PDF',
              style: PTypography.appBarTitle,
            ),
            Text(
              '${patient.fullName} • ${screening.screenId}',
              style: PTypography.captionOnPrimary,
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
              PSpacing.gapVerticalMd,
              Text(
                'กำลังสร้างเอกสารรายงาน PDF...',
                style: PTypography.bodyMuted,
              ),
            ],
          ),
        ),
        onError: (context, error) => Center(
          child: Padding(
            padding: const EdgeInsets.all(PSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: PColor.errorColor,
                  size: 48,
                ),
                PSpacing.gapVerticalMd,
                const Text(
                  'เกิดข้อผิดพลาดในการสร้างเอกสาร PDF',
                  style: PTypography.sectionHeader,
                ),
                PSpacing.gapVerticalSm,
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: PTypography.caption,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
