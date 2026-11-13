import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/data/repositories/screening_draft_store.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/feature/screening/bloc/screening_bloc.dart';
import 'package:ncd_screening_mobile/feature/screening/pages/risk_assessment_result_page.dart';
import 'package:ncd_screening_mobile/feature/screening/pages/screening_form_page.dart';
import 'package:ncd_screening_mobile/locator.dart';
import 'package:ncd_screening_mobile/shared/bloc/accessibility/accessibility_cubit.dart';

class _FakeRepo extends MockNcdRepository {
  int saveCalls = 0;
  bool fail = false;
  Completer<void>? gate;

  @override
  Future<Screening> saveScreening(Screening screening) async {
    saveCalls++;
    if (gate != null) await gate!.future;
    if (fail) throw Exception('disk full');
    return screening;
  }
}

final _patient = Patient(
  patientId: 'P001',
  patientCitizenId: '1234567890123',
  patientTitle: 'นาย',
  patientFname: 'สมชาย',
  patientLname: 'ใจดี',
  patientGender: 'ชาย',
  patientBirthDate: DateTime(1970, 1, 1),
  patientAddress: '1 ม.1',
  villageId: 'V001',
);

final _vhv = VHV(
  vhvId: 'VHV001',
  vhvCitizenId: '1111111111119',
  vhvTitle: 'นาง',
  vhvFname: 'อสม',
  vhvLname: 'ทดสอบ',
  vhvMobile: '0800000000',
  vhvEmail: 'a@b.c',
  vhvPassword: 'x',
  vhvBirthDate: DateTime(1980, 1, 1),
  vhvGender: 'หญิง',
  vhvAddress: '-',
  villageId: 'V001',
);

