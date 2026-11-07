import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_risk_calculator.dart';
import 'package:ncd_screening_mobile/domain/services/pdf_report_service.dart';
import 'package:ncd_screening_mobile/feature/patient/bloc/patient_bloc.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/patient_screening_detail_page.dart';
import 'package:ncd_screening_mobile/feature/screening/bloc/screening_bloc.dart';
import 'package:ncd_screening_mobile/feature/screening/pages/pdf_preview_page.dart';
import 'package:ncd_screening_mobile/feature/screening/pages/risk_assessment_result_page.dart';
import 'package:ncd_screening_mobile/locator.dart';
import 'package:ncd_screening_mobile/shared/bloc/accessibility/accessibility_cubit.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../support/mock_ncd_repository.dart';

class FakePdfReportService implements PdfReportServiceInterface {
  bool generateCalled = false;
  Uint8List? returnBytes;

  @override
  Future<Uint8List> generateScreeningReport({
    required Patient patient,
    required Screening screening,
    VHV? vhv,
    Nurse? nurse,
    Village? village,
  }) async {
    generateCalled = true;
    if (returnBytes != null) return returnBytes!;
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Center(
          child: pw.Text('Report: ${patient.fullName} - ${screening.screenId}'),
        ),
      ),
    );
    return pdf.save();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockNcdRepository mockRepository;
  late ScreeningBloc screeningBloc;
  late PatientBloc patientBloc;
  late AccessibilityCubit accessibilityCubit;
  late FakePdfReportService fakePdfService;

  final samplePatient = Patient(
    patientId: 'P001',
    patientCitizenId: '1509900123456',
    patientTitle: 'นาย',
    patientFname: 'สมชาย',
    patientLname: 'ใจดี',
    patientGender: 'ชาย',
    patientBirthDate: DateTime(1975, 5, 12),
    patientAddress: '123 หมู่ 1 ต.ท่าตอน',
    patientMobile: '0812345678',
    villageId: 'VIL001',
  );

  final sampleVhv = VHV(
    vhvId: 'VHV001',
    vhvCitizenId: '1509900987654',
    vhvTitle: 'นาง',
    vhvFname: 'สมศรี',
    vhvLname: 'รักสุข',
    vhvMobile: '0898765432',
    vhvEmail: 'somsri@example.com',
    vhvPassword: 'password123',
    vhvBirthDate: DateTime(1980, 3, 15),
    vhvGender: 'หญิง',
    vhvAddress: '45 หมู่ 1 ต.ท่าตอน',
    villageId: 'VIL001',
  );

  final sampleNurse = Nurse(
    nurseId: 'NUR001',
    nurseTitle: 'นางสาว',
    nurseFname: 'วิภาดา',
    nurseLname: 'สุขสมบูรณ์',
    nurseMobile: '0811122334',
    nurseEmail: 'wipada@maeai-hospital.go.th',
    nursePassword: 'nursepassword',
    nurseGender: 'หญิง',
    nurseBirthDate: DateTime(1990, 8, 20),
    subdistrictId: 'SD001',
  );

  final samplePendingScreening = Screening(
    screenId: 'SCR20260822001',
    patientId: 'P001',
    vhvId: 'VHV001',
    screeningDate: DateTime(2026, 8, 22),
    ageAtScreening: 51,
    createdAt: DateTime(2026, 8, 22, 9, 30),
    reviewStatus: ReviewStatus.pending,
    weight: 68.5,
    height: 168.0,
    bmi: 24.3,
    waistCm: 88.0,
    sbp: 128.0,
    dbp: 82.0,
    pulse: 74.0,
    bloodSugar: 110.0,
    results: NcdRiskCalculator.evaluateRisk(
      screeningId: 'SCR20260822001',
      weight: 68.5,
      height: 168.0,
      bmi: 24.3,
      waistCm: 88.0,
      sbp: 128.0,
      dbp: 82.0,
      pulse: 74.0,
      bloodSugar: 110.0,
      gender: 'ชาย',
    ),
    histories: [
      const ScreeningHistory(
        historyId: 'H001',
        screeningId: 'SCR20260822001',
        questionId: 'Q1',
        questionText: 'มีประวัติโรคเบาหวานในครอบครัวสายตรงหรือไม่',
        answerValue: 1.0,
        answerText: 'มี (บิดา/มารดา)',
      ),
    ],
  );

  final sampleApprovedScreening = samplePendingScreening.copyWith(
    reviewStatus: ReviewStatus.approved,
    reviewedByNurseId: 'NUR001',
    reviewedAt: DateTime(2026, 8, 22, 14, 15),
  );

  setUp(() {
    mockRepository = MockNcdRepository();
    screeningBloc = ScreeningBloc(mockRepository);
    patientBloc = PatientBloc(mockRepository);
    accessibilityCubit = AccessibilityCubit();
    fakePdfService = FakePdfReportService();

    locator.reset();
    locator.registerLazySingleton<PdfReportServiceInterface>(
      () => fakePdfService,
    );
  });

  tearDown(() {
    screeningBloc.close();
    patientBloc.close();
    accessibilityCubit.close();
    locator.reset();
  });

  Widget buildDetailApp({
    required Screening screening,
    Nurse? nurse,
    VHV? vhv,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ScreeningBloc>.value(value: screeningBloc),
        BlocProvider<PatientBloc>.value(value: patientBloc),
        BlocProvider<AccessibilityCubit>.value(value: accessibilityCubit),
      ],
      child: MaterialApp(
        home: PatientScreeningDetailPage(
          patient: samplePatient,
          screening: screening,
          nurse: nurse,
          vhv: vhv,
        ),
      ),
    );
  }

  Widget buildRiskResultApp({required Screening screening, VHV? vhv}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ScreeningBloc>.value(value: screeningBloc),
        BlocProvider<PatientBloc>.value(value: patientBloc),
        BlocProvider<AccessibilityCubit>.value(value: accessibilityCubit),
      ],
      child: MaterialApp(
        home: RiskAssessmentResultPage(
          patient: samplePatient,
          screening: screening,
          vhv: vhv,
        ),
      ),
    );
  }

  group('PatientScreeningDetailPage - UI Navigation & State Stress Tests', () {
    testWidgets('renders pending review screening state correctly', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildDetailApp(screening: samplePendingScreening, vhv: sampleVhv),
      );
      await tester.pumpAndSettle();

      expect(find.text('ผลคัดกรอง: สมชาย ใจดี'), findsOneWidget);
      expect(find.text('รอพยาบาลตรวจสอบและรับรองผล'), findsOneWidget);
      expect(find.text('ผลการประเมินความเสี่ยง 4 โรค'), findsOneWidget);
      expect(find.text('ข้อมูลสัญญาณชีพและร่างกาย'), findsOneWidget);
      expect(find.text('ดูตัวอย่าง / พิมพ์เอกสารสรุปผล (PDF)'), findsOneWidget);
      expect(
        find.byIcon(Icons.picture_as_pdf_outlined),
        findsNWidgets(2),
      ); // AppBar icon + Button icon
    });

    testWidgets(
      'renders approved review screening state correctly with nurse data',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          buildDetailApp(
            screening: sampleApprovedScreening,
            nurse: sampleNurse,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('ผ่านการรับรองโดยพยาบาลแล้ว'), findsOneWidget);
        expect(find.text('ประเมินและยืนยันผล (Submit)'), findsOneWidget);
      },
    );

    testWidgets('tapping AppBar PDF export icon navigates to PdfPreviewPage', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildDetailApp(screening: samplePendingScreening, vhv: sampleVhv),
      );
      await tester.pumpAndSettle();

      final appBarPdfIcon = find.byWidgetPredicate(
        (widget) =>
            widget is IconButton && widget.tooltip == 'ส่งออก/พิมพ์รายงาน PDF',
      );
      expect(appBarPdfIcon, findsOneWidget);

      await tester.tap(appBarPdfIcon);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(PdfPreviewPage), findsOneWidget);
      expect(find.text('ตัวอย่างรายงาน PDF'), findsOneWidget);
      expect(find.text('นายสมชาย ใจดี • SCR20260822001'), findsOneWidget);
    });

    testWidgets(
      'tapping in-body PDF export button navigates to PdfPreviewPage',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          buildDetailApp(
            screening: sampleApprovedScreening,
            nurse: sampleNurse,
          ),
        );
        await tester.pumpAndSettle();

        final exportButton = find.text('ดูตัวอย่าง / พิมพ์เอกสารสรุปผล (PDF)');
        await tester.ensureVisible(exportButton);
        await tester.tap(exportButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byType(PdfPreviewPage), findsOneWidget);
        expect(find.text('ตัวอย่างรายงาน PDF'), findsOneWidget);
      },
    );

    testWidgets(
      'reflects dynamic review state updates from ScreeningBloc historyList',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        // Initially loaded with pending screening in bloc history
        screeningBloc.emit(
          ScreeningState(
            historyList: [samplePendingScreening],
            currentScreening: samplePendingScreening,
          ),
        );

        await tester.pumpWidget(
          buildDetailApp(screening: samplePendingScreening),
        );
        await tester.pumpAndSettle();

        expect(find.text('รอพยาบาลตรวจสอบและรับรองผล'), findsOneWidget);

        // Nurse approves screening -> bloc emits updated historyList
        screeningBloc.emit(
          ScreeningState(
            historyList: [sampleApprovedScreening],
            currentScreening: sampleApprovedScreening,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('ผ่านการรับรองโดยพยาบาลแล้ว'), findsOneWidget);
      },
    );
  });

  group('RiskAssessmentResultPage - UI Navigation & State Stress Tests', () {
    testWidgets('renders all 4 disease risk cards and navigation buttons', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildRiskResultApp(screening: samplePendingScreening, vhv: sampleVhv),
      );
      await tester.pumpAndSettle();

      expect(find.text('แนวโน้มความเสี่ยง'), findsWidgets);
      expect(find.text('มีแนวโน้มความเสี่ยงที่จะเป็น'), findsOneWidget);
      expect(find.text('ผู้ป่วย: นายสมชาย ใจดี'), findsOneWidget);
      expect(find.text('กลับไปหน้ารายชื่อผู้ป่วย'), findsOneWidget);
      expect(
        find.text('ดูตัวอย่างและพิมพ์รายงาน PDF (Export PDF)'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.picture_as_pdf_outlined), findsNWidgets(2));
    });

    testWidgets('tapping AppBar PDF export icon navigates to PdfPreviewPage', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildRiskResultApp(screening: samplePendingScreening, vhv: sampleVhv),
      );
      await tester.pumpAndSettle();

      final appBarPdfIcon = find.byWidgetPredicate(
        (widget) =>
            widget is IconButton && widget.tooltip == 'ส่งออก/พิมพ์รายงาน PDF',
      );
      expect(appBarPdfIcon, findsOneWidget);

      await tester.tap(appBarPdfIcon);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(PdfPreviewPage), findsOneWidget);
      expect(find.text('ตัวอย่างรายงาน PDF'), findsOneWidget);
    });

    testWidgets('tapping body PDF export button navigates to PdfPreviewPage', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildRiskResultApp(screening: samplePendingScreening, vhv: sampleVhv),
      );
      await tester.pumpAndSettle();

      final exportButton = find.text(
        'ดูตัวอย่างและพิมพ์รายงาน PDF (Export PDF)',
      );
      await tester.ensureVisible(exportButton);
      await tester.tap(exportButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(PdfPreviewPage), findsOneWidget);
      expect(find.text('ตัวอย่างรายงาน PDF'), findsOneWidget);
    });
  });

  group('PdfPreviewPage - Widget Error Boundary and Fallback Tests', () {
    testWidgets('renders PDF preview layout and initiates report generation', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: PdfPreviewPage(
            patient: samplePatient,
            screening: samplePendingScreening,
            vhv: sampleVhv,
            pdfReportService: fakePdfService,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PdfPreview), findsOneWidget);
      expect(find.text('ตัวอย่างรายงาน PDF'), findsOneWidget);
      expect(find.text('นายสมชาย ใจดี • SCR20260822001'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    testWidgets('pops back when back icon is tapped on PdfPreviewPage', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PdfPreviewPage(
                      patient: samplePatient,
                      screening: samplePendingScreening,
                      pdfReportService: fakePdfService,
                    ),
                  ),
                ),
                child: const Text('Open Preview'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Preview'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(PdfPreviewPage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(PdfPreviewPage), findsNothing);
      expect(find.text('Open Preview'), findsOneWidget);
    });
  });
}
