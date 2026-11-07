import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/auth/bloc/auth_bloc.dart';
import 'package:ncd_screening_mobile/feature/auth/pages/login_page.dart';
import 'package:ncd_screening_mobile/feature/auth/pages/user_type_selection_page.dart';
import 'package:ncd_screening_mobile/shared/bloc/language/language_bloc.dart';
import 'support/mock_ncd_repository.dart';

void main() {
  late MockNcdRepository mockRepository;
  late AuthBloc authBloc;

  setUp(() {
    mockRepository = MockNcdRepository();
    authBloc = AuthBloc(mockRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<LanguageBloc>(create: (_) => LanguageBloc()),
      ],
      child: const MaterialApp(home: UserTypeSelectionPage()),
    );
  }

  group('UserTypeSelectionPage Widget Tests', () {
    testWidgets('renders header, hospital icon, and instructions', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify Hospital Icon and title texts
      expect(find.byIcon(Icons.local_hospital_rounded), findsOneWidget);
      expect(
        find.text('คัดกรองความเสี่ยง\n4 โรคไม่ติดต่อเรื้อรัง'),
        findsOneWidget,
      );
      expect(find.text('รพ.สต.แม่อาย จ.เชียงใหม่'), findsOneWidget);
      expect(find.text('เลือกประเภทผู้ใช้งานเพื่อเข้าสู่ระบบ'), findsOneWidget);
    });

    testWidgets('renders all 3 user role options properly', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createWidgetUnderTest());

      // 1. บุคคลทั่วไป (Patient)
      expect(find.text('บุคคลทั่วไป'), findsOneWidget);
      expect(
        find.text('เข้าดูประวัติและผลการคัดกรองสุขภาพของตนเอง'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);

      // 2. สำหรับ อสม. (VHV)
      expect(find.text('สำหรับ อสม.'), findsOneWidget);
      expect(
        find.text('บันทึกข้อมูลผู้ป่วยและทำแบบคัดกรองสุขภาพในชุมชน'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.volunteer_activism_outlined), findsOneWidget);

      // 3. สำหรับพยาบาล (Nurse)
      expect(find.text('สำหรับพยาบาล'), findsOneWidget);
      expect(
        find.text('ดูแลข้อมูล อสม. และอนุมัติผลการประเมินความเสี่ยง'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.medical_services_outlined), findsOneWidget);
    });

    testWidgets(
      'tapping บุคคลทั่วไป selects Patient role and navigates to LoginPage',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createWidgetUnderTest());

        final patientCard = find.text('บุคคลทั่วไป');
        await tester.ensureVisible(patientCard);
        await tester.tap(patientCard);
        await tester.pumpAndSettle();

        expect(authBloc.state.selectedRole, equals(UserRole.patient));
        expect(find.byType(LoginPage), findsOneWidget);
        expect(find.text('เข้าสู่ระบบ (บุคคลทั่วไป)'), findsWidgets);
      },
    );

    testWidgets(
      'tapping สำหรับ อสม. selects VHV role and navigates to LoginPage',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createWidgetUnderTest());

        final vhvCard = find.text('สำหรับ อสม.');
        await tester.ensureVisible(vhvCard);
        await tester.tap(vhvCard);
        await tester.pumpAndSettle();

        expect(authBloc.state.selectedRole, equals(UserRole.vhv));
        expect(find.byType(LoginPage), findsOneWidget);
        expect(find.text('เข้าสู่ระบบ อสม.'), findsWidgets);
      },
    );

    testWidgets(
      'tapping สำหรับพยาบาล selects Nurse role and navigates to LoginPage',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createWidgetUnderTest());

        final nurseCard = find.text('สำหรับพยาบาล');
        await tester.ensureVisible(nurseCard);
        await tester.tap(nurseCard);
        await tester.pumpAndSettle();

        expect(authBloc.state.selectedRole, equals(UserRole.nurse));
        expect(find.byType(LoginPage), findsOneWidget);
        expect(find.text('เข้าสู่ระบบพยาบาล'), findsWidgets);
      },
    );
  });
}
