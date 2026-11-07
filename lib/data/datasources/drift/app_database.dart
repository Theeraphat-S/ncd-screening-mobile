import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/ncd_tables.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_risk_calculator.dart';
import 'package:ncd_screening_mobile/domain/services/password_hasher.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    VillagesTable,
    NursesTable,
    VhvsTable,
    PatientsTable,
    ScreeningsTable,
    ScreeningHistoriesTable,
    ScreeningResultsTable,
    SyncQueueTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await _seedInitialDataIfEmpty();
    },
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 3) {
        await m.createTable(villagesTable);
        await m.createTable(nursesTable);
        await m.createTable(vhvsTable);
        await m.createTable(patientsTable);
        await m.createTable(screeningsTable);
        await m.createTable(screeningHistoriesTable);
        await m.createTable(screeningResultsTable);
      }
      if (from < 4) {
        if (from == 3) {
          await _migratePlaintextPasswords(m);
        } else {
          // Fresh v3 tables were created above without hash columns, so
          // this branch only applies to databases created before v3.
          await m.createTable(syncQueueTable);
        }
      }
    },
  );

  /// v3 -> v4: replace plaintext password columns with salted hashes and
  /// drop the plaintext columns. Existing values are hashed, never kept as-is.
  Future<void> _migratePlaintextPasswords(Migrator m) async {
    const hasher = PasswordHasher();

    await m.addColumn(vhvsTable, vhvsTable.vhvPasswordHash);
    await m.addColumn(nursesTable, nursesTable.nursePasswordHash);
    await m.createTable(syncQueueTable);

    final vhvRows = await customSelect(
      'SELECT vhv_id AS id, vhv_password AS pw FROM vhvs',
    ).get();
    for (final row in vhvRows) {
      final hash = await hasher.hash(row.read<String>('pw'));
      await customUpdate(
        'UPDATE vhvs SET vhv_password_hash = ? WHERE vhv_id = ?',
        variables: [
          Variable.withString(hash),
          Variable.withString(row.read<String>('id')),
        ],
        updates: {vhvsTable},
      );
    }

    final nurseRows = await customSelect(
      'SELECT nurse_id AS id, nurse_password AS pw FROM nurses',
    ).get();
    for (final row in nurseRows) {
      final hash = await hasher.hash(row.read<String>('pw'));
      await customUpdate(
        'UPDATE nurses SET nurse_password_hash = ? WHERE nurse_id = ?',
        variables: [
          Variable.withString(hash),
          Variable.withString(row.read<String>('id')),
        ],
        updates: {nursesTable},
      );
    }

    await m.alterTable(TableMigration(vhvsTable));
    await m.alterTable(TableMigration(nursesTable));
  }

  Future<void> _seedInitialDataIfEmpty() async {
    final existingVillages = await (select(villagesTable)..limit(1)).get();
    if (existingVillages.isNotEmpty) {
      return;
    }

    // Demo accounts share one hash; computed once to keep first launch fast.
    final demoPasswordHash = await const PasswordHasher().hash('password123');

    await transaction(() async {
      // 1. Seed Villages
      await batch((b) {
        b.insertAll(villagesTable, [
          const VillagesTableCompanion(
            villageId: Value('V001'),
            villageName: Value('บ้านท่าตอน'),
            villageNumber: Value('1'),
            subdistrictId: Value('SD001'),
            subdistrictName: Value('ท่าตอน'),
            districtName: Value('แม่อาย'),
            provinceName: Value('เชียงใหม่'),
          ),
          const VillagesTableCompanion(
            villageId: Value('V002'),
            villageName: Value('บ้านใหม่หมอกจ๋าม'),
            villageNumber: Value('2'),
            subdistrictId: Value('SD001'),
            subdistrictName: Value('ท่าตอน'),
            districtName: Value('แม่อาย'),
            provinceName: Value('เชียงใหม่'),
          ),
          const VillagesTableCompanion(
            villageId: Value('V003'),
            villageName: Value('บ้านห้วยปู'),
            villageNumber: Value('3'),
            subdistrictId: Value('SD001'),
            subdistrictName: Value('ท่าตอน'),
            districtName: Value('แม่อาย'),
            provinceName: Value('เชียงใหม่'),
          ),
          const VillagesTableCompanion(
            villageId: Value('V004'),
            villageName: Value('บ้านแม่ฮ่าง'),
            villageNumber: Value('4'),
            subdistrictId: Value('SD001'),
            subdistrictName: Value('ท่าตอน'),
            districtName: Value('แม่อาย'),
            provinceName: Value('เชียงใหม่'),
          ),
          const VillagesTableCompanion(
            villageId: Value('V005'),
            villageName: Value('บ้านร่มไทย'),
            villageNumber: Value('5'),
            subdistrictId: Value('SD001'),
            subdistrictName: Value('ท่าตอน'),
            districtName: Value('แม่อาย'),
            provinceName: Value('เชียงใหม่'),
          ),
        ]);
      });

      // 2. Seed Nurses
      await batch((b) {
        b.insertAll(nursesTable, [
          NursesTableCompanion(
            nurseId: const Value('NUR001'),
            nurseTitle: const Value('นางพยาบาล'),
            nurseFname: const Value('กานดา'),
            nurseLname: const Value('ใจดี'),
            nurseMobile: const Value('0823456789'),
            nurseEmail: const Value('nurse01@example.com'),
            nursePasswordHash: Value(demoPasswordHash),
            nurseGender: const Value('หญิง'),
            nurseBirthDate: Value(DateTime(1990, 10, 15)),
            subdistrictId: const Value('SD001'),
          ),
        ]);
      });

      // 3. Seed VHVs
      await batch((b) {
        b.insertAll(vhvsTable, [
          VhvsTableCompanion(
            vhvId: const Value('VHV001'),
            vhvCitizenId: const Value('1111111111111'),
            vhvTitle: const Value('นาย'),
            vhvFname: const Value('อสม'),
            vhvLname: const Value('ตัวอย่าง1'),
            vhvMobile: const Value('0800000001'),
            vhvEmail: const Value('vhv001@example.com'),
            vhvPasswordHash: Value(demoPasswordHash),
            vhvBirthDate: Value(DateTime(1995, 5, 20)),
            vhvGender: const Value('ชาย'),
            vhvAddress: const Value(
              'เลขที่ 60 หมู่ 1 บ้านท่าตอน ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่',
            ),
            villageId: const Value('V001'),
          ),
          VhvsTableCompanion(
            vhvId: const Value('VHV002'),
            vhvCitizenId: const Value('0647700893123'),
            vhvTitle: const Value('นาง'),
            vhvFname: const Value('สมใจ'),
            vhvLname: const Value('จิตอาสา'),
            vhvMobile: const Value('0647700893'),
            vhvEmail: const Value('somjai@example.com'),
            vhvPasswordHash: Value(demoPasswordHash),
            vhvBirthDate: Value(DateTime(1988, 3, 12)),
            vhvGender: const Value('หญิง'),
            vhvAddress: const Value('หมู่ 1 บ้านท่าตอน อ.แม่อาย'),
            villageId: const Value('V001'),
          ),
          VhvsTableCompanion(
            vhvId: const Value('VHV003'),
            vhvCitizenId: const Value('0812345678123'),
            vhvTitle: const Value('นาย'),
            vhvFname: const Value('มานะ'),
            vhvLname: const Value('ช่วยหมู่บ้าน'),
            vhvMobile: const Value('0812345678'),
            vhvEmail: const Value('mana@example.com'),
            vhvPasswordHash: Value(demoPasswordHash),
            vhvBirthDate: Value(DateTime(1982, 8, 25)),
            vhvGender: const Value('ชาย'),
            vhvAddress: const Value('หมู่ 1 บ้านท่าตอน อ.แม่อาย'),
            villageId: const Value('V001'),
          ),
        ]);
      });

      // 4. Seed Patients
      await batch((b) {
        b.insertAll(patientsTable, [
          PatientsTableCompanion(
            patientId: const Value('P001'),
            patientCitizenId: const Value('1234567890123'),
            patientTitle: const Value('นาย'),
            patientFname: const Value('สมชาย'),
            patientLname: const Value('ใจดี'),
            patientGender: const Value('ชาย'),
            patientBirthDate: Value(DateTime(1980, 2, 1)),
            patientAddress: const Value(
              '60 หมู่ 1 บ้านตัวอย่าง ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่',
            ),
            patientMobile: const Value('0891234567'),
            villageId: const Value('V001'),
          ),
          PatientsTableCompanion(
            patientId: const Value('P002'),
            patientCitizenId: const Value('2222222222222'),
            patientTitle: const Value('นาย'),
            patientFname: const Value('ว่าน'),
            patientLname: const Value('ตัวอย่าง'),
            patientGender: const Value('ชาย'),
            patientBirthDate: Value(DateTime(1996, 4, 15)),
            patientAddress: const Value(
              '15 หมู่ 1 บ้านท่าตอน ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่',
            ),
            patientMobile: const Value('0812222222'),
            villageId: const Value('V001'),
          ),
          PatientsTableCompanion(
            patientId: const Value('P003'),
            patientCitizenId: const Value('3250184930571'),
            patientTitle: const Value('นาง'),
            patientFname: const Value('สมศรี'),
            patientLname: const Value('มีสุข'),
            patientGender: const Value('หญิง'),
            patientBirthDate: Value(DateTime(1975, 7, 20)),
            patientAddress: const Value(
              '42 หมู่ 1 บ้านท่าตอน ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่',
            ),
            patientMobile: const Value('0834567890'),
            villageId: const Value('V001'),
          ),
          PatientsTableCompanion(
            patientId: const Value('P004'),
            patientCitizenId: const Value('1459900234889'),
            patientTitle: const Value('นาย'),
            patientFname: const Value('มั่นคง'),
            patientLname: const Value('ทรหด'),
            patientGender: const Value('ชาย'),
            patientBirthDate: Value(DateTime(1989, 10, 5)),
            patientAddress: const Value(
              '78 หมู่ 1 บ้านท่าตอน ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่',
            ),
            patientMobile: const Value('0867891234'),
            villageId: const Value('V001'),
          ),
          PatientsTableCompanion(
            patientId: const Value('P005'),
            patientCitizenId: const Value('2304055671004'),
            patientTitle: const Value('นาง'),
            patientFname: const Value('วิไล'),
            patientLname: const Value('งามตา'),
            patientGender: const Value('หญิง'),
            patientBirthDate: Value(DateTime(1986, 3, 14)),
            patientAddress: const Value(
              '23 หมู่ 1 บ้านท่าตอน ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่',
            ),
            patientMobile: const Value('0878901234'),
            villageId: const Value('V001'),
          ),
          PatientsTableCompanion(
            patientId: const Value('P006'),
            patientCitizenId: const Value('3102299845662'),
            patientTitle: const Value('นาย'),
            patientFname: const Value('ศักดิ์ดา'),
            patientLname: const Value('กล้าหาญ'),
            patientGender: const Value('ชาย'),
            patientBirthDate: Value(DateTime(1966, 6, 8)),
            patientAddress: const Value(
              '55 หมู่ 1 บ้านท่าตอน ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่',
            ),
            patientMobile: const Value('0890123456'),
            villageId: const Value('V001'),
          ),
        ]);
      });

      // 5. Seed Screenings
      await batch((b) {
        b.insertAll(screeningsTable, [
          ScreeningsTableCompanion(
            screenId: const Value('S001'),
            patientId: const Value('P001'),
            vhvId: const Value('VHV001'),
            screeningDate: Value(DateTime(2026, 2, 7, 10, 55)),
            ageAtScreening: const Value(46),
            createdAt: Value(DateTime(2026, 2, 7, 10, 55)),
            reviewStatus: const Value('PENDING'),
            weight: const Value(60.0),
            height: const Value(175.0),
            bmi: const Value(19.6),
            waistCm: const Value(72.0),
            sbp: const Value(125.0),
            dbp: const Value(65.0),
            pulse: const Value(72.0),
            bloodSugar: const Value(100.0),
          ),
          ScreeningsTableCompanion(
            screenId: const Value('S002'),
            patientId: const Value('P001'),
            vhvId: const Value('VHV001'),
            screeningDate: Value(DateTime(2026, 2, 11, 14, 22)),
            ageAtScreening: const Value(46),
            createdAt: Value(DateTime(2026, 2, 11, 14, 22)),
            reviewStatus: const Value('PENDING'),
            weight: const Value(60.0),
            height: const Value(175.0),
            bmi: const Value(19.6),
            waistCm: const Value(72.0),
            sbp: const Value(120.0),
            dbp: const Value(75.0),
            pulse: const Value(70.0),
            bloodSugar: const Value(98.0),
          ),
        ]);
      });

      // 6. Seed Screening Histories
      await batch((b) {
        b.insertAll(screeningHistoriesTable, [
          const ScreeningHistoriesTableCompanion(
            historyId: Value('H001'),
            screeningId: Value('S001'),
            questionId: Value('Q001'),
            questionText: Value('1) ประวัติป่วย/พบแพทย์ด้วยโรค NCDs'),
            answerText: Value('มี (เบาหวาน)'),
          ),
          const ScreeningHistoriesTableCompanion(
            historyId: Value('H002'),
            screeningId: Value('S001'),
            questionId: Value('Q002'),
            questionText: Value('2) ประวัติแพ้ยา'),
            answerText: Value('มี (ยาชา)'),
          ),
          const ScreeningHistoriesTableCompanion(
            historyId: Value('H003'),
            screeningId: Value('S001'),
            questionId: Value('Q003'),
            questionText: Value('3) ประวัติแพ้อาหาร'),
            answerText: Value('ไม่ทราบ'),
          ),
          const ScreeningHistoriesTableCompanion(
            historyId: Value('H004'),
            screeningId: Value('S001'),
            questionId: Value('Q004'),
            questionText: Value(
              '4) ญาติตรงสาย (พ่อ/แม่/พี่/น้อง) ป่วยเป็นโรค NCDs',
            ),
            answerText: Value('ไม่ทราบ'),
          ),
          const ScreeningHistoriesTableCompanion(
            historyId: Value('H005'),
            screeningId: Value('S002'),
            questionId: Value('Q001'),
            questionText: Value('1) ประวัติป่วย/พบแพทย์ด้วยโรค NCDs'),
            answerText: Value('มี (เบาหวาน)'),
          ),
          const ScreeningHistoriesTableCompanion(
            historyId: Value('H006'),
            screeningId: Value('S002'),
            questionId: Value('Q002'),
            questionText: Value('2) ประวัติแพ้ยา'),
            answerText: Value('มี (ยาชา)'),
          ),
          const ScreeningHistoriesTableCompanion(
            historyId: Value('H007'),
            screeningId: Value('S002'),
            questionId: Value('Q003'),
            questionText: Value('3) ประวัติแพ้อาหาร'),
            answerText: Value('ไม่ทราบ'),
          ),
          const ScreeningHistoriesTableCompanion(
            historyId: Value('H008'),
            screeningId: Value('S002'),
            questionId: Value('Q004'),
            questionText: Value(
              '4) ญาติตรงสาย (พ่อ/แม่/พี่/น้อง) ป่วยเป็นโรค NCDs',
            ),
            answerText: Value('ไม่ทราบ'),
          ),
        ]);
      });

      // 7. Seed Screening Results
      final resultsS1 = NcdRiskCalculator.evaluateRisk(
        screeningId: 'S001',
        weight: 60,
        height: 175,
        bmi: 19.6,
        waistCm: 72,
        sbp: 125,
        dbp: 65,
        pulse: 72,
        bloodSugar: 100,
        gender: 'ชาย',
        hasPersonalNcd: true,
        personalNcdDetail: 'เบาหวาน',
      );

      final resultsS2 = NcdRiskCalculator.evaluateRisk(
        screeningId: 'S002',
        weight: 60,
        height: 175,
        bmi: 19.6,
        waistCm: 72,
        sbp: 120,
        dbp: 75,
        pulse: 70,
        bloodSugar: 98,
        gender: 'ชาย',
      );

      final resultCompanions = <ScreeningResultsTableCompanion>[];
      for (final r in resultsS1) {
        resultCompanions.add(
          ScreeningResultsTableCompanion(
            resultId: Value(r.resultId),
            screeningId: Value(r.screeningId),
            diseaseName: Value(r.diseaseName),
            diseaseCode: Value(r.diseaseCode),
            score: Value(r.score),
            riskLevel: Value(r.riskLevel.name),
            adviceText: Value(r.adviceText),
            criteriaText: Value(r.criteriaText),
          ),
        );
      }
      for (final r in resultsS2) {
        resultCompanions.add(
          ScreeningResultsTableCompanion(
            resultId: Value(r.resultId),
            screeningId: Value(r.screeningId),
            diseaseName: Value(r.diseaseName),
            diseaseCode: Value(r.diseaseCode),
            score: Value(r.score),
            riskLevel: Value(r.riskLevel.name),
            adviceText: Value(r.adviceText),
            criteriaText: Value(r.criteriaText),
          ),
        );
      }

      await batch((b) {
        b.insertAll(screeningResultsTable, resultCompanions);
      });
    });
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'db');
  }
}
