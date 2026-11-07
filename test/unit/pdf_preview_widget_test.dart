import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_risk_calculator.dart';
import 'package:ncd_screening_mobile/domain/services/pdf_report_service.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/patient_screening_detail_page.dart';
import 'package:ncd_screening_mobile/feature/screening/bloc/screening_bloc.dart';
import 'package:ncd_screening_mobile/feature/screening/pages/pdf_preview_page.dart';
import 'package:ncd_screening_mobile/feature/screening/pages/risk_assessment_result_page.dart';
import 'package:ncd_screening_mobile/shared/bloc/accessibility/accessibility_cubit.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../support/mock_ncd_repository.dart';

class MockPdfReportService implements PdfReportServiceInterface {
  final bool shouldThrow;

  MockPdfReportService({this.shouldThrow = false});

  @override
  Future<Uint8List> generateScreeningReport({
    required Patient patient,
    required Screening screening,
    VHV? vhv,
    Nurse? nurse,
    Village? village,
  }) async {
    if (shouldThrow) {
      throw Exception('PDF Generation Failed Exception');
    }
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (context) => pw.Center(
          child: pw.Text('Mock PDF Report for ${patient.fullName}'),
        ),
      ),
    );
    return doc.save();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  final sampleScreening = Screening(
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
  );

  group('PdfPreviewPage Widget Tests', () {
    testWidgets('renders PdfPreviewPage header and PdfPreview widget', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockService = MockPdfReportService();

      await tester.pumpWidget(
        MaterialApp(
          home: PdfPreviewPage(
            patient: samplePatient,
            screening: sampleScreening,
            pdfReportService: mockService,
          ),
        ),
      );

      expect(find.text('ตัวอย่างรายงาน PDF'), findsOneWidget);
      expect(
        find.text('${samplePatient.fullName} • ${sampleScreening.screenId}'),
        findsOneWidget,
      );
      expect(find.byType(PdfPreview), findsOneWidget);
    });

    testWidgets(
      'displays error boundary when PDF generation throws an exception',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final mockFailingService = MockPdfReportService(shouldThrow: true);

        // Suppress framework exception during expected failure test
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {};
        addTearDown(() {
          FlutterError.onError = originalOnError;
        });

        await tester.pumpWidget(
          MaterialApp(
            home: PdfPreviewPage(
              patient: samplePatient,
              screening: sampleScreening,
              pdfReportService: mockFailingService,
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('เกิดข้อผิดพลาดในการสร้างเอกสาร PDF'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      },
    );
  });

  group('Screening Details & Result Page PDF Navigation Tests', () {
    testWidgets(
      'PatientScreeningDetailPage has PDF export action in AppBar and body',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final mockRepo = MockNcdRepository();
        final screeningBloc = ScreeningBloc(mockRepo);
        final accessibilityCubit = AccessibilityCubit();

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<ScreeningBloc>.value(value: screeningBloc),
              BlocProvider<AccessibilityCubit>.value(value: accessibilityCubit),
            ],
            child: MaterialApp(
              home: PatientScreeningDetailPage(
                patient: samplePatient,
                screening: sampleScreening,
              ),
            ),
          ),
        );

        // Verify AppBar action
        final appBarPdfIcon = find.byIcon(Icons.picture_as_pdf_outlined);
        expect(appBarPdfIcon, findsWidgets);

        // Verify Body Button
        final exportBtn = find.text('ดูตัวอย่าง / พิมพ์เอกสารสรุปผล (PDF)');
        expect(exportBtn, findsOneWidget);
        await tester.ensureVisible(exportBtn);
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(exportBtn);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(PdfPreviewPage), findsOneWidget);

        screeningBloc.close();
        accessibilityCubit.close();
      },
    );

    testWidgets(
      'RiskAssessmentResultPage has PDF export button navigating to PdfPreviewPage',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final accessibilityCubit = AccessibilityCubit();

        await tester.pumpWidget(
          BlocProvider<AccessibilityCubit>.value(
            value: accessibilityCubit,
            child: MaterialApp(
              home: RiskAssessmentResultPage(
                patient: samplePatient,
                screening: sampleScreening,
              ),
            ),
          ),
        );

        final exportBtn = find.text(
          'ดูตัวอย่างและพิมพ์รายงาน PDF (Export PDF)',
        );
        expect(exportBtn, findsOneWidget);
        await tester.ensureVisible(exportBtn);
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(exportBtn);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(PdfPreviewPage), findsOneWidget);

        accessibilityCubit.close();
      },
    );
  });
}
