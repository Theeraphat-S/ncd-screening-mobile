import 'package:drift/drift.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/services/password_hasher.dart';

class DriftNcdRepository implements NcdRepositoryInterface {
  final AppDatabase db;
  final PasswordHasher _hasher;

  DriftNcdRepository(this.db, {PasswordHasher? hasher})
    : _hasher = hasher ?? const PasswordHasher();

  // Session & Auth
  @override
  Future<dynamic> login({
    required UserRole role,
    required String identifier,
    String? password,
  }) async {
    final trimmedId = identifier.trim();
    final citizenIndex = await db.citizenIds.indexOf(trimmedId);
    if (role == UserRole.patient) {
      final query = db.select(db.patientsTable)
        ..where((t) => t.patientCitizenIdIndex.equals(citizenIndex));
      final row = await query.getSingleOrNull();
      if (row == null) {
        throw Exception('รหัสบัตรประชาชนไม่ถูกต้อง');
      }
      return await _mapPatient(row);
    } else if (role == UserRole.vhv) {
      final query = db.select(db.vhvsTable)
        ..where(
          (t) =>
              t.vhvCitizenIdIndex.equals(citizenIndex) |
              t.vhvMobile.equals(trimmedId) |
              t.vhvId.equals(trimmedId),
        );
      final row = await query.getSingleOrNull();
      if (row == null) {
        throw Exception('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง');
      }
      if (!await _passwordMatches(password, row.vhvPasswordHash)) {
        throw Exception('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง');
      }
      return await _mapVhv(row);
    } else if (role == UserRole.nurse) {
      final query = db.select(db.nursesTable)
        ..where(
          (t) =>
              t.nurseId.equals(trimmedId) |
              t.nurseMobile.equals(trimmedId) |
              t.nurseEmail.equals(trimmedId),
        );
      final row = await query.getSingleOrNull();
      if (row == null) {
        throw Exception('รหัสพยาบาลหรือรหัสผ่านไม่ถูกต้อง');
      }
      if (!await _passwordMatches(password, row.nursePasswordHash)) {
        throw Exception('รหัสพยาบาลหรือรหัสผ่านไม่ถูกต้อง');
      }
      return _mapNurse(row);
    }
    throw Exception('ไม่พบบทบาทผู้ใช้');
  }

  @override
  Future<bool> verifyNursePassword({
    required String nurseId,
    required String password,
  }) async {
    if (password.isEmpty) return false;
    final row = await (db.select(
      db.nursesTable,
    )..where((t) => t.nurseId.equals(nurseId))).getSingleOrNull();
    if (row == null) return false;
    return _passwordMatches(password, row.nursePasswordHash);
  }

  /// Empty input never matches, so a missing password cannot bypass the check.
  Future<bool> _passwordMatches(String? password, String storedHash) async {
    if (password == null || password.isEmpty || storedHash.isEmpty) {
      return false;
    }
    return _hasher.verify(password, storedHash);
  }

  // Villages
  @override
  Future<List<Village>> getVillages() async {
    final rows = await db.select(db.villagesTable).get();
    return rows.map(_mapVillage).toList();
  }

  @override
  Future<Village?> getVillageById(String villageId) async {
    final query = db.select(db.villagesTable)
      ..where((t) => t.villageId.equals(villageId));
    final row = await query.getSingleOrNull();
    return row != null ? _mapVillage(row) : null;
  }

