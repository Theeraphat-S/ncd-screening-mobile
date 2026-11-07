import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_lifestyle_advisor.dart';
import 'package:ncd_screening_mobile/shared/bloc/accessibility/accessibility_cubit.dart';
import 'package:ncd_screening_mobile/shared/widgets/elderly_bento_advice_card.dart';

void main() {
  group('Elderly UI & Accessibility Widgets', () {
    const sampleAdvice = PlainHealthAdvice(
      diseaseName: 'โรคเบาหวาน (ระดับน้ำตาลในเลือด)',
      conditionSummary: 'ค่าน้ำตาลในเลือด 145.0 มก./ดล. (อยู่ในเกณฑ์สูง)',
      riskLevel: RiskLevel.high,
      riskLabelThai: 'เสี่ยงสูง (พบแพทย์ รพ.สต.)',
      goodFoods: ['ข้าวกล้อง', 'ผักใบเขียวต้ม'],
      avoidFoods: ['น้ำอัดลม', 'ขนมหวาน'],
      exerciseTip: 'เดินเร็วหรือแกว่งแขนวันละ 30 นาที',
      dailyAdvice: 'งดกินน้ำตาลทราย',
      followUpSchedule: 'พบแพทย์ รพ.สต. ภายใน 2 สัปดาห์',
    );

    Widget buildTestWidget({required Widget child, AccessibilityCubit? cubit}) {
      return MaterialApp(
        home: BlocProvider<AccessibilityCubit>(
          create: (_) => cubit ?? AccessibilityCubit(),
          child: Scaffold(
            appBar: AppBar(actions: const [AccessibilityScaleToggle()]),
            body: child,
          ),
        ),
      );
    }

    testWidgets(
      'renders ElderlyBentoAdviceCard with plain Thai guidance and tags',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const SingleChildScrollView(
              child: ElderlyBentoAdviceCard(advice: sampleAdvice),
            ),
          ),
        );

        expect(find.text('โรคเบาหวาน (ระดับน้ำตาลในเลือด)'), findsOneWidget);
        expect(find.text('เสี่ยงสูง (พบแพทย์ รพ.สต.)'), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is RichText &&
                widget.text.toPlainText().contains('ข้าวกล้อง'),
          ),
          findsOneWidget,
        );
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is RichText &&
                widget.text.toPlainText().contains('น้ำอัดลม'),
          ),
          findsOneWidget,
        );
        expect(
          find.textContaining('พบแพทย์ รพ.สต. ภายใน 2 สัปดาห์'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'AccessibilityScaleToggle switches between standard and elderly font scale',
      (tester) async {
        final cubit = AccessibilityCubit();

        await tester.pumpWidget(
          buildTestWidget(
            cubit: cubit,
            child: const SingleChildScrollView(
              child: ElderlyBentoAdviceCard(advice: sampleAdvice),
            ),
          ),
        );

        expect(find.text('โหมดตัวโต'), findsOneWidget);
        expect(cubit.state.isElderlyMode, isFalse);

        // Tap toggle button
        await tester.tap(find.byType(AccessibilityScaleToggle));
        await tester.pumpAndSettle();

        expect(find.text('โหมดตัวโต (เปิด)'), findsOneWidget);
        expect(cubit.state.isElderlyMode, isTrue);
        expect(cubit.state.textScaleFactor, 1.35);
      },
    );
  });
}
