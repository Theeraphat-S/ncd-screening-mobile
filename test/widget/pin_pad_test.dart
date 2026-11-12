import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/feature/auth/widgets/pin_pad.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

Future<void> _tap(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.byKey(Key('pin_key_$d')));
    await tester.pump();
  }
}

void main() {
  testWidgets('calls onCompleted once after exactly 6 digits', (tester) async {
    final completed = <String>[];
    await tester.pumpWidget(_wrap(PinPad(onCompleted: completed.add)));

    await _tap(tester, '48291');
    expect(completed, isEmpty);

    await _tap(tester, '3');
    expect(completed, ['482913']);
  });

  testWidgets('backspace removes the last digit', (tester) async {
    final completed = <String>[];
    await tester.pumpWidget(_wrap(PinPad(onCompleted: completed.add)));

    await _tap(tester, '4829');
    await tester.tap(find.byKey(const Key('pin_key_backspace')));
    await tester.pump();
    await _tap(tester, '135');
    expect(completed, ['482135']);
  });

  testWidgets('shows filled dots as digits are entered and hides the digits',
      (tester) async {
    await tester.pumpWidget(_wrap(PinPad(onCompleted: (_) {})));
    expect(find.byKey(const Key('pin_dot_filled')), findsNothing);

    await _tap(tester, '12');
    expect(find.byKey(const Key('pin_dot_filled')), findsNWidgets(2));
    expect(find.text('12'), findsNothing);
  });

  testWidgets('input clears after completion so the pad can be reused',
      (tester) async {
    final completed = <String>[];
    await tester.pumpWidget(_wrap(PinPad(onCompleted: completed.add)));

    await _tap(tester, '482913');
    expect(find.byKey(const Key('pin_dot_filled')), findsNothing);
    await _tap(tester, '135790');
    expect(completed, ['482913', '135790']);
  });

  testWidgets('disabled pad ignores taps', (tester) async {
    final completed = <String>[];
    await tester.pumpWidget(
      _wrap(PinPad(onCompleted: completed.add, enabled: false)),
    );
    await _tap(tester, '482913');
    expect(completed, isEmpty);
  });

  testWidgets('shows an error message when provided', (tester) async {
    await tester.pumpWidget(
      _wrap(PinPad(onCompleted: (_) {}, errorText: 'PIN ไม่ถูกต้อง')),
    );
    expect(find.text('PIN ไม่ถูกต้อง'), findsOneWidget);
  });

  testWidgets('keys are at least 48dp for field use', (tester) async {
    await tester.pumpWidget(_wrap(PinPad(onCompleted: (_) {})));
    for (final d in ['0', '1', '5', '9']) {
      final size = tester.getSize(find.byKey(Key('pin_key_$d')));
      expect(size.shortestSide, greaterThanOrEqualTo(48), reason: d);
    }
  });
}