void main() {
  late AppDatabase db;
  late ScreeningDraftStore drafts;
  late _FakeRepo repo;

  setUp(() async {
    await locator.reset();
    db = AppDatabase(NativeDatabase.memory());
    drafts = ScreeningDraftStore(db);
    repo = _FakeRepo();
  });

  tearDown(() async {
    await locator.reset();
    await db.close();
  });

  Future<void> pumpForm(WidgetTester tester, {Widget? launcher}) async {
    tester.view.physicalSize = const Size(900, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final bloc = ScreeningBloc(repo);
    addTearDown(bloc.close);
    await tester.pumpWidget(
      RepositoryProvider<ScreeningDraftStore>.value(
        value: drafts,
        child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: bloc),
          BlocProvider(create: (_) => AccessibilityCubit()),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                key: const Key('open_form'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ScreeningFormPage(patient: _patient, vhv: _vhv),
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
    await tester.tap(find.byKey(const Key('open_form')));
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, String field, String text) async {
    await tester.enterText(find.byKey(Key('field_$field')), text);
    await tester.pump();
  }

  Future<void> fillValid(WidgetTester tester) async {
    await type(tester, 'weight', '60');
    await type(tester, 'height', '165');
    await type(tester, 'waist', '80');
    await type(tester, 'sbp', '120');
    await type(tester, 'dbp', '80');
    await type(tester, 'pulse', '72');
    await tester.tap(find.byKey(const Key('q1_ไม่มี')));
    await tester.tap(find.byKey(const Key('q4_ไม่มี')));
    await tester.pump();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const Key('submit_screening')));
    await tester.tap(find.byKey(const Key('submit_screening')));
    await tester.pumpAndSettle();
  }

  String text(WidgetTester tester, String field) => tester
      .widget<TextFormField>(find.byKey(Key('field_$field')))
      .controller!
      .text;

  testWidgets('every measurement starts empty (no pre-filled normal values)',
      (tester) async {
    await pumpForm(tester);
    for (final f in ['weight', 'height', 'waist', 'sbp', 'dbp', 'pulse', 'bloodSugar']) {
      expect(text(tester, f), isEmpty, reason: f);
    }
  });

  testWidgets('submitting empty form shows errors under the fields and saves nothing',
      (tester) async {
    await pumpForm(tester);
    await submit(tester);

    expect(repo.saveCalls, 0);
    expect(find.byIcon(Icons.error_outline_rounded), findsWidgets);
    expect(find.text('กรุณาเลือกคำตอบ'), findsNWidgets(2));
  });

  testWidgets('600 kg is rejected with a message under the weight field',
      (tester) async {
    await pumpForm(tester);
    await fillValid(tester);
    await type(tester, 'weight', '600');
    await submit(tester);

    expect(repo.saveCalls, 0);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets('height typed in metres (1.75) gets an error, not a silent save',
      (tester) async {
    await pumpForm(tester);
    await fillValid(tester);
    await type(tester, 'height', '1.75');
    await submit(tester);

    expect(repo.saveCalls, 0);
    expect(find.textContaining('เซนติเมตร'), findsWidgets);
  });

  testWidgets('blood sugar is optional: form saves without it', (tester) async {
    await pumpForm(tester);
    await fillValid(tester);
    await submit(tester);

    expect(repo.saveCalls, 1);
    expect(find.byType(RiskAssessmentResultPage), findsOneWidget);
  });

  testWidgets('live BMI appears while typing', (tester) async {
    await pumpForm(tester);
    await type(tester, 'weight', '60');
    await type(tester, 'height', '165');

    expect(find.byKey(const Key('live_bmi')), findsOneWidget);
    expect(find.textContaining('22'), findsWidgets);
  });

  testWidgets('keyboard "next" moves focus weight -> height', (tester) async {
    await pumpForm(tester);
    await tester.tap(find.byKey(const Key('field_weight')));
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();

    final height = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const Key('field_height')),
        matching: find.byType(EditableText),
      ),
    );
    expect(height.focusNode.hasFocus, isTrue);
  });

  testWidgets('abnormal-but-possible value asks for confirmation before saving',
      (tester) async {
    await pumpForm(tester);
    await fillValid(tester);
    await type(tester, 'sbp', '190');
    await type(tester, 'dbp', '100');
    await submit(tester);

    expect(find.text('ค่าที่กรอกผิดปกติ'), findsOneWidget);
    expect(repo.saveCalls, 0);

    await tester.tap(find.text('ตรวจสอบอีกครั้ง'));
    await tester.pumpAndSettle();
    expect(repo.saveCalls, 0);

    await submit(tester);
    await tester.tap(find.text('ยืนยันและบันทึก'));
    await tester.pumpAndSettle();
    expect(repo.saveCalls, 1);
  });

  testWidgets('input is autosaved and restored with a banner next time',
      (tester) async {
    await pumpForm(tester);
    await type(tester, 'weight', '71');
    await tester.tap(find.byKey(const Key('q1_มี')));
    await tester.pump();
    await tester.runAsync(() async {});
    await tester.pump(const Duration(milliseconds: 800));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));

    expect(await tester.runAsync(() => drafts.load('P001', 'VHV001')), isNotNull);

    // Re-open the form on a fresh page.
    await tester.pumpWidget(const SizedBox());
    await pumpForm(tester);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('restored_banner')), findsOneWidget);
    expect(text(tester, 'weight'), '71');
  });

  testWidgets('leaving with data asks first; "keep" stores the draft',
      (tester) async {
    await pumpForm(tester);
    await type(tester, 'weight', '65');

    final back = tester.state<NavigatorState>(find.byType(Navigator));
    unawaited(back.maybePop());
    await tester.pumpAndSettle();
    expect(find.text('ออกจากแบบฟอร์มคัดกรอง?'), findsOneWidget);

    await tester.tap(find.text('อยู่ต่อ'));
    await tester.pumpAndSettle();
    expect(find.byType(ScreeningFormPage), findsOneWidget);

    unawaited(back.maybePop());
    await tester.pumpAndSettle();
    await tester.tap(find.text('ออก (เก็บไว้)'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    expect(find.byType(ScreeningFormPage), findsNothing);
    final draft = await tester.runAsync(() => drafts.load('P001', 'VHV001'));
    expect(draft?.data['weight'], '65');
  });

  testWidgets('empty form can be left without a prompt', (tester) async {
    await pumpForm(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    unawaited(nav.maybePop());
    await tester.pumpAndSettle();
    expect(find.byType(ScreeningFormPage), findsNothing);
  });

  testWidgets('save failure keeps the user on the form with their data',
      (tester) async {
    repo.fail = true;
    await pumpForm(tester);
    await fillValid(tester);
    await submit(tester);

    expect(find.byType(RiskAssessmentResultPage), findsNothing);
    expect(find.byType(ScreeningFormPage), findsOneWidget);
    expect(text(tester, 'weight'), '60');
    expect(find.textContaining('กรุณาลองใหม่'), findsOneWidget);

    // and it can be retried
    repo.fail = false;
    await submit(tester);
    expect(find.byType(RiskAssessmentResultPage), findsOneWidget);
  });

  testWidgets('double tap while saving only saves once', (tester) async {
    repo.gate = Completer<void>();
    await pumpForm(tester);
    await fillValid(tester);

    await tester.ensureVisible(find.byKey(const Key('submit_screening')));
    await tester.tap(find.byKey(const Key('submit_screening')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('submit_screening')), warnIfMissed: false);
    await tester.pump();

    expect(repo.saveCalls, 1);
    repo.gate!.complete();
    await tester.pumpAndSettle();
    expect(repo.saveCalls, 1);
    expect(find.byType(RiskAssessmentResultPage), findsOneWidget);
  });

  testWidgets('after a successful save the draft is gone', (tester) async {
    await pumpForm(tester);
    await fillValid(tester);
    await submit(tester);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));

    expect(await tester.runAsync(() => drafts.load('P001', 'VHV001')), isNull);
  });
}
