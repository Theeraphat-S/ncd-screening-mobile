import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/data/repositories/drift_ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';

final _uuidV4 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

Future<Set<String>> _tableNames(AppDatabase db) async {
  final rows = await db
      .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
      .get();
  return rows.map((r) => r.read<String>('name')).toSet();
}

Patient _newPatient(String citizenId) => Patient(
      patientId: '',
      patientCitizenId: citizenId,
      patientTitle: 'นาย',
      patientFname: 'ทดสอบ',
      patientLname: 'ระบบ',
      patientGender: 'ชาย',
      patientBirthDate: DateTime(1960, 1, 1),
      patientAddress: '1 หมู่ 1',
      villageId: 'V001',
    );

void main() {
  group('Schema v4', () {
    test('schema version is 4 and new tables exist', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      expect(db.schemaVersion, equals(4));
      final tables = await _tableNames(db);
      expect(tables, containsAll(['sync_queue', 'screening_drafts']));
    });

    test('upgrading v3 -> v4 keeps data and adds the new tables', () async {
      final dir = Directory.systemTemp.createTempSync('ncd_v4_migration');
      final file = File('${dir.path}/app.sqlite');
      addTearDown(() {
        try {
          dir.deleteSync(recursive: true);
        } on FileSystemException {
          // Windows may still hold the file handle briefly; temp dir is harmless.
        }
      });

      // Build a database, then rewind it to look like a v3 install.
      final first = AppDatabase(NativeDatabase(file));
      await first.customSelect('SELECT 1').get(); // forces open + seed
      await first.customStatement('DROP TABLE sync_queue');
      await first.customStatement('DROP TABLE screening_drafts');
      await first.customStatement('PRAGMA user_version = 3');
      await first.close();

      final upgraded = AppDatabase(NativeDatabase(file));
      addTearDown(upgraded.close);

      final tables = await _tableNames(upgraded);
      expect(tables, containsAll(['sync_queue', 'screening_drafts']));
      final repo = DriftNcdRepository(upgraded);
      expect(await repo.getPatientById('P001'), isNotNull);
      final version = await upgraded
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.read<int>('user_version'), equals(4));
    });
  });

  group('Generated IDs', () {
    late AppDatabase db;
    late DriftNcdRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftNcdRepository(db);
    });
    tearDown(() => db.close());

    test('new patient gets a UUID v4 id', () async {
      final created = await repo.addPatient(_newPatient('9999999999991'));
      expect(created.patientId, matches(_uuidV4));
    });

    test('ids stay unique after a delete (no count+1 reuse)', () async {
      final a = await repo.addPatient(_newPatient('9999999999991'));
      final b = await repo.addPatient(_newPatient('9999999999992'));
      await repo.deletePatient(a.patientId);
      final c = await repo.addPatient(_newPatient('9999999999993'));
      expect({a.patientId, b.patientId, c.patientId}.length, equals(3));
    });

    test('seeded demo ids are untouched', () async {
      expect(await repo.getPatientById('P001'), isNotNull);
      expect((await repo.getVhvById('VHV001')), isNotNull);
    });
  });
}
