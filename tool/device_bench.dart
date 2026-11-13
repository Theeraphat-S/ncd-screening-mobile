// On-device benchmark. Run in PROFILE mode on the slowest phone available:
//   flutter run --profile --flavor local -t tool/device_bench.dart -d <device>
// Results are printed as lines starting with "BENCH" (see `flutter logs`).
//
// Targets (see README): login / PIN unlock <= 1000 ms with no UI jank,
// analytics load+compute <= 2000 ms, PDF <= 3000 ms.
import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/data/repositories/drift_ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/models/village_analytics.dart';
import 'package:ncd_screening_mobile/domain/services/password_hasher.dart';
import 'package:ncd_screening_mobile/domain/services/pdf_report_service.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';
import 'package:ncd_screening_mobile/domain/services/village_analytics_calculator.dart';

const _patients = 2000;
final _lines = <String>[];

void _log(String s) {
  _lines.add(s);
  // ignore: avoid_print
  print('BENCH $s');
}

/// Runs [body] while a 16 ms timer watches for UI-thread stalls.
Future<(int ms, int maxGapMs)> _measure(Future<void> Function() body) async {
  var last = DateTime.now();
  var maxGap = 0;
  final t = Timer.periodic(const Duration(milliseconds: 16), (_) {
    final now = DateTime.now();
    final gap = now.difference(last).inMilliseconds;
    if (gap > maxGap) maxGap = gap;
    last = now;
  });
  // Let the watcher tick normally first, and again after the work, so a
  // body that blocks this isolate synchronously shows up as one long gap.
  await Future<void>.delayed(const Duration(milliseconds: 100));
  maxGap = 0;
  final sw = Stopwatch()..start();
  await body();
  sw.stop();
  await Future<void>.delayed(const Duration(milliseconds: 100));
  t.cancel();
  return (sw.elapsedMilliseconds, maxGap);
}

Future<void> _run() async {
  final stored = PasswordHasher.hash('password123');

  var r = await _measure(() async {
    PasswordHasher.verify('password123', stored); // old behaviour, UI thread
  });
  _log('verify on UI thread: ${r.$1} ms, longest UI stall ${r.$2} ms');

  r = await _measure(() async {
    await PasswordHasher.verifyAsync('password123', stored);
  });
  _log('verify on isolate:   ${r.$1} ms, longest UI stall ${r.$2} ms');

  final pins = PinService(InMemorySecureStore());
  await pins.setPin('U1', '135790');
  r = await _measure(() async {
    await pins.verifyPin('U1', '135790');
  });
  _log('PIN unlock (isolate): ${r.$1} ms, longest UI stall ${r.$2} ms');

  final db = AppDatabase(NativeDatabase.memory());
  final repo = DriftNcdRepository(db);
  r = await _measure(() async {
    await repo.login(
      role: UserRole.vhv,
      identifier: '1111111111111',
      password: 'password123',
    );
  });
  _log('VHV login (first open incl. seed): ${r.$1} ms, stall ${r.$2} ms');
  r = await _measure(() async {
    await repo.login(
      role: UserRole.vhv,
      identifier: '1111111111111',
      password: 'password123',
    );
  });
  _log('VHV login (warm): ${r.$1} ms, longest UI stall ${r.$2} ms');

  final villages = await repo.getVillages();
  r = await _measure(() async {
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
  _log('(setup) seed $_patients patients + ${_patients * 2} screenings: ${r.$1} ms');

  late List<Object> all;
  r = await _measure(() async {
    all = await Future.wait<Object>([
      repo.getVillages(),
      repo.getPatients(),
      repo.getAllScreenings(),
    ]);
    VillageAnalyticsCalculator.compute(
      villages: all[0] as List<Village>,
      patients: all[1] as List<Patient>,
      screenings: all[2] as List<Screening>,
      selectedVillageId: null,
      sortOrder: AnalyticsSortOrder.values.first,
    );
  });
  _log('analytics load+compute: ${r.$1} ms, longest UI stall ${r.$2} ms');

  final patient = (all[1] as List<Patient>).first;
  final screening = (all[2] as List<Screening>).first;
  r = await _measure(() async {
    await PdfReportService()
        .generateScreeningReport(patient: patient, screening: screening);
  });
  _log('PDF generate: ${r.$1} ms, longest UI stall ${r.$2} ms');

  await db.close();
  _log('DONE');
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    home: Scaffold(body: Center(child: CircularProgressIndicator())),
  ));
  // Let the first frame render before measuring.
  Future<void>.delayed(const Duration(seconds: 2), _run);
}
