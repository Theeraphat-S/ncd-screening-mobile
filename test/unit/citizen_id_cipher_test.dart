import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/data/repositories/drift_ncd_repository.dart';
import 'package:ncd_screening_mobile/data/security/citizen_id_cipher.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';

import '../support/memory_key_store.dart';
import '../support/test_citizen_ids.dart';

Patient _patient({String id = '', String citizenId = '1500200000010'}) =>
    Patient(
      patientId: id,
      patientCitizenId: citizenId,
      patientTitle: 'นาย',
      patientFname: 'สมชาย',
      patientLname: 'ใจดี',
      patientGender: 'ชาย',
      patientBirthDate: DateTime(1980, 1, 1),
      patientAddress: 'หมู่ 1',
      patientMobile: '0800000000',
      patientImg: null,
      villageId: 'V001',
    );

void main() {
  group('CitizenIdCipher', () {
    late CitizenIdCipher cipher;

    setUp(() {
      cipher = testCitizenIds();
    });

    test('encrypt then decrypt returns the trimmed original', () async {
      final stored = await cipher.encrypt(' 1500200000010 ');
      expect(stored, isNot(contains('1500200000010')));
      expect(await cipher.decrypt(stored), equals('1500200000010'));
    });

    test('same ID encrypts differently each time (random nonce)', () async {
      final a = await cipher.encrypt('1500200000010');
      final b = await cipher.encrypt('1500200000010');
      expect(a, isNot(equals(b)));
    });

    test('index is deterministic and separates different IDs', () async {
      final a = await cipher.indexOf('1500200000010');
      expect(await cipher.indexOf(' 1500200000010'), equals(a));
      expect(await cipher.indexOf('1500200000011'), isNot(equals(a)));
      expect(a, isNot(contains('1500200000010')));
    });

    test('tampered ciphertext is rejected', () async {
      final stored = await cipher.encrypt('1500200000010');
      final raw = base64Decode(stored);
      raw[raw.length - 1] ^= 0x01; // flip one bit of the authentication tag
      await expectLater(cipher.decrypt(base64Encode(raw)), throwsA(anything));
    });

    test('keys from another installation cannot decrypt', () async {
      final other = CitizenIdCipher.withKeys(
        encKey: List<int>.filled(32, 1),
        indexKey: List<int>.filled(32, 2),
      );
      final stored = await cipher.encrypt('1500200000010');
      await expectLater(other.decrypt(stored), throwsA(anything));
    });

    test(
      'loadOrCreate generates keys once and reloads the same ones',
      () async {
        final store = MemoryKeyStore();
        final first = await CitizenIdCipher.loadOrCreate(store);
        final stored = await first.encrypt('1500200000010');

        final second = await CitizenIdCipher.loadOrCreate(store);
        expect(await second.decrypt(stored), equals('1500200000010'));
        expect(
          await second.indexOf('1500200000010'),
          await first.indexOf('1500200000010'),
        );
      },
    );

    test('loadOrCreate rejects a stored key with the wrong length', () async {
      final store = MemoryKeyStore();
      await store.write('citizen_id.enc_key.v1', 'AAAA');
      await expectLater(CitizenIdCipher.loadOrCreate(store), throwsStateError);
    });
  });

  group('DriftNcdRepository - citizen ID protection', () {
    late AppDatabase db;
    late DriftNcdRepository repository;

    setUp(() {
      db = AppDatabase(
        citizenIds: testCitizenIds(),
        executor: NativeDatabase.memory(),
      );
      repository = DriftNcdRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('stored patient row never contains the plain citizen ID', () async {
      final created = await repository.addPatient(_patient());
      final row = await (db.select(
        db.patientsTable,
      )..where((t) => t.patientId.equals(created.patientId))).getSingle();
      expect(row.patientCitizenId, isNot(contains('1500200000010')));
      expect(row.patientCitizenIdIndex, isNotEmpty);
    });

    test(
      'patient can be found and logged in by citizen ID after creation',
      () async {
        await repository.addPatient(
          _patient(id: 'P900', citizenId: '1500200000010'),
        );

        final byId = await repository.getPatientByCitizenId('1500200000010');
        expect(byId?.patientId, equals('P900'));
        expect(byId?.patientCitizenId, equals('1500200000010'));

        final loggedIn = await repository.login(
          role: UserRole.patient,
          identifier: '1500200000010',
        );
        expect((loggedIn as Patient).patientId, equals('P900'));
      },
    );

    test('updating the citizen ID moves the lookup to the new value', () async {
      final created = await repository.addPatient(_patient(id: 'P901'));
      await repository.updatePatient(
        created.copyWith(patientCitizenId: '1500200000027'),
      );

      expect(await repository.getPatientByCitizenId('1500200000010'), isNull);
      expect(
        (await repository.getPatientByCitizenId('1500200000027'))?.patientId,
        equals('P901'),
      );
    });

    test('name and partial-ID search still work on decrypted values', () async {
      await repository.addPatient(
        _patient(id: 'P902', citizenId: '1500200000010'),
      );

      final byName = await repository.getPatients(searchQuery: 'สมชาย');
      expect(byName.map((p) => p.patientId), contains('P902'));

      final byPartialId = await repository.getPatients(searchQuery: '20000001');
      expect(byPartialId.map((p) => p.patientId), contains('P902'));
    });

    test('demo patients are seeded encrypted and remain searchable', () async {
      final rows = await db.select(db.patientsTable).get();
      for (final row in rows) {
        expect(row.patientCitizenId, isNot(matches(RegExp(r'^\d{13}$'))));
      }
      final found = await repository.getPatientByCitizenId('1234567890123');
      expect(found, isNotNull);
    });
  });
}
