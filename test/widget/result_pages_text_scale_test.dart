import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_risk_calculator.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/patient_screening_detail_page.dart';
import 'package:ncd_screening_mobile/feature/screening/bloc/screening_bloc.dart';
import 'package:ncd_screening_mobile/feature/screening/pages/risk_assessment_result_page.dart';
import 'package:ncd_screening_mobile/shared/bloc/accessibility/accessibility_cubit.dart';

final _patient = Patient(
  patientId: 'P001',
  patientCitizenId: '1234567890121',
  patientTitle: 'นาย',
  patientFname: 'สมชาย',
  patientLname: 'ใจดี',
  patientGender: 'ชาย',
  patientBirthDate: DateTime(1950, 1, 1),
  patientAddress: '1 ม.1 ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่',
  villageId: 'V001',
);

/// A high-risk case so every card (triage alert, advice, four risks) shows.
Screening _highRisk() {
  const w = 92.0, h = 160.0, waist = 104.0, sbp = 182.0, dbp = 112.0;
  final bmi = w / ((h / 100) * (h / 100));
  return Screening(
    screenId: 'S001',
    patientId: 'P001',
    vhvId: 'VHV001',
    screeningDate: DateTime(2026, 11, 1),
    ageAtScreening: 76,
    createdAt: DateTime(2026, 11, 1),
    weight: w,
    height: h,
    bmi: bmi,
    waistCm: waist,
    sbp: sbp,
    dbp: dbp,
    pulse: 96,
    bloodSugar: 260,
    results: NcdRiskCalculator.evaluateRisk(
      screeningId: 'S001',
      weight: w,
      height: h,
      bmi: bmi,
      waistCm: waist,
      sbp: sbp,
      dbp: dbp,
      pulse: 96,
      bloodSugar: 260,
      gender: 'ชาย',
    ),
  );
}

void main() {
  setUpAll(() async {
    final loader = FontLoader('Sarabun')
      ..addFont(rootBundle.load('assets/fonts/Sarabun-Regular.ttf'));
    await loader.load();
  });

  Future<void> pumpAt2x(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final bloc = ScreeningBloc(MockNcdRepository());
    addTearDown(bloc.close);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: bloc),
          BlocProvider(create: (_) => AccessibilityCubit()),
        ],
        child: MaterialApp(
          theme: ThemeData(fontFamily: 'Sarabun'),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2.0)),
            child: child!,
          ),
          home: page,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('VHV result page: 2x system text on a 360px phone, no overflow',
      (tester) async {
    await pumpAt2x(
      tester,
      RiskAssessmentResultPage(patient: _patient, screening: _highRisk()),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('patient result detail page: 2x system text, no overflow',
      (tester) async {
    await pumpAt2x(
      tester,
      PatientScreeningDetailPage(patient: _patient, screening: _highRisk()),
    );
    expect(tester.takeException(), isNull);
  });
}
