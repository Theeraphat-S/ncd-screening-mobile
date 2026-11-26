import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/services/clinical_triage_service.dart';
import 'package:ncd_screening_mobile/shared/config/contacts.dart';
import 'package:ncd_screening_mobile/shared/services/phone_dialer.dart';
import 'package:ncd_screening_mobile/shared/widgets/emergency_hospital_card.dart';

const _crisisTriage = ClinicalTriageAssessment(
  urgencyLevel: TriageUrgencyLevel.emergency,
  requiresImmediateVisit: true,
  urgencyLabel: 'ภาวะวิกฤตความดันโลหิตสูง (Hypertensive Crisis)',
  clinicalRationale: 'ความดันโลหิต 185/115 มม.ปรอท สูงเกินเกณฑ์อันตราย',
  recommendedAction: 'ส่งตัวพบแพทย์ รพ.สต. หรือ รพ.แม่อาย ทันที',
);

Widget _card(PhoneDialer dialer) => MaterialApp(
      home: Scaffold(
        body: EmergencyHospitalCard(triage: _crisisTriage, dialer: dialer),
      ),
    );

void main() {
  group('EmergencyHospitalCard', () {
    testWidgets('renders alert details and both call buttons', (tester) async {
      await tester.pumpWidget(_card((_) async => true));

      expect(find.text('การแจ้งเตือนเคสเร่งด่วน'), findsOneWidget);
      expect(find.text('ภาวะวิกฤตความดันโลหิตสูง (Hypertensive Crisis)'), findsOneWidget);
      expect(find.textContaining('185/115'), findsOneWidget);
      expect(find.textContaining('1669'), findsOneWidget);
      expect(find.textContaining('รพ.สต.แม่อาย'), findsOneWidget);
      expect(find.textContaining(HealthCenterContacts.healthCenterPhone), findsOneWidget);
    });

    testWidgets('the health-center button calls the รพ.สต. number', (tester) async {
      final dialled = <String>[];
      await tester.pumpWidget(_card((n) async {
        dialled.add(n);
        return true;
      }));

      await tester.tap(find.textContaining('รพ.สต.แม่อาย'));
      await tester.pumpAndSettle();

      expect(dialled, [HealthCenterContacts.healthCenterPhone]);
      // A call was placed, so no "calling…" message pretends otherwise.
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('the hotline button calls 1669', (tester) async {
      final dialled = <String>[];
      await tester.pumpWidget(_card((n) async {
        dialled.add(n);
        return true;
      }));

      await tester.tap(find.textContaining('1669'));
      await tester.pumpAndSettle();

      expect(dialled, ['1669']);
    });

    testWidgets('a device that cannot call shows the number instead', (tester) async {
      await tester.pumpWidget(_card((_) async => false));

      await tester.tap(find.textContaining('1669'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('เครื่องนี้โทรออกไม่ได้ กรุณาโทร 1669'), findsOneWidget);
    });

    testWidgets('renders nothing when requiresImmediateVisit is false', (tester) async {
      const routineTriage = ClinicalTriageAssessment(
        urgencyLevel: TriageUrgencyLevel.routine,
        requiresImmediateVisit: false,
        urgencyLabel: 'ปกติ',
        clinicalRationale: 'ปกติ',
        recommendedAction: 'ตรวจประจำปี',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmergencyHospitalCard(triage: routineTriage),
          ),
        ),
      );

      expect(find.text('การแจ้งเตือนเคสเร่งด่วน'), findsNothing);
    });
  });

  group('telUri', () {
    test('strips display formatting', () {
      expect(telUri('053-459034').toString(), 'tel:053459034');
      expect(telUri(' 1669 ').toString(), 'tel:1669');
      expect(telUri('+66 53 459 034').toString(), 'tel:+6653459034');
    });
  });
}
