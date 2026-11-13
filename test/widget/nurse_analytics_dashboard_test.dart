import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_risk_calculator.dart';
import 'package:ncd_screening_mobile/feature/nurse/bloc/village_analytics_bloc.dart';
import 'package:ncd_screening_mobile/feature/nurse/bloc/village_bloc.dart';
import 'package:ncd_screening_mobile/feature/nurse/pages/nurse_village_list_page.dart';
import 'package:ncd_screening_mobile/feature/patient/bloc/patient_bloc.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/patient_detail_page.dart';
import 'package:ncd_screening_mobile/shared/bloc/accessibility/accessibility_cubit.dart';

class DirectMockNcdRepository implements NcdRepositoryInterface {
  final List<Village> _villages = const [
    Village(villageId: 'V001', villageName: 'บ้านท่าตอน', villageNumber: '1'),
    Village(villageId: 'V002', villageName: 'บ้านใหม่หมอกจ๋าม', villageNumber: '2'),
  ];

  final List<Patient> _patients = [
    Patient(
      patientId: 'P001',
      patientCitizenId: '1234567890121',
      patientTitle: 'นาย',
      patientFname: 'สมชาย',
      patientLname: 'ใจดี',
      patientGender: 'ชาย',
      patientBirthDate: DateTime(1980, 2, 1),
      patientAddress: '60 หมู่ 1 บ้านท่าตอน ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่',
      villageId: 'V001',
    ),
  ];

  final List<Screening> _screenings = [
    Screening(
      screenId: 'S001',
      patientId: 'P001',
      vhvId: 'VHV001',
      screeningDate: DateTime(2026, 2, 7, 10, 55),
      ageAtScreening: 46,
      createdAt: DateTime(2026, 2, 7, 10, 55),
      reviewStatus: ReviewStatus.pending,
      weight: 70,
      height: 170,
      bmi: 24.2,
      waistCm: 88,
      sbp: 145,
      dbp: 95,
      pulse: 75,
      bloodSugar: 140,
      results: NcdRiskCalculator.evaluateRisk(
        screeningId: 'S001',
        weight: 70,
        height: 170,
        bmi: 24.2,
        waistCm: 88,
        sbp: 145,
        dbp: 95,
        pulse: 75,
        bloodSugar: 140,
        gender: 'ชาย',
      ),
    ),
  ];

  @override
  Future<dynamic> login({required UserRole role, required String identifier, String? password, DateTime? birthDate}) async => null;

  @override
  Future<List<Village>> getVillages() async => _villages;

  @override
  Future<Village?> getVillageById(String villageId) async =>
      _villages.firstWhere((v) => v.villageId == villageId);

  @override
  Future<List<Patient>> getPatients({String? villageId, String? searchQuery}) async => _patients;

  @override
  Future<Patient?> getPatientById(String patientId) async =>
      _patients.firstWhere((p) => p.patientId == patientId);

  @override
  Future<Patient?> getPatientByCitizenId(String citizenId) async =>
      _patients.firstWhere((p) => p.patientCitizenId == citizenId);

  @override
  Future<Patient> addPatient(Patient patient) async => patient;

  @override
  Future<Patient> updatePatient(Patient patient) async => patient;

  @override
  Future<bool> deletePatient(String patientId) async => true;

  @override
  Future<List<VHV>> getVhvs({String? villageId}) async => [];

  @override
  Future<VHV?> getVhvById(String vhvId) async => null;

  @override
  Future<VHV> addVhv(VHV vhv) async => vhv;

  @override
  Future<VHV> updateVhv(VHV vhv) async => vhv;

  @override
  Future<Nurse?> getNurseById(String nurseId) async => null;

  @override
  Future<List<Screening>> getScreeningsByPatient(String patientId) async =>
      _screenings.where((s) => s.patientId == patientId).toList();

  @override
  Future<List<Screening>> getAllScreenings({String? villageId}) async => _screenings;

  @override
  Future<Screening?> getScreeningById(String screeningId) async =>
      _screenings.firstWhere((s) => s.screenId == screeningId);

