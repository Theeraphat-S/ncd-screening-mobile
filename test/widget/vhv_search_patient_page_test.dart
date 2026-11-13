import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/feature/patient/bloc/patient_bloc.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/vhv_search_patient_page.dart';

class _Repo extends MockNcdRepository {
  final List<String?> queries = [];
  final List<Patient> data;
  _Repo(this.data);

  @override
  Future<List<Patient>> getPatients({String? villageId, String? searchQuery}) async {
    queries.add(searchQuery);
    return data
        .where((p) => searchQuery == null || searchQuery.isEmpty
            ? true
            : p.patientFname.contains(searchQuery) ||
                p.patientAddress.contains(searchQuery))
        .toList();
  }
}

Patient _patient(String id, String fname, String address) => Patient(
      patientId: id,
      patientCitizenId: '150990012345$id',
      patientTitle: 'นาย',
      patientFname: fname,
      patientLname: 'ทดสอบ',
      patientGender: 'ชาย',
      patientBirthDate: DateTime(1970, 1, 1),
      patientAddress: address,
      villageId: 'V1',
    );

final _vhv = VHV(
  vhvId: 'VHV1',
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
  villageId: 'V1',
);

void main() {
  setUpAll(() async {
    final loader = FontLoader('Sarabun')
      ..addFont(rootBundle.load('assets/fonts/Sarabun-Regular.ttf'));
    await loader.load();
  });

  late _Repo repo;

  Future<void> pumpPage(WidgetTester tester) async {
    repo = _Repo([
      _patient('1', 'สมชาย', '12/3 หมู่ 1'),
      _patient('2', 'มานี', '99 หมู่ 2'),
    ]);
    final bloc = PatientBloc(repo);
    addTearDown(bloc.close);
    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(home: VhvSearchPatientPage(vhv: _vhv)),
      ),
    );
  }

  testWidgets('searches by itself after the user pauses typing (300 ms)',
      (tester) async {
    await pumpPage(tester);
    await tester.enterText(find.byType(TextField), 'สม');
    await tester.pump(const Duration(milliseconds: 200));
    expect(repo.queries, isEmpty, reason: 'still within the debounce window');

    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();
    expect(repo.queries, ['สม']);
    expect(find.textContaining('สมชาย'), findsOneWidget);
    expect(find.textContaining('มานี'), findsNothing);
  });

  testWidgets('fast typing sends only one query for the final text',
      (tester) async {
    await pumpPage(tester);
    for (final t in ['ส', 'สม', 'สมช']) {
      await tester.enterText(find.byType(TextField), t);
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(repo.queries, ['สมช']);
  });

  testWidgets('results show the house number', (tester) async {
    await pumpPage(tester);
    await tester.enterText(find.byType(TextField), '99');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.textContaining('99 หมู่ 2'), findsOneWidget);
  });

  testWidgets('no match shows the empty message', (tester) async {
    await pumpPage(tester);
    await tester.enterText(find.byType(TextField), 'ไม่มีคนนี้');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('ไม่พบข้อมูล'), findsOneWidget);
  });

  testWidgets('clearing the box restores the prompt without searching',
      (tester) async {
    await pumpPage(tester);
    await tester.enterText(find.byType(TextField), 'สม');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('ล้างคำค้นหา'));
    await tester.pumpAndSettle();

    expect(find.textContaining('พิมพ์ชื่อ'), findsOneWidget);
    expect(find.textContaining('สมชาย'), findsNothing);
  });

  testWidgets('pressing the search button searches immediately', (tester) async {
    await pumpPage(tester);
    await tester.enterText(find.byType(TextField), 'มานี');
    await tester.tap(find.text('ค้นหา'));
    await tester.pumpAndSettle();

    expect(repo.queries, ['มานี']);
  });

  testWidgets('phone width with 2x system text scale shows results without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    repo = _Repo([
      _patient('1', 'สมชาย', '12/3 หมู่ 1 ตำบลท่าตอน อำเภอแม่อาย'),
      _patient('2', 'มานี', '99 หมู่ 2 ตำบลท่าตอน อำเภอแม่อาย'),
    ]);
    final bloc = PatientBloc(repo);
    addTearDown(bloc.close);
    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(
          theme: ThemeData(fontFamily: 'Sarabun'),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2.0)),
            child: child!,
          ),
          home: VhvSearchPatientPage(vhv: _vhv),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'สม');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
