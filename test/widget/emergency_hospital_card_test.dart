import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/services/clinical_triage_service.dart';
import 'package:ncd_screening_mobile/shared/widgets/emergency_hospital_card.dart';

void main() {
  group('EmergencyHospitalCard', () {
    testWidgets('renders alert details and contact buttons for crisis triage', (
      tester,
    ) async {
      const crisisTriage = ClinicalTriageAssessment(
        urgencyLevel: TriageUrgencyLevel.emergency,
        requiresImmediateVisit: true,
        urgencyLabel: 'ภาวะวิกฤตความดันโลหิตสูง (Hypertensive Crisis)',
        clinicalRationale: 'ความดันโลหิต 185/115 มม.ปรอท สูงเกินเกณฑ์อันตราย',
        recommendedAction: 'ส่งตัวพบแพทย์ รพ.สต. หรือ รพ.แม่อาย ทันที',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EmergencyHospitalCard(triage: crisisTriage)),
        ),
      );

      expect(find.text('การแจ้งเตือนเคสเร่งด่วน'), findsOneWidget);
      expect(
        find.text('ภาวะวิกฤตความดันโลหิตสูง (Hypertensive Crisis)'),
        findsOneWidget,
      );
      expect(find.textContaining('185/115'), findsOneWidget);
      expect(find.textContaining('1669'), findsOneWidget);
      expect(find.textContaining('รพ.สต.แม่อาย'), findsOneWidget);

      // Tap hospital phone button
      await tester.tap(find.textContaining('รพ.สต.แม่อาย'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('renders nothing when requiresImmediateVisit is false', (
      tester,
    ) async {
      const routineTriage = ClinicalTriageAssessment(
        urgencyLevel: TriageUrgencyLevel.routine,
        requiresImmediateVisit: false,
        urgencyLabel: 'ปกติ',
        clinicalRationale: 'ปกติ',
        recommendedAction: 'ตรวจประจำปี',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EmergencyHospitalCard(triage: routineTriage)),
        ),
      );

      expect(find.text('การแจ้งเตือนเคสเร่งด่วน'), findsNothing);
    });
  });
}
