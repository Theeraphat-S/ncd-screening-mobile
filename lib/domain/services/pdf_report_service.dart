import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_risk_calculator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

part 'pdf_report_sections.dart';

abstract class PdfReportServiceInterface {
  Future<Uint8List> generateScreeningReport({
    required Patient patient,
    required Screening screening,
    VHV? vhv,
    Nurse? nurse,
    Village? village,
  });
}

Future<pw.Font> _bundledSarabunRegular() =>
    _loadFont('assets/fonts/Sarabun-Regular.ttf');
Future<pw.Font> _bundledSarabunBold() =>
    _loadFont('assets/fonts/Sarabun-Bold.ttf');

Future<pw.Font> _loadFont(String assetPath) async {
  final data = await rootBundle.load(assetPath);
  return pw.Font.ttf(data);
}

class PdfReportService implements PdfReportServiceInterface {
  final Future<pw.Font> Function()? fontRegularLoader;
  final Future<pw.Font> Function()? fontBoldLoader;

  PdfReportService({this.fontRegularLoader, this.fontBoldLoader});

  @override
  Future<Uint8List> generateScreeningReport({
    required Patient patient,
    required Screening screening,
    VHV? vhv,
    Nurse? nurse,
    Village? village,
  }) async {
    final pdf = pw.Document(
      title: 'NCD Screening Report - ${patient.fullName}',
      author: 'รพ.สต.แม่อาย',
      creator: 'NCD Screening Mobile App',
    );

    // Font resolution with graceful offline fallback
    pw.Font regularFont;
    pw.Font boldFont;

    // Thai fonts are bundled as assets so the PDF works fully offline.
    // Helvetica has no Thai glyphs, so it is only a last resort.
    try {
      regularFont = await (fontRegularLoader ?? _bundledSarabunRegular)();
      boldFont = await (fontBoldLoader ?? _bundledSarabunBold)();
    } catch (e) {
      debugPrint('Bundled Thai font failed to load: $e');
      regularFont = pw.Font.helvetica();
      boldFont = pw.Font.helveticaBold();
    }

    final theme = pw.ThemeData.withFont(base: regularFont, bold: boldFont);

    // Ensure 4 NCD risk results exist (fallback to calculator if empty)
    final results = screening.results.isNotEmpty
        ? screening.results
        : NcdRiskCalculator.evaluateRisk(
            screeningId: screening.screenId,
            weight: screening.weight,
            height: screening.height,
            bmi: screening.bmi,
            waistCm: screening.waistCm,
            sbp: screening.sbp,
            dbp: screening.dbp,
            pulse: screening.pulse,
            bloodSugar: screening.bloodSugar,
            gender: patient.patientGender,
          );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        theme: theme,
        header: (context) => _buildReportHeader(screening),
        footer: _buildReportFooter,
        build: (context) => [
          _buildPatientDemographicsBlock(patient, screening, vhv, village),
          pw.SizedBox(height: 10),
          _buildVitalSignsSection(screening),
          pw.SizedBox(height: 10),
          _buildNcdRiskEvaluationSection(results),
          pw.SizedBox(height: 10),
          _buildNurseReviewAndSignatureBlock(screening, nurse, vhv),
          pw.SizedBox(height: 8),
          _buildMedicalDisclaimerBlock(),
        ],
      ),
    );

    return pdf.save();
  }
}