  // Patients
  @override
  Future<List<Patient>> getPatients({
    String? villageId,
    String? searchQuery,
  }) async {
    var query = db.select(db.patientsTable);
    if (villageId != null && villageId.isNotEmpty) {
      query = query..where((t) => t.villageId.equals(villageId));
    }
    final rows = await query.get();
    var list = await Future.wait(rows.map(_mapPatient));
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((p) {
        return p.patientCitizenId.contains(q) ||
            p.patientFname.toLowerCase().contains(q) ||
            p.patientLname.toLowerCase().contains(q) ||
            p.fullName.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  @override
  Future<Patient?> getPatientById(String patientId) async {
    final query = db.select(db.patientsTable)
      ..where((t) => t.patientId.equals(patientId));
    final row = await query.getSingleOrNull();
    return row != null ? await _mapPatient(row) : null;
  }

  @override
  Future<Patient?> getPatientByCitizenId(String citizenId) async {
    final index = await db.citizenIds.indexOf(citizenId);
    final query = db.select(db.patientsTable)
      ..where((t) => t.patientCitizenIdIndex.equals(index));
    final row = await query.getSingleOrNull();
    return row != null ? await _mapPatient(row) : null;
  }

  @override
  Future<Patient> addPatient(Patient patient) async {
    String newId = patient.patientId;
    if (newId.isEmpty) {
      final count = (await db.select(db.patientsTable).get()).length;
      newId = 'P${(count + 1).toString().padLeft(3, '0')}';
    }
    final created = patient.copyWith(patientId: newId);
    final cid = await db.citizenIds.encrypt(created.patientCitizenId);
    final cidIndex = await db.citizenIds.indexOf(created.patientCitizenId);
    await db
        .into(db.patientsTable)
        .insert(
          PatientsTableCompanion(
            patientId: Value(created.patientId),
            patientCitizenId: Value(cid),
            patientCitizenIdIndex: Value(cidIndex),
            patientTitle: Value(created.patientTitle),
            patientFname: Value(created.patientFname),
            patientLname: Value(created.patientLname),
            patientGender: Value(created.patientGender),
            patientBirthDate: Value(created.patientBirthDate),
            patientAddress: Value(created.patientAddress),
            patientMobile: Value(created.patientMobile),
            patientImg: Value(created.patientImg),
            villageId: Value(created.villageId),
          ),
        );
    return created;
  }

  @override
  Future<Patient> updatePatient(Patient patient) async {
    final cid = await db.citizenIds.encrypt(patient.patientCitizenId);
    final cidIndex = await db.citizenIds.indexOf(patient.patientCitizenId);
    final rowsAffected =
        await (db.update(
          db.patientsTable,
        )..where((t) => t.patientId.equals(patient.patientId))).write(
          PatientsTableCompanion(
            patientCitizenId: Value(cid),
            patientCitizenIdIndex: Value(cidIndex),
            patientTitle: Value(patient.patientTitle),
            patientFname: Value(patient.patientFname),
            patientLname: Value(patient.patientLname),
            patientGender: Value(patient.patientGender),
            patientBirthDate: Value(patient.patientBirthDate),
            patientAddress: Value(patient.patientAddress),
            patientMobile: Value(patient.patientMobile),
            patientImg: Value(patient.patientImg),
            villageId: Value(patient.villageId),
          ),
        );
    if (rowsAffected == 0) {
      throw Exception('แก้ไขผู้ป่วย ไม่สำเร็จ');
    }
    return patient;
  }

  @override
  Future<bool> deletePatient(String patientId) async {
    return db.transaction(() async {
      final screenings = await (db.select(
        db.screeningsTable,
      )..where((t) => t.patientId.equals(patientId))).get();
      final screeningIds = screenings.map((s) => s.screenId).toList();

      if (screeningIds.isNotEmpty) {
        await (db.delete(
          db.screeningResultsTable,
        )..where((t) => t.screeningId.isIn(screeningIds))).go();
        await (db.delete(
          db.screeningHistoriesTable,
        )..where((t) => t.screeningId.isIn(screeningIds))).go();
        await (db.delete(
          db.screeningsTable,
        )..where((t) => t.screenId.isIn(screeningIds))).go();
      }

      final rows = await (db.delete(
        db.patientsTable,
      )..where((t) => t.patientId.equals(patientId))).go();
      return rows > 0;
    });
  }

  // VHV
  @override
  Future<List<VHV>> getVhvs({String? villageId}) async {
    var query = db.select(db.vhvsTable);
    if (villageId != null && villageId.isNotEmpty) {
      query = query..where((t) => t.villageId.equals(villageId));
    }
    final rows = await query.get();
    return Future.wait(rows.map(_mapVhv));
  }

  @override
  Future<VHV?> getVhvById(String vhvId) async {
    final query = db.select(db.vhvsTable)..where((t) => t.vhvId.equals(vhvId));
    final row = await query.getSingleOrNull();
    return row != null ? await _mapVhv(row) : null;
  }

  @override
  Future<VHV> addVhv(VHV vhv) async {
    if (vhv.vhvPassword.isEmpty) {
      throw Exception('กรุณากำหนดรหัสผ่านให้ อสม.');
    }
    String newId = vhv.vhvId;
    if (newId.isEmpty) {
      final count = (await db.select(db.vhvsTable).get()).length;
      newId = 'VHV${(count + 1).toString().padLeft(3, '0')}';
    }
    final created = vhv.copyWith(vhvId: newId);
    final passwordHash = await _hasher.hash(created.vhvPassword);
    final cid = await db.citizenIds.encrypt(created.vhvCitizenId);
    final cidIndex = await db.citizenIds.indexOf(created.vhvCitizenId);
    await db
        .into(db.vhvsTable)
        .insert(
          VhvsTableCompanion(
            vhvId: Value(created.vhvId),
            vhvCitizenId: Value(cid),
            vhvCitizenIdIndex: Value(cidIndex),
            vhvTitle: Value(created.vhvTitle),
            vhvFname: Value(created.vhvFname),
            vhvLname: Value(created.vhvLname),
            vhvMobile: Value(created.vhvMobile),
            vhvEmail: Value(created.vhvEmail),
            vhvPasswordHash: Value(passwordHash),
            vhvBirthDate: Value(created.vhvBirthDate),
            vhvGender: Value(created.vhvGender),
            vhvAddress: Value(created.vhvAddress),
            vhvImg: Value(created.vhvImg),
            villageId: Value(created.villageId),
          ),
        );
    return created;
  }

  @override
  Future<VHV> updateVhv(VHV vhv) async {
    final cid = await db.citizenIds.encrypt(vhv.vhvCitizenId);
    final cidIndex = await db.citizenIds.indexOf(vhv.vhvCitizenId);
    // Empty password means "keep the current one".
    final passwordHash = vhv.vhvPassword.isNotEmpty
        ? Value(await _hasher.hash(vhv.vhvPassword))
        : const Value<String>.absent();
    final rowsAffected =
        await (db.update(
          db.vhvsTable,
        )..where((t) => t.vhvId.equals(vhv.vhvId))).write(
          VhvsTableCompanion(
            vhvCitizenId: Value(cid),
            vhvCitizenIdIndex: Value(cidIndex),
            vhvTitle: Value(vhv.vhvTitle),
            vhvFname: Value(vhv.vhvFname),
            vhvLname: Value(vhv.vhvLname),
            vhvMobile: Value(vhv.vhvMobile),
            vhvEmail: Value(vhv.vhvEmail),
            vhvPasswordHash: passwordHash,
            vhvBirthDate: Value(vhv.vhvBirthDate),
            vhvGender: Value(vhv.vhvGender),
            vhvAddress: Value(vhv.vhvAddress),
            vhvImg: Value(vhv.vhvImg),
            villageId: Value(vhv.villageId),
          ),
        );
    if (rowsAffected == 0) {
      throw Exception('แก้ไขอสม ไม่สำเร็จ');
    }
    return vhv;
  }

  // Nurse
  @override
  Future<Nurse?> getNurseById(String nurseId) async {
    final query = db.select(db.nursesTable)
      ..where((t) => t.nurseId.equals(nurseId));
    final row = await query.getSingleOrNull();
    return row != null ? _mapNurse(row) : null;
  }

  // Screenings
  @override
  Future<List<Screening>> getScreeningsByPatient(String patientId) async {
    final query = db.select(db.screeningsTable)
      ..where((t) => t.patientId.equals(patientId))
      ..orderBy([(t) => OrderingTerm.desc(t.screeningDate)]);
    final rows = await query.get();
    final screenings = <Screening>[];
    for (final row in rows) {
      final histories = await (db.select(
        db.screeningHistoriesTable,
      )..where((t) => t.screeningId.equals(row.screenId))).get();
      final results = await (db.select(
        db.screeningResultsTable,
      )..where((t) => t.screeningId.equals(row.screenId))).get();
      screenings.add(_mapScreening(row, histories, results));
    }
    return screenings;
  }

  @override
  Future<List<Screening>> getAllScreenings({String? villageId}) async {
    List<ScreeningsTableData> rows;
    if (villageId != null && villageId.isNotEmpty) {
      final patientsInVillage = await (db.select(
        db.patientsTable,
      )..where((t) => t.villageId.equals(villageId))).get();
      final patientIds = patientsInVillage.map((p) => p.patientId).toList();
      if (patientIds.isEmpty) {
        return [];
      }
      final query = db.select(db.screeningsTable)
        ..where((t) => t.patientId.isIn(patientIds))
        ..orderBy([(t) => OrderingTerm.desc(t.screeningDate)]);
      rows = await query.get();
    } else {
      final query = db.select(db.screeningsTable)
        ..orderBy([(t) => OrderingTerm.desc(t.screeningDate)]);
      rows = await query.get();
    }

    final screenings = <Screening>[];
    for (final row in rows) {
      final histories = await (db.select(
        db.screeningHistoriesTable,
      )..where((t) => t.screeningId.equals(row.screenId))).get();
      final results = await (db.select(
        db.screeningResultsTable,
      )..where((t) => t.screeningId.equals(row.screenId))).get();
      screenings.add(_mapScreening(row, histories, results));
    }
    return screenings;
  }

  @override
  Future<Screening?> getScreeningById(String screeningId) async {
    final query = db.select(db.screeningsTable)
      ..where((t) => t.screenId.equals(screeningId));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    final histories = await (db.select(
      db.screeningHistoriesTable,
    )..where((t) => t.screeningId.equals(row.screenId))).get();
    final results = await (db.select(
      db.screeningResultsTable,
    )..where((t) => t.screeningId.equals(row.screenId))).get();
    return _mapScreening(row, histories, results);
  }

  @override
  Future<Screening> saveScreening(Screening screening) async {
    String newId = screening.screenId;
    if (newId.isEmpty) {
      final count = (await db.select(db.screeningsTable).get()).length;
      newId = 'S${(count + 1).toString().padLeft(3, '0')}';
    }
    final created = screening.copyWith(screenId: newId);

    await db.transaction(() async {
      await db
          .into(db.screeningsTable)
          .insert(
            ScreeningsTableCompanion(
              screenId: Value(created.screenId),
              patientId: Value(created.patientId),
              vhvId: Value(created.vhvId),
              screeningDate: Value(created.screeningDate),
              ageAtScreening: Value(created.ageAtScreening),
              createdAt: Value(created.createdAt),
              reviewStatus: Value(created.reviewStatus.code),
              reviewedByNurseId: Value(created.reviewedByNurseId),
              reviewedAt: Value(created.reviewedAt),
              weight: Value(created.weight),
              height: Value(created.height),
              bmi: Value(created.bmi),
              waistCm: Value(created.waistCm),
              sbp: Value(created.sbp),
              dbp: Value(created.dbp),
              pulse: Value(created.pulse),
              bloodSugar: Value(created.bloodSugar),
            ),
          );

      if (created.histories.isNotEmpty) {
        final historyCompanions = <ScreeningHistoriesTableCompanion>[];
        for (var i = 0; i < created.histories.length; i++) {
          final h = created.histories[i];
          final hid = h.historyId.isNotEmpty
              ? h.historyId
              : 'H_${newId}_${i + 1}';
          historyCompanions.add(
            ScreeningHistoriesTableCompanion(
              historyId: Value(hid),
              screeningId: Value(newId),
              questionId: Value(h.questionId),
              questionText: Value(h.questionText),
              answerValue: Value(h.answerValue),
              answerText: Value(h.answerText),
            ),
          );
        }
        await db.batch((b) {
          b.insertAll(db.screeningHistoriesTable, historyCompanions);
        });
      }

      if (created.results.isNotEmpty) {
        final resultCompanions = <ScreeningResultsTableCompanion>[];
        for (var i = 0; i < created.results.length; i++) {
          final r = created.results[i];
          final rid = r.resultId.isNotEmpty
              ? r.resultId
              : 'R_${newId}_${i + 1}';
          resultCompanions.add(
            ScreeningResultsTableCompanion(
              resultId: Value(rid),
              screeningId: Value(newId),
              diseaseName: Value(r.diseaseName),
              diseaseCode: Value(r.diseaseCode),
              score: Value(r.score),
              riskLevel: Value(r.riskLevel.name),
              adviceText: Value(r.adviceText),
              criteriaText: Value(r.criteriaText),
            ),
          );
        }
        await db.batch((b) {
          b.insertAll(db.screeningResultsTable, resultCompanions);
        });
      }
    });

    return created;
  }

  @override
  Future<Screening> updateScreeningReview({
    required String screeningId,
    required ReviewStatus status,
    required String nurseId,
    List<ScreeningResult>? updatedResults,
  }) async {
    final existing = await getScreeningById(screeningId);
    if (existing == null) {
      throw Exception('บันทึกผลประเมิน ไม่สำเร็จ');
    }
    final now = DateTime.now();

    await db.transaction(() async {
      await (db.update(
        db.screeningsTable,
      )..where((t) => t.screenId.equals(screeningId))).write(
        ScreeningsTableCompanion(
          reviewStatus: Value(status.code),
          reviewedByNurseId: Value(nurseId),
          reviewedAt: Value(now),
        ),
      );

      if (updatedResults != null) {
        await (db.delete(
          db.screeningResultsTable,
        )..where((t) => t.screeningId.equals(screeningId))).go();

        final resultCompanions = <ScreeningResultsTableCompanion>[];
        for (var i = 0; i < updatedResults.length; i++) {
          final r = updatedResults[i];
          final rid = r.resultId.isNotEmpty
              ? r.resultId
              : 'R_${screeningId}_${i + 1}';
          resultCompanions.add(
            ScreeningResultsTableCompanion(
              resultId: Value(rid),
              screeningId: Value(screeningId),
              diseaseName: Value(r.diseaseName),
              diseaseCode: Value(r.diseaseCode),
              score: Value(r.score),
              riskLevel: Value(r.riskLevel.name),
              adviceText: Value(r.adviceText),
              criteriaText: Value(r.criteriaText),
            ),
          );
        }
        await db.batch((b) {
          b.insertAll(db.screeningResultsTable, resultCompanions);
        });
      }
    });

    final updated = await getScreeningById(screeningId);
    return updated!;
  }

  // Model Mappers
  Village _mapVillage(VillagesTableData row) {
    return Village(
      villageId: row.villageId,
      villageName: row.villageName,
      villageNumber: row.villageNumber,
      subdistrictId: row.subdistrictId,
      subdistrictName: row.subdistrictName,
      districtName: row.districtName,
      provinceName: row.provinceName,
    );
  }

  Future<Patient> _mapPatient(PatientsTableData row) async {
    return Patient(
      patientId: row.patientId,
      patientCitizenId: await db.citizenIds.decrypt(row.patientCitizenId),
      patientTitle: row.patientTitle,
      patientFname: row.patientFname,
      patientLname: row.patientLname,
      patientGender: row.patientGender,
      patientBirthDate: row.patientBirthDate,
      patientAddress: row.patientAddress,
      patientMobile: row.patientMobile,
      patientImg: row.patientImg,
      villageId: row.villageId,
    );
  }

  Future<VHV> _mapVhv(VhvsTableData row) async {
    return VHV(
      vhvId: row.vhvId,
      vhvCitizenId: await db.citizenIds.decrypt(row.vhvCitizenId),
      vhvTitle: row.vhvTitle,
      vhvFname: row.vhvFname,
      vhvLname: row.vhvLname,
      vhvMobile: row.vhvMobile,
      vhvEmail: row.vhvEmail,
      vhvPassword: '', // Never expose stored hashes or plaintext
      vhvBirthDate: row.vhvBirthDate,
      vhvGender: row.vhvGender,
      vhvAddress: row.vhvAddress,
      vhvImg: row.vhvImg,
      villageId: row.villageId,
    );
  }

  Nurse _mapNurse(NursesTableData row) {
    return Nurse(
      nurseId: row.nurseId,
      nurseTitle: row.nurseTitle,
      nurseFname: row.nurseFname,
      nurseLname: row.nurseLname,
      nurseMobile: row.nurseMobile,
      nurseEmail: row.nurseEmail,
      nursePassword: '', // Never expose stored hashes or plaintext
      nurseGender: row.nurseGender,
      nurseBirthDate: row.nurseBirthDate,
      nurseImg: row.nurseImg,
      subdistrictId: row.subdistrictId,
    );
  }

  Screening _mapScreening(
    ScreeningsTableData row,
    List<ScreeningHistoriesTableData> histories,
    List<ScreeningResultsTableData> results,
  ) {
    return Screening(
      screenId: row.screenId,
      patientId: row.patientId,
      vhvId: row.vhvId,
      screeningDate: row.screeningDate,
      ageAtScreening: row.ageAtScreening,
      createdAt: row.createdAt,
      reviewStatus: ReviewStatus.fromString(row.reviewStatus),
      reviewedByNurseId: row.reviewedByNurseId,
      reviewedAt: row.reviewedAt,
      weight: row.weight,
      height: row.height,
      bmi: row.bmi,
      waistCm: row.waistCm,
      sbp: row.sbp,
      dbp: row.dbp,
      pulse: row.pulse,
      bloodSugar: row.bloodSugar,
      histories: histories
          .map(
            (h) => ScreeningHistory(
              historyId: h.historyId,
              screeningId: h.screeningId,
              questionId: h.questionId,
              questionText: h.questionText,
              answerValue: h.answerValue,
              answerText: h.answerText,
            ),
          )
          .toList(),
      results: results
          .map(
            (r) => ScreeningResult(
              resultId: r.resultId,
              screeningId: r.screeningId,
              diseaseName: r.diseaseName,
              diseaseCode: r.diseaseCode,
              score: r.score,
              riskLevel: RiskLevel.fromString(r.riskLevel),
              adviceText: r.adviceText,
              criteriaText: r.criteriaText,
            ),
          )
          .toList(),
    );
  }
}
