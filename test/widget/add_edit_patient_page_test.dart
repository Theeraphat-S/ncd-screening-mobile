import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/feature/patient/bloc/patient_bloc.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/add_edit_patient_page.dart';
import 'package:ncd_screening_mobile/shared/theme/app_theme.dart';
import 'package:ncd_screening_mobile/shared/widgets/app_feedback.dart';

class _FailingAddRepository extends MockNcdRepository {
  @override
  Future<Patient> addPatient(Patient patient) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    throw Exception('duplicate citizen id');
  }
}

void main() {
  late PatientBloc bloc;

  tearDown(() => bloc.close());

  /// Opens the form on top of a launcher page, so popping is observable.
  Future<void> openForm(
    WidgetTester tester, {
    NcdRepositoryInterface? repository,
    Size size = const Size(400, 900),
    double textScale = 1.0,
  }) async {
    bloc = PatientBloc(repository ?? MockNcdRepository());
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BlocProvider<PatientBloc>.value(
        value: bloc,
        child: MaterialApp(
          theme: AppTheme.standardTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
            ),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddEditPatientPage(villageId: 'V001'),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.descendant(
        of: find.ancestor(
          of: find.text(label),
          matching: find.byType(Column),
        ).first,
        matching: find.byType(TextFormField),
      );

  Future<void> fillValid(WidgetTester tester) async {
    await tester.enterText(field('เลขบัตรประชาชน'), '1234567890121');
    await tester.enterText(field('ชื่อ'), 'สมชาย');
    await tester.enterText(field('นามสกุล'), 'ใจดี');
    await tester.enterText(field('ที่อยู่'), '60 หมู่ 1');
  }

  Future<void> tapSave(WidgetTester tester) async {
    final save = find.text('บันทึก');
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pump();
  }

  testWidgets('an empty form shows each problem under its own field',
      (tester) async {
    await openForm(tester);
    await tapSave(tester);
    await tester.pumpAndSettle();

    expect(find.text('กรุณากรอกเลขบัตรประชาชน'), findsOneWidget);
    expect(find.text('กรุณากรอกชื่อ'), findsOneWidget);
    expect(find.text('กรุณากรอกนามสกุล'), findsOneWidget);
    expect(find.text('กรุณากรอกที่อยู่ให้ครบถ้วน'), findsOneWidget);
    expect(find.byType(InlineAlert), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.byType(AddEditPatientPage), findsOneWidget);
  });

  testWidgets('a wrong check digit is reported on the ID field',
      (tester) async {
    await openForm(tester);
    await fillValid(tester);
    await tester.enterText(field('เลขบัตรประชาชน'), '1234567890123');
    await tapSave(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('เลขบัตรประชาชนไม่ถูกต้อง กรุณาตรวจสอบตัวเลขอีกครั้ง'),
      findsOneWidget,
    );
  });

  testWidgets('a successful save closes the form', (tester) async {
    await openForm(tester);
    await fillValid(tester);
    await tapSave(tester);

    expect(find.text('กำลังบันทึก…'), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.byType(AddEditPatientPage), findsNothing);
    expect(bloc.state.patients.first.patientFname, 'สมชาย');
  });

  testWidgets('a failed save keeps the form open with the typed data',
      (tester) async {
    await openForm(tester, repository: _FailingAddRepository());
    await fillValid(tester);
    await tapSave(tester);
    await tester.pumpAndSettle();

    expect(find.byType(AddEditPatientPage), findsOneWidget);
    expect(find.byType(InlineAlert), findsOneWidget);
    expect(find.text('สมชาย'), findsOneWidget);
    expect(find.text('บันทึก'), findsOneWidget);
  });

  testWidgets('leaving with unsaved input asks first', (tester) async {
    await openForm(tester);
    await tester.enterText(field('ชื่อ'), 'สมชาย');
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('ออกโดยไม่บันทึก?'), findsOneWidget);

    await tester.tap(find.text('กรอกต่อ'));
    await tester.pumpAndSettle();
    expect(find.byType(AddEditPatientPage), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'ออกโดยไม่บันทึก'));
    await tester.pumpAndSettle();
    expect(find.byType(AddEditPatientPage), findsNothing);
  });

  testWidgets('an untouched form leaves without asking', (tester) async {
    await openForm(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('ออกโดยไม่บันทึก?'), findsNothing);
    expect(find.byType(AddEditPatientPage), findsNothing);
  });

  testWidgets('no overflow on a small phone with large text and all errors',
      (tester) async {
    await openForm(tester, size: const Size(320, 640), textScale: 1.6);
    await tapSave(tester);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
