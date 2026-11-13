import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/data/repositories/drift_ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/password_hasher.dart';

void main() {
  late AppDatabase db;
  late DriftNcdRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftNcdRepository(db);
  });
  tearDown(() => db.close());

  group('Staff login requires a password', () {
    test('VHV login without a password is rejected', () async {
      await expectLater(
        repo.login(role: UserRole.vhv, identifier: '0800000001'),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        repo.login(role: UserRole.vhv, identifier: '0800000001', password: ''),
        throwsA(isA<Exception>()),
      );
    });

    test('nurse login without a password is rejected', () async {
      await expectLater(
        repo.login(role: UserRole.nurse, identifier: 'NUR001'),
        throwsA(isA<Exception>()),
      );
    });

    test('correct password still works for VHV and nurse', () async {
      final vhv = await repo.login(
        role: UserRole.vhv,
        identifier: '0800000001',
        password: 'password123',
      );
      final nurse = await repo.login(
        role: UserRole.nurse,
        identifier: 'NUR001',
        password: 'password123',
      );
      expect(vhv, isA<VHV>());
      expect(nurse, isA<Nurse>());
    });
  });

  group('Passwords are stored hashed', () {
    test('seeded VHV and nurse passwords are hashes, not plaintext', () async {
      final vhvRows = await db.select(db.vhvsTable).get();
      final nurseRows = await db.select(db.nursesTable).get();
      expect(vhvRows.every((r) => PasswordHasher.isHashed(r.vhvPassword)),
          isTrue);
      expect(nurseRows.every((r) => PasswordHasher.isHashed(r.nursePassword)),
          isTrue);
    });

    test('addVhv hashes the plaintext password', () async {
      final created = await repo.addVhv(_vhv(password: 'secret-pass-1'));
      final row = await (db.select(db.vhvsTable)
            ..where((t) => t.vhvId.equals(created.vhvId)))
          .getSingle();
      expect(row.vhvPassword, isNot(contains('secret-pass-1')));
      expect(PasswordHasher.verify('secret-pass-1', row.vhvPassword), isTrue);

      final user = await repo.login(
        role: UserRole.vhv,
        identifier: '0899999999',
        password: 'secret-pass-1',
      );
      expect((user as VHV).vhvId, created.vhvId);
    });

    test('updateVhv with an already-hashed value does not double hash',
        () async {
      final created = await repo.addVhv(_vhv(password: 'secret-pass-1'));
      final stored = (await repo.getVhvById(created.vhvId))!;
      await repo.updateVhv(stored.copyWith(vhvFname: 'แก้ชื่อ'));
      final user = await repo.login(
        role: UserRole.vhv,
        identifier: '0899999999',
        password: 'secret-pass-1',
      );
      expect((user as VHV).vhvFname, 'แก้ชื่อ');
    });

    test('updateVhv with a new plaintext password re-hashes it', () async {
      final created = await repo.addVhv(_vhv(password: 'secret-pass-1'));
      final stored = (await repo.getVhvById(created.vhvId))!;
      await repo.updateVhv(stored.copyWith(vhvPassword: 'brand-new-pass'));
      await expectLater(
        repo.login(
          role: UserRole.vhv,
          identifier: '0899999999',
          password: 'secret-pass-1',
        ),
        throwsA(isA<Exception>()),
      );
      expect(
        await repo.login(
          role: UserRole.vhv,
          identifier: '0899999999',
          password: 'brand-new-pass',
        ),
        isA<VHV>(),
      );
    });

    test('legacy plaintext rows still log in once and are upgraded to a hash',
        () async {
      await (db.update(db.vhvsTable)..where((t) => t.vhvId.equals('VHV001')))
          .write(const VhvsTableCompanion(vhvPassword: Value('legacy-plain')));

      final user = await repo.login(
        role: UserRole.vhv,
        identifier: '0800000001',
        password: 'legacy-plain',
      );
      expect(user, isA<VHV>());

      final row = await (db.select(db.vhvsTable)
            ..where((t) => t.vhvId.equals('VHV001')))
          .getSingle();
      expect(PasswordHasher.isHashed(row.vhvPassword), isTrue);

      await expectLater(
        repo.login(
          role: UserRole.vhv,
          identifier: '0800000001',
          password: 'wrong',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Patient login needs citizen ID + date of birth', () {
    test('correct citizen ID and birth date succeeds', () async {
      final user = await repo.login(
        role: UserRole.patient,
        identifier: '1234567890121',
        birthDate: DateTime(1980, 2, 1),
      );
      expect((user as Patient).patientId, 'P001');
    });

    test('time-of-day in the supplied birth date is ignored', () async {
      final user = await repo.login(
        role: UserRole.patient,
        identifier: '1234567890121',
        birthDate: DateTime(1980, 2, 1, 14, 30),
      );
      expect(user, isA<Patient>());
    });

    test('wrong birth date is rejected with the same message as unknown ID',
        () async {
      Object? wrongDob;
      Object? unknownId;
      try {
        await repo.login(
          role: UserRole.patient,
          identifier: '1234567890121',
          birthDate: DateTime(1999, 1, 1),
        );
      } catch (e) {
        wrongDob = e;
      }
      try {
        await repo.login(
          role: UserRole.patient,
          identifier: '9999999999999',
          birthDate: DateTime(1980, 2, 1),
        );
      } catch (e) {
        unknownId = e;
      }
      expect(wrongDob, isA<Exception>());
      expect(wrongDob.toString(), equals(unknownId.toString()));
    });

    test('missing birth date is rejected', () async {
      await expectLater(
        repo.login(role: UserRole.patient, identifier: '1234567890121'),
        throwsA(isA<Exception>()),
      );
    });
  });
}

VHV _vhv({required String password}) => VHV(
      vhvId: '',
      vhvCitizenId: '1999999999999',
      vhvTitle: 'นาย',
      vhvFname: 'ทดสอบ',
      vhvLname: 'ระบบ',
      vhvMobile: '0899999999',
      vhvEmail: 'test@example.com',
      vhvPassword: password,
      vhvBirthDate: DateTime(1985, 5, 5),
      vhvGender: 'ชาย',
      vhvAddress: '1 หมู่ 1',
      villageId: 'V001',
    );
