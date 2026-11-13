import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/patient/widgets/screening_detail/screening_detail_widgets.dart';

void main() {
  group('ScreeningDetail Sub-widgets Tests', () {
    testWidgets(
      'ScreeningStatusBanner displays pending status and date correctly',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScreeningStatusBanner(
                reviewStatus: ReviewStatus.pending,
                screeningDate: DateTime(2025, 3, 15),
              ),
            ),
          ),
        );

        expect(find.text('รอพยาบาลตรวจสอบและรับรองผล'), findsOneWidget);
        expect(find.text('วันที่ตรวจ: 15/03/2568'), findsOneWidget);
        expect(find.byIcon(Icons.hourglass_top_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'ScreeningStatusBanner displays approved status and date correctly',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScreeningStatusBanner(
                reviewStatus: ReviewStatus.approved,
                screeningDate: DateTime(2025, 3, 15),
              ),
            ),
          ),
        );

        expect(find.text('ผ่านการรับรองโดยพยาบาลแล้ว'), findsOneWidget);
        expect(find.text('วันที่ตรวจ: 15/03/2568'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      },
    );

    testWidgets('ScreeningRiskSummarySection renders 4 diseases with badges', (
      tester,
    ) async {
      final List<ScreeningResult> results = [
        const ScreeningResult(
          resultId: 'r1',
          screeningId: 's1',
          diseaseName: 'โรคเบาหวาน',
          diseaseCode: 'DIABETES',
          riskLevel: RiskLevel.high,
          score: 85,
          adviceText: 'พบแพทย์',
        ),
        const ScreeningResult(
          resultId: 'r2',
          screeningId: 's1',
          diseaseName: 'โรคความดันโลหิตสูง',
          diseaseCode: 'HYPERTENSION',
          riskLevel: RiskLevel.low,
          score: 10,
          adviceText: 'ปกติ',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ScreeningRiskSummarySection(results: results),
            ),
          ),
        ),
      );

      expect(find.text('ผลการประเมินความเสี่ยง 4 โรค'), findsOneWidget);
      expect(find.text('โรคเบาหวาน'), findsOneWidget);
      expect(find.text('คะแนน: 85 คะแนน'), findsOneWidget);
      expect(find.text('สูง'), findsOneWidget);
      expect(find.text('โรคความดันโลหิตสูง'), findsOneWidget);
      expect(find.text('ต่ำ'), findsOneWidget);
    });

    testWidgets('ScreeningVitalsCard displays vitals metrics correctly', (
      tester,
    ) async {
      final screening = Screening(
        screenId: 's1',
        patientId: 'p1',
        vhvId: 'v1',
        screeningDate: DateTime(2025, 3, 15),
        ageAtScreening: 60,
        createdAt: DateTime(2025, 3, 15),
        weight: 65.5,
        height: 165.0,
        bmi: 24.1,
        waistCm: 82.0,
        sbp: 130.0,
        dbp: 85.0,
        pulse: 78.0,
        bloodSugar: 110.0,
        results: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ScreeningVitalsCard(screening: screening),
            ),
          ),
        ),
      );

      expect(find.text('ข้อมูลสัญญาณชีพและร่างกาย'), findsOneWidget);
      expect(find.text('65.5 กก.'), findsOneWidget);
      expect(find.text('165.0 ซม.'), findsOneWidget);
      expect(find.text('24.1 kg/m²'), findsOneWidget);
      expect(find.text('82.0 ซม.'), findsOneWidget);
      expect(find.text('130/85 mmHg'), findsOneWidget);
      expect(find.text('78 ครั้ง/นาที'), findsOneWidget);
      expect(find.text('110.0 mg/dL'), findsOneWidget);
    });

    testWidgets(
      'ScreeningLifestyleGuidanceSection renders header and bento cards',
      (tester) async {
        final screening = Screening(
          screenId: 's1',
          patientId: 'p1',
          vhvId: 'v1',
          screeningDate: DateTime(2025, 3, 15),
          ageAtScreening: 60,
          createdAt: DateTime(2025, 3, 15),
          weight: 65.5,
          height: 165.0,
          bmi: 24.1,
          waistCm: 82.0,
          sbp: 130.0,
          dbp: 85.0,
          pulse: 78.0,
          bloodSugar: 110.0,
          results: const [
            ScreeningResult(
              resultId: 'r1',
              screeningId: 's1',
              diseaseName: 'โรคเบาหวาน',
              diseaseCode: 'DIABETES',
              riskLevel: RiskLevel.moderate,
              score: 50,
              adviceText: 'ควบคุมอาหาร',
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ScreeningLifestyleGuidanceSection(screening: screening),
              ),
            ),
          ),
        );

        expect(find.text('คู่มือการปฏิบัติตัวและอาหารสุขภาพ'), findsOneWidget);
        expect(
          find.text('คำแนะนำเข้าใจง่ายสำหรับประชาชนและผู้สูงอายุ'),
          findsOneWidget,
        );
      },
    );
  });
}
