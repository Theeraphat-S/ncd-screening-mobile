import 'dart:typed_data';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_risk_calculator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

abstract class PdfReportServiceInterface {
  Future<Uint8List> generateScreeningReport({
    required Patient patient,
    required Screening screening,
    VHV? vhv,
    Nurse? nurse,
    Village? village,
  });
}

class PdfReportService implements PdfReportServiceInterface {
  final Future<pw.Font> Function()? fontRegularLoader;
  final Future<pw.Font> Function()? fontBoldLoader;

  PdfReportService({
    this.fontRegularLoader,
    this.fontBoldLoader,
  });

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

    try {
      if (fontRegularLoader != null && fontBoldLoader != null) {
        regularFont = await fontRegularLoader!();
        boldFont = await fontBoldLoader!();
      } else {
        regularFont = await PdfGoogleFonts.sarabunRegular();
        boldFont = await PdfGoogleFonts.sarabunBold();
      }
    } catch (_) {
      regularFont = pw.Font.helvetica();
      boldFont = pw.Font.helveticaBold();
    }

    final theme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
    );

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

  pw.Widget _buildReportHeader(Screening screening) {
    final thaiYear = screening.screeningDate.year + 543;
    final dateFormatted =
        '${screening.screeningDate.day.toString().padLeft(2, '0')}/${screening.screeningDate.month.toString().padLeft(2, '0')}/$thaiYear';

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColor.fromInt(0xFF006A60), width: 2),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'โรงพยาบาลส่งเสริมสุขภาพตำบลแม่อาย (รพ.สต.แม่อาย)',
                  style: pw.TextStyle(
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFF006A60),
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'รายงานสรุปผลการตรวจคัดกรองสุขภาพและประเมินความเสี่ยงโรคไม่ติดต่อเรื้อรัง (NCDs)',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFF2D3748),
                  ),
                ),
                pw.Text(
                  'Subdistrict Health Promoting Hospital NCD Screening Summary Report',
                  style: const pw.TextStyle(
                    fontSize: 8.5,
                    color: PdfColor.fromInt(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFF0FDF4),
              border: pw.Border.all(color: const PdfColor.fromInt(0xFF006A60), width: 0.8),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'วันที่ตรวจ: $dateFormatted',
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFF006A60),
                  ),
                ),
                pw.Text(
                  'รหัสคัดกรอง: ${screening.screenId}',
                  style: const pw.TextStyle(
                    fontSize: 8.5,
                    color: PdfColor.fromInt(0xFF4A5568),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPatientDemographicsBlock(
    Patient patient,
    Screening screening,
    VHV? vhv,
    Village? village,
  ) {
    final birthYear = patient.patientBirthDate.year + 543;
    final birthDateStr =
        '${patient.patientBirthDate.day.toString().padLeft(2, '0')}/${patient.patientBirthDate.month.toString().padLeft(2, '0')}/$birthYear';

    final villageAddress = village != null
        ? village.fullAddress
        : (patient.villageId.isNotEmpty ? 'รหัสหมู่บ้าน: ${patient.villageId}' : '-');

    final screenerName = vhv != null
        ? '${vhv.fullName} (อสม.)'
        : (screening.vhvId.isNotEmpty ? '${screening.vhvId} (อสม.)' : 'อสม. ประจำพื้นที่');

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF8FAFC),
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFE2E8F0), width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '1. ข้อมูลทั่วไปของผู้รับการตรวจคัดกรอง (Patient Demographics)',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF006A60),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            children: [
              pw.Expanded(
                flex: 3,
                child: _buildInfoItem('ชื่อ-นามสกุล:', patient.fullName),
              ),
              pw.Expanded(
                flex: 3,
                child: _buildInfoItem('เลขบัตรประชาชน:', patient.patientCitizenId),
              ),
              pw.Expanded(
                flex: 2,
                child: _buildInfoItem('เพศ / อายุ:', '${patient.patientGender} / ${screening.ageAtScreening} ปี'),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Expanded(
                flex: 3,
                child: _buildInfoItem('วัน/เดือน/ปีเกิด:', '$birthDateStr (อายุ ${patient.age} ปี)'),
              ),
              pw.Expanded(
                flex: 3,
                child: _buildInfoItem('เบอร์โทรศัพท์:', patient.patientMobile.isNotEmpty ? patient.patientMobile : '-'),
              ),
              pw.Expanded(
                flex: 2,
                child: _buildInfoItem('ผู้ตรวจคัดกรอง:', screenerName),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildInfoItem('ที่อยู่ / หมู่บ้าน:', '${patient.patientAddress} $villageAddress'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoItem(String label, String value) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$label ',
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColor.fromInt(0xFF64748B),
            ),
          ),
          pw.TextSpan(
            text: value,
            style: pw.TextStyle(
              fontSize: 9.5,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildVitalSignsSection(Screening screening) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF8FAFC),
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFE2E8F0), width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '2. ผลการตรวจสัญญาณชีพและร่างกาย (Vital Signs & Physical Measurements)',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF006A60),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(
              color: const PdfColor.fromInt(0xFFCBD5E1),
              width: 0.6,
            ),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE6F4F1)),
                children: [
                  _buildTableCell('ความดันโลหิต (BP)', isHeader: true),
                  _buildTableCell('ระดับน้ำตาลในเลือด', isHeader: true),
                  _buildTableCell('ดัชนีมวลกาย (BMI)', isHeader: true),
                  _buildTableCell('รอบเอว (Waist)', isHeader: true),
                  _buildTableCell('ชีพจร (Pulse)', isHeader: true),
                  _buildTableCell('น้ำหนัก / ส่วนสูง', isHeader: true),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildTableCell('${screening.sbp.toInt()} / ${screening.dbp.toInt()} mmHg'),
                  _buildTableCell(screening.bloodSugar == null
                      ? 'ไม่ได้ตรวจ'
                      : '${screening.bloodSugar!.toStringAsFixed(0)} mg/dL'),
                  _buildTableCell('${screening.bmi.toStringAsFixed(1)} kg/m²'),
                  _buildTableCell('${screening.waistCm.toStringAsFixed(1)} ซม.'),
                  _buildTableCell('${screening.pulse.toInt()} bpm'),
                  _buildTableCell('${screening.weight.toStringAsFixed(1)} kg / ${screening.height.toStringAsFixed(1)} cm'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: pw.Center(
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: isHeader ? 8.5 : 9.5,
            fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isHeader
                ? const PdfColor.fromInt(0xFF006A60)
                : const PdfColor.fromInt(0xFF1E293B),
          ),
        ),
      ),
    );
  }

  pw.Widget _buildNcdRiskEvaluationSection(List<ScreeningResult> results) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF8FAFC),
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFE2E8F0), width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '3. การประเมินความเสี่ยง 4 กลุ่มโรคไม่ติดต่อเรื้อรัง (4 NCDs Risk Assessment)',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF006A60),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(
              color: const PdfColor.fromInt(0xFFCBD5E1),
              width: 0.6,
            ),
            columnWidths: const {
              0: pw.FlexColumnWidth(2.2),
              1: pw.FlexColumnWidth(1.6),
              2: pw.FlexColumnWidth(3.1),
              3: pw.FlexColumnWidth(3.1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE6F4F1)),
                children: [
                  _buildTableHeaderCell('โรค / ภาวะสุขภาพ'),
                  _buildTableHeaderCell('ระดับความเสี่ยง'),
                  _buildTableHeaderCell('เกณฑ์การประเมินที่ตรวจพบ'),
                  _buildTableHeaderCell('คำแนะนำในการดูแลสุขภาพ'),
                ],
              ),
              ...results.map(_buildRiskTableRow),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
          color: const PdfColor.fromInt(0xFF006A60),
        ),
      ),
    );
  }

  pw.TableRow _buildRiskTableRow(ScreeningResult result) {
    PdfColor badgeBg;
    PdfColor badgeText;
    String badgeLabel;

    switch (result.riskLevel) {
      case RiskLevel.high:
        badgeBg = const PdfColor.fromInt(0xFFFEE2E2);
        badgeText = const PdfColor.fromInt(0xFFB91C1C);
        badgeLabel = 'ความเสี่ยงสูง (High)';
        break;
      case RiskLevel.moderate:
        badgeBg = const PdfColor.fromInt(0xFFFEF3C7);
        badgeText = const PdfColor.fromInt(0xFFB45309);
        badgeLabel = 'ความเสี่ยงปานกลาง (Moderate)';
        break;
      case RiskLevel.low:
        badgeBg = const PdfColor.fromInt(0xFFDCFCE7);
        badgeText = const PdfColor.fromInt(0xFF15803D);
        badgeLabel = 'ความเสี่ยงต่ำ (Low)';
        break;
    }

    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            result.diseaseName,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF1E293B),
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: pw.BoxDecoration(
              color: badgeBg,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Center(
              child: pw.Text(
                badgeLabel,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 7.5,
                  fontWeight: pw.FontWeight.bold,
                  color: badgeText,
                ),
              ),
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            result.criteriaText.isNotEmpty ? result.criteriaText : '-',
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColor.fromInt(0xFF334155),
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            result.adviceText.isNotEmpty ? result.adviceText : '-',
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColor.fromInt(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildNurseReviewAndSignatureBlock(
    Screening screening,
    Nurse? nurse,
    VHV? vhv,
  ) {
    final isApproved = screening.reviewStatus == ReviewStatus.approved;
    final nurseName = nurse?.fullName ??
        (screening.reviewedByNurseId != null && screening.reviewedByNurseId!.isNotEmpty
            ? 'พยาบาลวิชาชีพ (${screening.reviewedByNurseId})'
            : 'พยาบาลวิชาชีพ');

    String reviewDateFormatted = '-';
    if (screening.reviewedAt != null) {
      final rYear = screening.reviewedAt!.year + 543;
      reviewDateFormatted =
          '${screening.reviewedAt!.day.toString().padLeft(2, '0')}/${screening.reviewedAt!.month.toString().padLeft(2, '0')}/$rYear';
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF8FAFC),
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFE2E8F0), width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '4. การตรวจสอบและรับรองผลโดยพยาบาลวิชาชีพ (Nurse Review & Verification)',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFF006A60),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: pw.BoxDecoration(
                  color: isApproved
                      ? const PdfColor.fromInt(0xFFDCFCE7)
                      : const PdfColor.fromInt(0xFFFEF3C7),
                  borderRadius: pw.BorderRadius.circular(4),
                  border: pw.Border.all(
                    color: isApproved
                        ? const PdfColor.fromInt(0xFF16A34A)
                        : const PdfColor.fromInt(0xFFD97706),
                    width: 0.6,
                  ),
                ),
                child: pw.Text(
                  isApproved ? '✓ อนุมัติแล้ว (APPROVED)' : '⏳ รอการตรวจสอบ (PENDING)',
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: isApproved
                        ? const PdfColor.fromInt(0xFF15803D)
                        : const PdfColor.fromInt(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          if (isApproved)
            pw.Text(
              'ได้รับการตรวจสอบและรับรองผลโดย: $nurseName  |  วันที่รับรอง: $reviewDateFormatted',
              style: const pw.TextStyle(
                fontSize: 8.5,
                color: PdfColor.fromInt(0xFF1E293B),
              ),
            )
          else
            pw.Text(
              'สถานะ: ข้อมูลคัดกรองเบื้องต้นโดย อสม. อยู่ระหว่างรอพยาบาลวิชาชีพตรวจสอบและยืนยันผล',
              style: const pw.TextStyle(
                fontSize: 8.5,
                color: PdfColor.fromInt(0xFF64748B),
              ),
            ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              pw.Column(
                children: [
                  pw.Text(
                    'ลงชื่อ ................................................................',
                    style: const pw.TextStyle(fontSize: 8.5, color: PdfColor.fromInt(0xFF475569)),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    '( ${vhv?.fullName ?? '................................................'} )',
                    style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF1E293B)),
                  ),
                  pw.Text(
                    'ผู้ตรวจคัดกรอง (อสม.)',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF64748B)),
                  ),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text(
                    'ลงชื่อ ................................................................',
                    style: const pw.TextStyle(fontSize: 8.5, color: PdfColor.fromInt(0xFF475569)),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    '( ${isApproved ? nurseName : '................................................'} )',
                    style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF1E293B)),
                  ),
                  pw.Text(
                    'พยาบาลวิชาชีพผู้ตรวจรับรอง',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMedicalDisclaimerBlock() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFFFFBEB),
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFFDE68A), width: 0.6),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'หมายเหตุ / คำเตือนทางการแพทย์: ',
            style: pw.TextStyle(
              fontSize: 7.5,
              fontWeight: pw.FontWeight.bold,
              color: const PdfColor.fromInt(0xFF92400E),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              'รายงานนี้เป็นการประเมินความเสี่ยงสุขภาพเบื้องต้นในชุมชน มิใช่ผลการตรวจวินิจฉัยโรคขั้นสุดท้ายโดยแพทย์ หากผลการประเมินมีความเสี่ยง หรือมีอาการผิดปกติ กรุณานำเอกสารนี้ติดต่อ รพ.สต.แม่อาย หรือโรงพยาบาลใกล้บ้านเพื่อรับการตรวจประเมินอย่างละเอียด',
              style: const pw.TextStyle(
                fontSize: 7.5,
                color: PdfColor.fromInt(0xFF78350F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildReportFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColor.fromInt(0xFFE2E8F0), width: 0.8),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'โรงพยาบาลส่งเสริมสุขภาพตำบลแม่อาย ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่ | โทรศัพท์ 053-459-000',
            style: const pw.TextStyle(
              fontSize: 7.5,
              color: PdfColor.fromInt(0xFF94A3B8),
            ),
          ),
          pw.Text(
            'หน้า ${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(
              fontSize: 7.5,
              color: PdfColor.fromInt(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
