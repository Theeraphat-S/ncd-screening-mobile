import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/feature/screening/bloc/screening_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/add_edit_patient_page.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/id_card_scanner_page.dart';
import 'package:ncd_screening_mobile/feature/screening/pages/screening_form_page.dart';

class MockNcdRepository implements NcdRepositoryInterface {
  final Map<String, Patient> patientsByCitizenId = {};

  @override
  Future<Patient?> getPatientByCitizenId(String citizenId) async {
    return patientsByCitizenId[citizenId];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockNcdRepository mockRepo;
  final testVhv = VHV(
    vhvId: 'VHV001',
    vhvCitizenId: '1500200000001',
    vhvTitle: 'นาย',
    vhvFname: 'สมศักดิ์',
    vhvLname: 'อาสาดี',
    vhvGender: 'ชาย',
    vhvBirthDate: DateTime(1985, 5, 15),
    vhvAddress: '123 ม.1',
    vhvMobile: '0812345678',
    vhvEmail: 'vhv1@example.com',
    vhvPassword: 'password123',
    villageId: 'V01',
  );

  final testPatient = Patient(
    patientId: 'P001',
    patientCitizenId: '1500200000010',
    patientTitle: 'นาย',
    patientFname: 'สมชาย',
    patientLname: 'ใจดี',
    patientGender: 'ชาย',
    patientBirthDate: DateTime(1972, 1, 15),
    patientAddress: '45 ม.1',
    patientMobile: '0899999999',
    villageId: 'V01',
  );

  setUp(() {
    mockRepo = MockNcdRepository();
    final locator = GetIt.instance;
    if (locator.isRegistered<NcdRepositoryInterface>()) {
      locator.unregister<NcdRepositoryInterface>();
    }
    locator.registerSingleton<NcdRepositoryInterface>(mockRepo);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget buildTestWidget() {
    // The real app provides ScreeningBloc above the navigator (see main.dart).
    return BlocProvider<ScreeningBloc>(
      create: (_) => ScreeningBloc(mockRepo),
      child: MaterialApp(home: IdCardScannerPage(vhv: testVhv)),
    );
  }

  group('IdCardScannerPage', () {
    testWidgets('renders scanner UI elements properly', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('สแกนบัตรประชาชน (OCR)'), findsOneWidget);
      expect(find.text('วางบัตรประชาชนให้อยู่ในกรอบ'), findsOneWidget);
      expect(find.text('ทดสอบผู้ป่วยเดิม'), findsOneWidget);
      expect(find.text('ทดสอบคนใหม่'), findsOneWidget);
    });

    testWidgets('matches existing patient and navigates to ScreeningFormPage', (tester) async {
      mockRepo.patientsByCitizenId['1500200000010'] = testPatient;

      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('ทดสอบผู้ป่วยเดิม'));
      await tester.pumpAndSettle();

      expect(find.byType(ScreeningFormPage), findsOneWidget);
    });

    testWidgets('routes to AddEditPatientPage with pre-filled info for new patient', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('ทดสอบคนใหม่'));
      await tester.pumpAndSettle();

      expect(find.byType(AddEditPatientPage), findsOneWidget);
      expect(find.text('1500299988877'), findsOneWidget);
      expect(find.text('วันเพ็ญ'), findsOneWidget);
      expect(find.text('สดใส'), findsOneWidget);
    });
  });
}
