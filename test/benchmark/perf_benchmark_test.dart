// Manual benchmark, skipped in normal runs. Run with:
//   flutter test test/benchmark/perf_benchmark_test.dart --dart-define=BENCH=true
//
// Numbers come from the host running the test (a desktop CPU), so they are a
// LOWER BOUND for a low-end Android phone. Re-measure on a device in profile
// mode before trusting any absolute threshold.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/data/repositories/drift_ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/models/village_analytics.dart';
import 'package:ncd_screening_mobile/domain/services/password_hasher.dart';
import 'package:ncd_screening_mobile/domain/services/pdf_report_service.dart';
import 'package:ncd_screening_mobile/domain/services/village_analytics_calculator.dart';

const _bench = bool.fromEnvironment('BENCH');
const _patients = 2000;

Future<T> _time<T>(String label, Future<T> Function() body) async {
  final sw = Stopwatch()..start();
  final result = await body();
  sw.stop();
  // ignore: avoid_print
  print('BENCH $label: ${sw.elapsedMilliseconds} ms');
  return result;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PBKDF2 cost (blocks the calling isolate when run synchronously)', () {
    final sw = Stopwatch()..start();
    final stored = PasswordHasher.hash('password123');
    final hashMs = sw.elapsedMilliseconds;
    sw
      ..reset()
      ..start();
    PasswordHasher.verify('password123', stored);
    // ignore: avoid_print
    print('BENCH pbkdf2 hash: $hashMs ms, verify: ${sw.elapsedMilliseconds} ms');
  }, skip: !_bench);

  test('analytics, list and PDF on $_patients patients', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DriftNcdRepository(db);
    final villages = await repo.getVillages();

    await _time('seed $_patients patients + ${_patients * 2} screenings', () async {
      for (var i = 0; i < _patients; i++) {
        final p = await repo.addPatient(Patient(
          patientId: '',
          patientCitizenId: '${1000000000000 + i}',
          patientTitle: 'นาย',
          patientFname: 'ทดสอบ$i',
          patientLname: 'ระบบ',
          patientGender: i.isEven ? 'ชาย' : 'หญิง',
          patientBirthDate: DateTime(1950 + i % 40, 1 + i % 12, 1 + i % 28),
          patientAddress: '$i หมู่ ${1 + i % 5}',
          villageId: villages[i % villages.length].villageId,
        ));
        for (var s = 0; s < 2; s++) {
          await repo.saveScreening(Screening(
            screenId: '',
            patientId: p.patientId,
            vhvId: 'VHV001',
            screeningDate: DateTime.now().subtract(Duration(days: s * 90)),
            ageAtScreening: 30 + i % 50,
            createdAt: DateTime.now(),
            weight: 55.0 + i % 40,
            height: 150.0 + i % 30,
            bmi: 24.0,
            waistCm: 70.0 + i % 30,
            sbp: 110.0 + i % 50,
            dbp: 70.0 + i % 30,
            pulse: 70,
            bloodSugar: 90.0 + i % 80,
          ));
        }
      }
    });

    final all = await _time('getVillages+getPatients+getAllScreenings', () async {
      return Future.wait([
        repo.getVillages(),
        repo.getPatients(),
        repo.getAllScreenings(),
      ]);
    });
    await _time('getPatients(search "ทดสอบ19")', () => repo.getPatients(searchQuery: 'ทดสอบ19'));

    await _time('VillageAnalyticsCalculator.compute', () async {
      return VillageAnalyticsCalculator.compute(
        villages: all[0] as List<Village>,
        patients: all[1] as List<Patient>,
        screenings: all[2] as List<Screening>,
        selectedVillageId: null,
        sortOrder: AnalyticsSortOrder.values.first,
      );
    });

    final patients = all[1] as List<Patient>;
    final screenings = all[2] as List<Screening>;
    final bytes = await _time('PDF generate (bundled Sarabun)', () {
      return PdfReportService().generateScreeningReport(
        patient: patients.first,
        screening: screenings.first,
      );
    });
    // ignore: avoid_print
    print('BENCH PDF size: ${bytes.length} bytes');
  }, skip: !_bench, timeout: const Timeout(Duration(minutes: 10)));
}
