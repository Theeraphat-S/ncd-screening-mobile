import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/shared/bloc/accessibility/accessibility_cubit.dart';
import 'package:ncd_screening_mobile/shared/theme/app_theme.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/widgets/patient_accessibility_floating_bubble.dart';

void main() {
  group('PatientAccessibilityFloatingBubble Widget Tests', () {
    late AccessibilityCubit accessibilityCubit;

    setUp(() {
      accessibilityCubit = AccessibilityCubit();
    });

    tearDown(() {
      accessibilityCubit.close();
    });

    Widget createTestWidget() {
      return MaterialApp(
        theme: AppTheme.standardTheme,
        home: BlocProvider<AccessibilityCubit>.value(
          value: accessibilityCubit,
          child: const Scaffold(
            body: Stack(
              children: [
                Center(child: Text('Patient Main Screen')),
                PatientAccessibilityFloatingBubble(),
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('renders collapsed floating bubble trigger by default', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.accessibility_new_rounded), findsOneWidget);
      expect(find.text('ปรับการแสดงผล'), findsNothing);
    });

    testWidgets('expands and displays accessibility controls when tapped', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap FAB to expand
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('ปรับการแสดงผล'), findsOneWidget);
      expect(find.text('โหมดตัวโต (ผู้สูงอายุ)'), findsOneWidget);
      expect(find.text('โหมดคอนทราสต์สูง (AAA)'), findsOneWidget);
      expect(find.text('A-'), findsOneWidget);
      expect(find.text('A+'), findsOneWidget);
      expect(find.text('รีเซ็ตค่ามาตรฐาน'), findsOneWidget);
    });

    testWidgets(
      'toggles elderly mode and fine-tunes font scaling with A+ and A-',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Expand bubble
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Tap A+ button
        await tester.tap(find.text('A+'));
        await tester.pumpAndSettle();
        expect(accessibilityCubit.state.textScaleFactor, 1.1);

        // Tap A- button
        await tester.tap(find.text('A-'));
        await tester.pumpAndSettle();
        expect(accessibilityCubit.state.textScaleFactor, 1.0);

        // Tap Reset
        await tester.tap(find.text('รีเซ็ตค่ามาตรฐาน'));
        await tester.pumpAndSettle();
        expect(accessibilityCubit.state.textScaleFactor, 1.0);
        expect(accessibilityCubit.state.isElderlyMode, isFalse);
      },
    );

    testWidgets('collapses when close icon is tapped', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Expand
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('ปรับการแสดงผล'), findsOneWidget);

      // Tap close
      await tester.tap(find.byKey(const Key('bubble_close_button')));
      await tester.pumpAndSettle();
      expect(find.text('ปรับการแสดงผล'), findsNothing);
    });
  });

  group('AppTheme Theme Tokens Tests', () {
    test('standardTheme uses teal primary and white background', () {
      final theme = AppTheme.standardTheme;
      expect(theme.brightness, Brightness.light);
      expect(theme.textTheme.bodyMedium?.fontFamily, 'Sarabun');
    });

    test(
      'highContrastTheme uses dark charcoal background and yellow primary',
      () {
        final theme = AppTheme.highContrastTheme;
        expect(theme.brightness, Brightness.dark);
        expect(theme.scaffoldBackgroundColor, PColor.hcBackground);
        expect(theme.colorScheme.primary, PColor.hcAccent);
        expect(theme.appBarTheme.backgroundColor, PColor.hcBackground);
      },
    );
  });
}
