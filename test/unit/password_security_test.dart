import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/data/repositories/drift_ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/password_hasher.dart';
import '../support/test_citizen_ids.dart';

VHV _newVhv({String password = 'secret123', String mobile = '0855555555'}) =>
    VHV(
      vhvId: '',
      vhvCitizenId: '5555555555555',
      vhvTitle: 'นาง',
      vhvFname: 'ทดสอบ',
      vhvLname: 'ระบบ',
      vhvMobile: mobile,
      vhvEmail: 'test@example.com',
      vhvPassword: password,
      vhvBirthDate: DateTime(1992, 4, 10),
      vhvGender: 'หญิง',
      vhvAddress: '88 หมู่ 3',
      villageId: 'V003',
    );

void main() {
  group('PasswordHasher', () {
    const hasher = PasswordHasher(iterations: 1000);

    test(
      'hash never equals the plaintext and uses the expected format',
      () async {
        final stored = await hasher.hash('password123');
        expect(stored, isNot(contains('password123')));
        expect(stored, startsWith('pbkdf2_sha256\$1000\$'));
      },
    );

    test(
      'same password produces different hashes because of random salt',
      () async {
        final a = await hasher.hash('password123');
        final b = await hasher.hash('password123');
        expect(a, isNot(equals(b)));
      },
    );

    test('verify accepts the right password and rejects others', () async {
      final stored = await hasher.hash('password123');
      expect(await hasher.verify('password123', stored), isTrue);
      expect(await hasher.verify('password124', stored), isFalse);
      expect(await hasher.verify('', stored), isFalse);
    });

    test('verify returns false for empty or malformed stored values', () async {
      expect(await hasher.verify('password123', ''), isFalse);
      expect(await hasher.verify('password123', 'password123'), isFalse);
      expect(
        await hasher.verify('password123', 'pbkdf2_sha256\$x\$a\$b'),
        isFalse,
      );
      expect(
        await hasher.verify('password123', 'pbkdf2_sha256\$1000\$!!!\$!!!'),
        isFalse,
      );
    });
  });

  group('DriftNcdRepository - password storage', () {
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

    test('demo seed stores hashes, never plaintext', () async {
      final rows = await db.select(db.vhvsTable).get();
      expect(rows, isNotEmpty);
      for (final row in rows) {
        expect(row.vhvPasswordHash, startsWith('pbkdf2_sha256'));
        expect(row.vhvPasswordHash, isNot(contains('password123')));
      }
      final nurse = await db.select(db.nursesTable).getSingle();
      expect(nurse.nursePasswordHash, startsWith('pbkdf2_sha256'));
    });

    test('addVhv stores a hash and login works with that password', () async {
      final created = await repository.addVhv(_newVhv());
      final row = await (db.select(
        db.vhvsTable,
      )..where((t) => t.vhvId.equals(created.vhvId))).getSingle();
      expect(row.vhvPasswordHash, isNot(contains('secret123')));

      final user = await repository.login(
        role: UserRole.vhv,
        identifier: '5555555555555',
        password: 'secret123',
      );
      expect((user as VHV).vhvId, equals(created.vhvId));
      expect(
        user.vhvPassword,
        isEmpty,
        reason: 'read models must not expose secrets',
      );
    });

    test('addVhv rejects a VHV without a password', () async {
      expect(() => repository.addVhv(_newVhv(password: '')), throwsException);
    });

    test('VHV and nurse login reject an empty password', () async {
      expect(
        () => repository.login(
          role: UserRole.vhv,
          identifier: '1111111111111',
          password: '',
        ),
        throwsException,
      );
      expect(
        () => repository.login(role: UserRole.nurse, identifier: 'NUR001'),
        throwsException,
      );
    });

    test(
      'updateVhv with empty password keeps the existing credential',
      () async {
        final current = await repository.getVhvById('VHV001');
        await repository.updateVhv(current!.copyWith(vhvMobile: '0811111111'));

        final user = await repository.login(
          role: UserRole.vhv,
          identifier: '1111111111111',
          password: 'password123',
        );
        expect(user, isNotNull);
      },
    );

    test('updateVhv with a new password replaces the credential', () async {
      final current = await repository.getVhvById('VHV001');
      await repository.updateVhv(current!.copyWith(vhvPassword: 'newsecret99'));

      expect(
        () => repository.login(
          role: UserRole.vhv,
          identifier: '1111111111111',
          password: 'password123',
        ),
        throwsException,
      );
      final user = await repository.login(
        role: UserRole.vhv,
        identifier: '1111111111111',
        password: 'newsecret99',
      );
      expect(user, isNotNull);
    });

    test('verifyNursePassword matches only the correct password', () async {
      expect(
        await repository.verifyNursePassword(
          nurseId: 'NUR001',
          password: 'password123',
        ),
        isTrue,
      );
      expect(
        await repository.verifyNursePassword(
          nurseId: 'NUR001',
          password: 'wrong',
        ),
        isFalse,
      );
      expect(
        await repository.verifyNursePassword(nurseId: 'NUR001', password: ''),
        isFalse,
      );
    });
  });

  group('AppDatabase - v3 to v5 migration', () {
    test(
      'legacy plaintext passwords are hashed and the plaintext columns are dropped',
      () async {
        final db = AppDatabase(
          citizenIds: testCitizenIds(),
          executor: NativeDatabase.memory(
            setup: (raw) {
              raw.execute('''
          CREATE TABLE villages (
            village_id TEXT NOT NULL PRIMARY KEY,
            village_name TEXT NOT NULL,
            village_number TEXT NOT NULL,
            subdistrict_id TEXT NOT NULL DEFAULT 'SD001',
            subdistrict_name TEXT NOT NULL DEFAULT 'ท่าตอน',
            district_name TEXT NOT NULL DEFAULT 'แม่อาย',
            province_name TEXT NOT NULL DEFAULT 'เชียงใหม่'
          )''');
              raw.execute('''
          CREATE TABLE nurses (
            nurse_id TEXT NOT NULL PRIMARY KEY,
            nurse_title TEXT NOT NULL,
            nurse_fname TEXT NOT NULL,
            nurse_lname TEXT NOT NULL,
            nurse_mobile TEXT NOT NULL,
            nurse_email TEXT NOT NULL,
            nurse_password TEXT NOT NULL,
            nurse_gender TEXT NOT NULL,
            nurse_birth_date INTEGER NOT NULL,
            nurse_img TEXT,
            subdistrict_id TEXT NOT NULL DEFAULT 'SD001'
          )''');
              raw.execute('''
          CREATE TABLE vhvs (
            vhv_id TEXT NOT NULL PRIMARY KEY,
            vhv_citizen_id TEXT NOT NULL,
            vhv_title TEXT NOT NULL,
            vhv_fname TEXT NOT NULL,
            vhv_lname TEXT NOT NULL,
            vhv_mobile TEXT NOT NULL,
            vhv_email TEXT NOT NULL,
            vhv_password TEXT NOT NULL,
            vhv_birth_date INTEGER NOT NULL,
            vhv_gender TEXT NOT NULL,
            vhv_address TEXT NOT NULL,
            vhv_img TEXT,
            village_id TEXT NOT NULL
          )''');
              raw.execute(
                'INSERT INTO villages (village_id, village_name, village_number) '
                "VALUES ('V001', 'บ้านท่าตอน', '1')",
              );
              raw.execute(
                'INSERT INTO nurses (nurse_id, nurse_title, nurse_fname, nurse_lname, '
                'nurse_mobile, nurse_email, nurse_password, nurse_gender, nurse_birth_date) '
                "VALUES ('NUR900', 'นาง', 'ก', 'ข', '0800000000', 'n@x.th', 'nursepass', 'หญิง', 0)",
              );
              raw.execute(
                'INSERT INTO vhvs (vhv_id, vhv_citizen_id, vhv_title, vhv_fname, vhv_lname, '
                'vhv_mobile, vhv_email, vhv_password, vhv_birth_date, vhv_gender, vhv_address, village_id) '
                "VALUES ('VHV900', '9999999999999', 'นาย', 'ก', 'ข', '0900000000', 'v@x.th', "
                "'legacypass', 0, 'ชาย', 'addr', 'V001')",
              );
              raw.execute('''
          CREATE TABLE patients (
            patient_id TEXT NOT NULL PRIMARY KEY,
            patient_citizen_id TEXT NOT NULL,
            patient_title TEXT NOT NULL,
            patient_fname TEXT NOT NULL,
            patient_lname TEXT NOT NULL,
            patient_gender TEXT NOT NULL,
            patient_birth_date INTEGER NOT NULL,
            patient_address TEXT NOT NULL,
            patient_mobile TEXT NOT NULL DEFAULT '',
            patient_img TEXT,
            village_id TEXT NOT NULL
          )''');
              raw.execute(
                'INSERT INTO patients (patient_id, patient_citizen_id, patient_title, '
                'patient_fname, patient_lname, patient_gender, patient_birth_date, patient_address, village_id) '
                "VALUES ('P900', '1500200000010', 'นาย', 'ก', 'ข', 'ชาย', 0, 'addr', 'V001')",
              );
              raw.execute('PRAGMA user_version = 3');
            },
          ),
        );
        addTearDown(db.close);
        final repository = DriftNcdRepository(db);

        final vhvUser = await repository.login(
          role: UserRole.vhv,
          identifier: '9999999999999',
          password: 'legacypass',
        );
        expect(vhvUser, isNotNull);

        final nurseOk = await repository.verifyNursePassword(
          nurseId: 'NUR900',
          password: 'nursepass',
        );
        expect(nurseOk, isTrue);

        final patient = await repository.login(
          role: UserRole.patient,
          identifier: '1500200000010',
        );
        expect((patient as Patient).patientId, equals('P900'));

        final rawPatient = await db
            .customSelect(
              'SELECT patient_citizen_id AS cid, patient_citizen_id_index AS idx FROM patients',
            )
            .getSingle();
        expect(
          rawPatient.read<String>('cid'),
          isNot(contains('1500200000010')),
        );
        expect(rawPatient.read<String>('idx'), isNotEmpty);

        final columns = await db
            .customSelect('PRAGMA table_info(vhvs)')
            .map((r) => r.read<String>('name'))
            .get();
        expect(columns, isNot(contains('vhv_password')));
        expect(columns, contains('vhv_password_hash'));

        final nurseColumns = await db
            .customSelect('PRAGMA table_info(nurses)')
            .map((r) => r.read<String>('name'))
            .get();
        expect(nurseColumns, isNot(contains('nurse_password')));
      },
    );
  });
}