  @override
  Future<Screening> saveScreening(Screening screening) async => screening;

  @override
  Future<Screening> updateScreeningReview({
    required String screeningId,
    required ReviewStatus status,
    required String nurseId,
    List<ScreeningResult>? updatedResults,
  }) async => _screenings.first;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleNurse = Nurse(
    nurseId: 'NUR001',
    nurseTitle: 'นางพยาบาล',
    nurseFname: 'กานดา',
    nurseLname: 'ใจดี',
    nurseMobile: '0823456789',
    nurseEmail: 'nurse01@example.com',
    nursePassword: 'password123',
    nurseGender: 'หญิง',
    nurseBirthDate: DateTime(1990, 10, 15),
  );

  group('NurseVillageListPage 2-Tab & Analytics Dashboard Widget Tests', () {
    testWidgets('renders 2-Tab bar and default Health Analytics Dashboard correctly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repository = DirectMockNcdRepository();
      final villageBloc = VillageBloc(repository);
      final villageAnalyticsBloc = VillageAnalyticsBloc(repository);
      final patientBloc = PatientBloc(repository);
      final accessibilityCubit = AccessibilityCubit();

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<VillageBloc>.value(value: villageBloc),
            BlocProvider<VillageAnalyticsBloc>.value(value: villageAnalyticsBloc),
            BlocProvider<PatientBloc>.value(value: patientBloc),
            BlocProvider<AccessibilityCubit>.value(value: accessibilityCubit),
          ],
          child: MaterialApp(
            home: NurseVillageListPage(nurse: sampleNurse),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      // Check App bar title and tabs
      expect(find.text('ระบบพยาบาล รพ.สต.แม่อาย'), findsOneWidget);
      expect(find.text('ภาพรวมสถิติสุขภาพ'), findsOneWidget);
      expect(find.text('จัดการหมู่บ้านและ อสม.'), findsOneWidget);

      // Check Nurse header banner
      expect(find.text('พยาบาล: นางพยาบาลกานดา ใจดี'), findsOneWidget);
      expect(find.text('พื้นที่รับผิดชอบ: ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่'), findsOneWidget);

      // Check 4 KPI summary cards
      expect(find.text('ประชากรทั้งหมด'), findsOneWidget);
      expect(find.text('ความครอบคลุม'), findsOneWidget);
      expect(find.text('กลุ่มเสี่ยงสูง'), findsOneWidget);
      expect(find.text('รอพยาบาลตรวจ'), findsOneWidget);

      // Check 4 NCD risk breakdowns
      expect(find.text('สถิติความเสี่ยงรายโรค NCDs (4 โรค)'), findsOneWidget);
      expect(find.text('โรคเบาหวาน'), findsWidgets);
      expect(find.text('โรคความดันโลหิตสูง'), findsWidgets);
      expect(find.text('โรคหลอดเลือดหัวใจ'), findsWidgets);
      expect(find.text('โรคอ้วนลงพุง'), findsWidgets);

      // Check Demographic Distribution
      expect(find.text('การกระจายตัวของประชากร'), findsOneWidget);
      expect(find.text('สัดส่วนเพศ (Gender Ratio)'), findsOneWidget);
      expect(find.text('กลุ่มช่วงอายุ (Age Groups)'), findsOneWidget);
      expect(find.text('< 35 ปี'), findsOneWidget);
      expect(find.text('35–59 ปี'), findsOneWidget);
      expect(find.text('≥ 60 ปี'), findsOneWidget);

      // Check Village Comparison Section
      expect(find.text('การเปรียบเทียบสถิติรายหมู่บ้าน'), findsOneWidget);

      villageBloc.close();
      villageAnalyticsBloc.close();
      patientBloc.close();
      accessibilityCubit.close();
    });

    testWidgets('switches to Tab 2 (Villages & VHV Management) and displays village list', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repository = DirectMockNcdRepository();
      final villageBloc = VillageBloc(repository);
      final villageAnalyticsBloc = VillageAnalyticsBloc(repository);
      final patientBloc = PatientBloc(repository);
      final accessibilityCubit = AccessibilityCubit();

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<VillageBloc>.value(value: villageBloc),
            BlocProvider<VillageAnalyticsBloc>.value(value: villageAnalyticsBloc),
            BlocProvider<PatientBloc>.value(value: patientBloc),
            BlocProvider<AccessibilityCubit>.value(value: accessibilityCubit),
          ],
          child: MaterialApp(
            home: NurseVillageListPage(nurse: sampleNurse),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      // Tap on Tab 2
      await tester.tap(find.text('จัดการหมู่บ้านและ อสม.'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should show villages in management tab
      expect(find.text('หมู่ 1 บ้านท่าตอน'), findsWidgets);
      expect(find.text('หมู่ 2 บ้านใหม่หมอกจ๋าม'), findsWidgets);

      // Tap a village in Tab 2 to open bottom sheet
      await tester.tap(find.text('หมู่ 1 บ้านท่าตอน').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('รายชื่อ อสม. ในหมู่บ้าน'), findsOneWidget);
      expect(find.text('รายชื่อผู้ป่วยในหมู่บ้าน'), findsOneWidget);

      villageBloc.close();
      villageAnalyticsBloc.close();
      patientBloc.close();
      accessibilityCubit.close();
    });

    testWidgets('drills down to a specific village from comparison list', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repository = DirectMockNcdRepository();
      final villageBloc = VillageBloc(repository);
      final villageAnalyticsBloc = VillageAnalyticsBloc(repository);
      final patientBloc = PatientBloc(repository);
      final accessibilityCubit = AccessibilityCubit();

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<VillageBloc>.value(value: villageBloc),
            BlocProvider<VillageAnalyticsBloc>.value(value: villageAnalyticsBloc),
            BlocProvider<PatientBloc>.value(value: patientBloc),
            BlocProvider<AccessibilityCubit>.value(value: accessibilityCubit),
          ],
          child: MaterialApp(
            home: NurseVillageListPage(nurse: sampleNurse),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      // Scroll to comparison section
      final villageCard = find.text('หมู่ 1 บ้านท่าตอน').first;
      await tester.ensureVisible(villageCard);
      await tester.tap(villageCard);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Village filter dropdown should now reflect selected village
      expect(villageAnalyticsBloc.state.selectedVillageId, equals('V001'));
      expect(villageAnalyticsBloc.state.analytics!.isAllVillages, isFalse);

      villageBloc.close();
      villageAnalyticsBloc.close();
      patientBloc.close();
      accessibilityCubit.close();
    });

    testWidgets('navigates to PatientDetailPage when tapping a high-risk priority patient', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repository = DirectMockNcdRepository();
      final villageBloc = VillageBloc(repository);
      final villageAnalyticsBloc = VillageAnalyticsBloc(repository);
      final patientBloc = PatientBloc(repository);
      final accessibilityCubit = AccessibilityCubit();

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<VillageBloc>.value(value: villageBloc),
            BlocProvider<VillageAnalyticsBloc>.value(value: villageAnalyticsBloc),
            BlocProvider<PatientBloc>.value(value: patientBloc),
            BlocProvider<AccessibilityCubit>.value(value: accessibilityCubit),
          ],
          child: MaterialApp(
            home: NurseVillageListPage(nurse: sampleNurse),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      final highRiskSection = find.text('กลุ่มเสี่ยงสูงที่ต้องติดตามเร่งด่วน');
      await tester.ensureVisible(highRiskSection);

      if (villageAnalyticsBloc.state.analytics!.highRiskPriorityQueue.isNotEmpty) {
        final firstPatient = villageAnalyticsBloc.state.analytics!.highRiskPriorityQueue.first.patient;
        final patientNameFinder = find.text(firstPatient.fullName);
        await tester.ensureVisible(patientNameFinder);
        await tester.tap(patientNameFinder);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(PatientDetailPage), findsOneWidget);
        expect(find.text('รายละเอียดผู้ป่วย'), findsOneWidget);
      }

      villageBloc.close();
      villageAnalyticsBloc.close();
      patientBloc.close();
      accessibilityCubit.close();
    });
  });
}
