import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/clinical_triage_service.dart';

void main() {
  group('ClinicalTriageService', () {
    final basePatient = Patient(
      patientId: 'P001',
      patientCitizenId: '1500200000010',
      patientTitle: 'นาย',
      patientFname: 'สมชาย',
      patientLname: 'ใจดี',
      patientGender: 'ชาย',
      patientBirthDate: DateTime(1960, 1, 1),
      patientAddress: '123 ม.1',
      patientMobile: '0812345678',
      villageId: 'V01',
    );

    test(
      'classifies hypertensive crisis (SBP >= 180) as Emergency with requiresImmediateVisit',
      () {
        final crisisScreening = Screening(
          screenId: 'SCR_CRISIS',
          patientId: 'P001',
          vhvId: 'VHV001',
          screeningDate: DateTime.now(),
          ageAtScreening: 66,
          weight: 70,
          height: 165,
          bmi: 25.7,
          waistCm: 88,
          sbp: 185.0,
          dbp: 115.0,
          pulse: 90,
          bloodSugar: 110,
          reviewStatus: ReviewStatus.pending,
          createdAt: DateTime.now(),
          histories: const [],
          results: const [
            ScreeningResult(
              resultId: 'R1',
              screeningId: 'SCR_CRISIS',
              diseaseName: 'โรคความดันโลหิตสูง',
              diseaseCode: 'HT',
              score: 10,
              riskLevel: RiskLevel.high,
              adviceText: 'วิกฤต',
            ),
          ],
        );

        final triage = ClinicalTriageService.assess(
          screening: crisisScreening,
          results: crisisScreening.results,
        );

        expect(triage.urgencyLevel, TriageUrgencyLevel.emergency);
        expect(triage.requiresImmediateVisit, isTrue);
        expect(triage.urgencyLabel, contains('วิกฤตความดันโลหิตสูง'));

        final payload = ClinicalTriageService.generateLineWebhookPayload(
          patient: basePatient,
          screening: crisisScreening,
          triage: triage,
        );

        expect(payload['event'], 'CLINICAL_TRIAGE_ALERT');
        expect(payload['message'], contains('สมชาย ใจดี'));
        expect(payload['message'], contains('185/115'));
      },
    );

    test('classifies multi-NCD high risk as Urgent triage', () {
      final multiHighScreening = Screening(
        screenId: 'SCR_MULTI',
        patientId: 'P001',
        vhvId: 'VHV001',
        screeningDate: DateTime.now(),
        ageAtScreening: 66,
        weight: 85,
        height: 160,
        bmi: 33.2,
        waistCm: 96,
        sbp: 155.0,
        dbp: 95.0,
        pulse: 80,
        bloodSugar: 160,
        reviewStatus: ReviewStatus.pending,
        createdAt: DateTime.now(),
        histories: const [],
        results: const [
          ScreeningResult(
            resultId: 'R1',
            screeningId: 'SCR_MULTI',
            diseaseName: 'โรคเบาหวาน',
            diseaseCode: 'DM',
            score: 8,
            riskLevel: RiskLevel.high,
            adviceText: 'เสี่ยงสูง',
          ),
          ScreeningResult(
            resultId: 'R2',
            screeningId: 'SCR_MULTI',
            diseaseName: 'โรคความดันโลหิตสูง',
            diseaseCode: 'HT',
            score: 8,
            riskLevel: RiskLevel.high,
            adviceText: 'เสี่ยงสูง',
          ),
        ],
      );

      final triage = ClinicalTriageService.assess(
        screening: multiHighScreening,
        results: multiHighScreening.results,
      );

      expect(triage.urgencyLevel, TriageUrgencyLevel.urgent);
      expect(triage.requiresImmediateVisit, isTrue);
      expect(triage.urgencyLabel, contains('เสี่ยงสูงหลายโรคพร้อมกัน'));
    });

    test('classifies normal vitals as Routine', () {
      final normalScreening = Screening(
        screenId: 'SCR_NORM',
        patientId: 'P001',
        vhvId: 'VHV001',
        screeningDate: DateTime.now(),
        ageAtScreening: 35,
        weight: 60,
        height: 170,
        bmi: 20.7,
        waistCm: 75,
        sbp: 118.0,
        dbp: 75.0,
        pulse: 70,
        bloodSugar: 90,
        reviewStatus: ReviewStatus.pending,
        createdAt: DateTime.now(),
        histories: const [],
        results: const [
          ScreeningResult(
            resultId: 'R1',
            screeningId: 'SCR_NORM',
            diseaseName: 'โรคเบาหวาน',
            diseaseCode: 'DM',
            score: 0,
            riskLevel: RiskLevel.low,
            adviceText: 'ปกติ',
          ),
        ],
      );

      final triage = ClinicalTriageService.assess(
        screening: normalScreening,
        results: normalScreening.results,
      );

      expect(triage.urgencyLevel, TriageUrgencyLevel.routine);
      expect(triage.requiresImmediateVisit, isFalse);
    });
  });
}
