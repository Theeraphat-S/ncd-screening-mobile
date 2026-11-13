import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';

enum ExportPrivacyMode {
  anonymized, // Masked for PDPA and public research
  clinicalFull, // Full medical dataset for JHCIS / HOSxP import
}

class HealthDataExportService {
  /// Mask 13-digit Thai Citizen ID (e.g. 1500200000010 -> 1-5002-XXXXX-XX-0)
  static String maskCitizenId(String rawId) {
    final cleaned = rawId.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleaned.length != 13) return 'X-XXXX-XXXXX-XX-X';
    return '${cleaned.substring(0, 1)}-${cleaned.substring(1, 5)}-XXXXX-XX-${cleaned.substring(12, 13)}';
  }

  /// Mask patient full name (e.g. นาย สมชาย ใจดี -> นาย ส*** จ***)
  static String maskName(String title, String fname, String lname) {
    final fMasked = fname.isNotEmpty ? '${fname[0]}***' : '***';
    final lMasked = lname.isNotEmpty ? '${lname[0]}***' : '***';
    return '$title $fMasked $lMasked'.trim();
  }

  /// Generate CSV string formatted according to MOPH standard
  static String generateCsv({
    required List<Patient> patients,
    required List<Screening> screenings,
    required List<Village> villages,
    required ExportPrivacyMode mode,
    String? villageFilterId,
  }) {
    final villageMap = {for (final v in villages) v.villageId: v.villageName};
    final patientMap = {for (final p in patients) p.patientId: p};

    final filteredScreenings = villageFilterId == null
        ? screenings
        : screenings.where((s) {
            final p = patientMap[s.patientId];
            return p != null && p.villageId == villageFilterId;
          }).toList();

    final buffer = StringBuffer();

    // CSV Header Row (BOM for Excel Thai utf-8 support)
    buffer.write('\uFEFF');
    buffer.writeln([
      'ลำดับ',
      'เลขบัตรประชาชน',
      'คำนำหน้า',
      'ชื่อ-นามสกุล',
      'เพศ',
      'อายุ (ปี)',
      'หมู่บ้าน',
      'วันที่คัดกรอง',
      'น้ำหนัก_กก',
      'ส่วนสูง_ซม',
      'BMI',
      'รอบเอว_ซม',
      'ความดัน_SBP',
      'ความดัน_DBP',
      'ชีพจร_ครั้งต่อนาที',
      'น้ำตาลในเลือด_mgdL',
      'เสี่ยงเบาหวาน_DM',
      'เสี่ยงความดัน_HT',
      'เสี่ยงหัวใจ_CVD',
      'เสี่ยงอ้วนลงพุง_OBESITY',
      'สถานะการตรวจรับรอง',
      'โหมดข้อมูล',
    ].map(_escapeCsv).join(','));

    for (int i = 0; i < filteredScreenings.length; i++) {
      final s = filteredScreenings[i];
      final p = patientMap[s.patientId];

      final cid = (p == null)
          ? 'N/A'
          : (mode == ExportPrivacyMode.anonymized
              ? maskCitizenId(p.patientCitizenId)
              : p.patientCitizenId);

      final fullName = (p == null)
          ? 'N/A'
          : (mode == ExportPrivacyMode.anonymized
              ? maskName(p.patientTitle, p.patientFname, p.patientLname)
              : p.fullName);

      final villageName = (p != null && villageMap.containsKey(p.villageId))
          ? villageMap[p.villageId]!
          : (p?.villageId ?? 'N/A');

      final dateStr =
          '${s.screeningDate.day.toString().padLeft(2, '0')}/${s.screeningDate.month.toString().padLeft(2, '0')}/${s.screeningDate.year + 543}';

      // Extract 4 NCD risk levels
      String dmRisk = 'NORMAL';
      String htRisk = 'NORMAL';
      String cvdRisk = 'NORMAL';
      String obRisk = 'NORMAL';

      for (final r in s.results) {
        final code = r.diseaseCode.toUpperCase();
        if (code.contains('DM')) dmRisk = r.riskLevel.name.toUpperCase();
        if (code.contains('HT')) htRisk = r.riskLevel.name.toUpperCase();
        if (code.contains('CVD')) cvdRisk = r.riskLevel.name.toUpperCase();
        if (code.contains('OBESITY') || code.contains('METABOLIC')) {
          obRisk = r.riskLevel.name.toUpperCase();
        }
      }

      buffer.writeln([
        (i + 1).toString(),
        cid,
        p?.patientTitle ?? '',
        fullName,
        p?.patientGender ?? 'N/A',
        s.ageAtScreening.toString(),
        villageName,
        dateStr,
        s.weight.toStringAsFixed(1),
        s.height.toStringAsFixed(1),
        s.bmi.toStringAsFixed(2),
        s.waistCm.toStringAsFixed(1),
        s.sbp.toInt().toString(),
        s.dbp.toInt().toString(),
        s.pulse.toInt().toString(),
        s.bloodSugar?.toStringAsFixed(1) ?? '',
        dmRisk,
        htRisk,
        cvdRisk,
        obRisk,
        s.reviewStatus == ReviewStatus.approved ? 'รับรองแล้ว' : 'รอรับรอง',
        mode == ExportPrivacyMode.anonymized ? 'PDPA_ANONYMIZED' : 'CLINICAL_FULL',
      ].map(_escapeCsv).join(','));
    }

    return buffer.toString();
  }

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
