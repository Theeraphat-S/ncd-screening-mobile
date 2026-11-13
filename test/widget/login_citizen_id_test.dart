import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/feature/auth/bloc/auth_bloc.dart';
import 'package:ncd_screening_mobile/feature/auth/pages/login_page.dart';

void main() {
  const invalidIdMessage = 'เลขบัตรประชาชนไม่ถูกต้อง กรุณาตรวจสอบตัวเลขอีกครั้ง';

  late AuthBloc authBloc;

  setUp(() => authBloc = AuthBloc(MockNcdRepository()));
  tearDown(() => authBloc.close());

  Future<void> openPatientLogin(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const MaterialApp(home: LoginPage(role: UserRole.patient)),
      ),
    );
  }

  Future<void> submit(WidgetTester tester, String citizenId) async {
    await tester.enterText(find.byType(TextField).first, citizenId);
    final button = find.widgetWithText(ElevatedButton, 'เข้าสู่ระบบ');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
  }

  testWidgets('patient login rejects a 13-digit ID with a wrong check digit',
      (tester) async {
    await openPatientLogin(tester);
    await submit(tester, '1234567890123');

    expect(find.text(invalidIdMessage), findsOneWidget);
  });

  testWidgets('patient login accepts an ID with a correct check digit',
      (tester) async {
    await openPatientLogin(tester);
    await submit(tester, '1234567890121');

    expect(find.text(invalidIdMessage), findsNothing);
  });
}
