import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/health_data_export_service.dart';

void main() {
  group('HealthDataExportService', () {
    test('maskCitizenId replaces middle digits with X according to PDPA', () {
      expect(
        HealthDataExportService.maskCitizenId('1500200000010'),
        '1-5002-XXXXX-XX-0',
      );
      expect(
        HealthDataExportService.maskCitizenId('3-5002-99887-65-4'),
        '3-5002-XXXXX-XX-4',
      );
      expect(HealthDataExportService.maskCitizenId('123'), 'X-XXXX-XXXXX-XX-X');
    });

    test('maskName masks first and last names with asterisks', () {
      expect(
        HealthDataExportService.maskName('นาย', 'สมชาย', 'ใจดี'),
        'นาย ส*** ใ***',
      );
      expect(
        HealthDataExportService.maskName('นาง', 'วันเพ็ญ', 'สดใส'),
        'นาง ว*** ส***',
      );
    });

    test('generates anonymized CSV with correct headers and masked data', () {
      final villages = [
        const Village(
          villageId: 'V01',
          villageName: 'บ้านท่าตอน',
          villageNumber: '1',
          subdistrictName: 'ท่าตอน',
          districtName: 'แม่อาย',
          provinceName: 'เชียงใหม่',
        ),
      ];

      final patients = [
        Patient(
          patientId: 'P001',
          patientCitizenId: '1500200000010',
          patientTitle: 'นาย',
          patientFname: 'สมชาย',
          patientLname: 'ใจดี',
          patientGender: 'ชาย',
          patientBirthDate: DateTime(1965, 1, 1),
          patientAddress: '123 ม.1',
          patientMobile: '0812345678',
          villageId: 'V01',
        ),
      ];

      final screenings = [
        Screening(
          screenId: 'SCR001',
          patientId: 'P001',
          vhvId: 'VHV001',
          screeningDate: DateTime(2025, 3, 15),
          ageAtScreening: 60,
          weight: 68.0,
          height: 170.0,
          bmi: 23.53,
          waistCm: 82.0,
          sbp: 130.0,
          dbp: 85.0,
          pulse: 72.0,
          bloodSugar: 105.0,
          reviewStatus: ReviewStatus.approved,
          createdAt: DateTime(2025, 3, 15),
          histories: const [],
          results: const [
            ScreeningResult(
              resultId: 'R1',
              screeningId: 'SCR001',
              diseaseName: 'โรคเบาหวาน',
              diseaseCode: 'DM',
              score: 2,
              riskLevel: RiskLevel.moderate,
              adviceText: 'ระวังน้ำตาล',
            ),
          ],
        ),
      ];

      // Anonymized export
      final csvAnonymized = HealthDataExportService.generateCsv(
        patients: patients,
        screenings: screenings,
        villages: villages,
        mode: ExportPrivacyMode.anonymized,
      );

      expect(csvAnonymized, contains('1-5002-XXXXX-XX-0'));
      expect(csvAnonymized, contains('นาย ส*** ใ***'));
      expect(csvAnonymized, contains('บ้านท่าตอน'));
      expect(csvAnonymized, contains('PDPA_ANONYMIZED'));
      expect(csvAnonymized, isNot(contains('1500200000010')));

      // Full Clinical export
      final csvFull = HealthDataExportService.generateCsv(
        patients: patients,
        screenings: screenings,
        villages: villages,
        mode: ExportPrivacyMode.clinicalFull,
      );

      expect(csvFull, contains('1500200000010'));
      expect(csvFull, contains('นายสมชาย ใจดี'));
      expect(csvFull, contains('CLINICAL_FULL'));
    });
  });
}
