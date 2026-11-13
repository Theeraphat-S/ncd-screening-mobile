import 'package:drift/drift.dart';
import 'package:ncd_screening_mobile/domain/services/patient_search.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/id_generator.dart';
import 'package:ncd_screening_mobile/domain/services/password_hasher.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';

class DriftNcdRepository implements NcdRepositoryInterface {
  final AppDatabase db;

  DriftNcdRepository(this.db);

  // Session & Auth
  @override
  Future<dynamic> login({
    required UserRole role,
    required String identifier,
    String? password,
    DateTime? birthDate,
  }) async {
    final trimmedId = identifier.trim();
    if (role == UserRole.patient) {
      const message = 'เลขบัตรประชาชนหรือวันเกิดไม่ถูกต้อง';
      final query = db.select(db.patientsTable)
        ..where((t) => t.patientCitizenId.equals(trimmedId));
      final row = await query.getSingleOrNull();
      if (row == null || birthDate == null) {
        throw Exception(message);
      }
      final dob = row.patientBirthDate;
      if (birthDate.year != dob.year ||
          birthDate.month != dob.month ||
          birthDate.day != dob.day) {
        throw Exception(message);
      }
      return _mapPatient(row);
    } else if (role == UserRole.vhv) {
      const message = 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง';
      final query = db.select(db.vhvsTable)
        ..where((t) =>
            t.vhvCitizenId.equals(trimmedId) |
            t.vhvMobile.equals(trimmedId) |
            t.vhvId.equals(trimmedId));
      final row = await query.getSingleOrNull();
      if (row == null || !await _passwordMatches(password, row.vhvPassword)) {
        throw Exception(message);
      }
      if (!PasswordHasher.isHashed(row.vhvPassword)) {
        await (db.update(db.vhvsTable)..where((t) => t.vhvId.equals(row.vhvId)))
            .write(VhvsTableCompanion(
          vhvPassword: Value(await PasswordHasher.hashAsync(password!)),
        ));
      }
      return _mapVhv(row);
    } else if (role == UserRole.nurse) {
      const message = 'รหัสพยาบาลหรือรหัสผ่านไม่ถูกต้อง';
      final query = db.select(db.nursesTable)
        ..where((t) =>
            t.nurseId.equals(trimmedId) |
            t.nurseMobile.equals(trimmedId) |
            t.nurseEmail.equals(trimmedId));
      final row = await query.getSingleOrNull();
      if (row == null || !await _passwordMatches(password, row.nursePassword)) {
        throw Exception(message);
      }
      if (!PasswordHasher.isHashed(row.nursePassword)) {
        await (db.update(db.nursesTable)
              ..where((t) => t.nurseId.equals(row.nurseId)))
            .write(NursesTableCompanion(
          nursePassword: Value(await PasswordHasher.hashAsync(password!)),
        ));
      }
      return _mapNurse(row);
    }
    throw Exception('ไม่พบบทบาทผู้ใช้');
  }

  /// Hashed values are verified with PBKDF2. Legacy plaintext rows (written
  /// before hashing existed) are compared once and upgraded by the caller.
  Future<bool> _passwordMatches(String? supplied, String stored) async {
    if (supplied == null || supplied.isEmpty) return false;
    return PasswordHasher.isHashed(stored)
        ? await PasswordHasher.verifyAsync(supplied, stored)
        : stored == supplied;
  }

  /// Keeps an already-hashed value as is; hashes anything else.
  Future<String> _hashIfNeeded(String value) async =>
      PasswordHasher.isHashed(value) ? value : await PasswordHasher.hashAsync(value);

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
    var list = rows.map(_mapPatient).toList();
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      list = list.where((p) => PatientSearch.matches(p, searchQuery)).toList();
    }
    return list;
  }

  @override
  Future<Patient?> getPatientById(String patientId) async {
    final query = db.select(db.patientsTable)
      ..where((t) => t.patientId.equals(patientId));
    final row = await query.getSingleOrNull();
    return row != null ? _mapPatient(row) : null;
  }

  @override
  Future<Patient?> getPatientByCitizenId(String citizenId) async {
    final query = db.select(db.patientsTable)
      ..where((t) => t.patientCitizenId.equals(citizenId.trim()));
    final row = await query.getSingleOrNull();
    return row != null ? _mapPatient(row) : null;
  }

  @override
  Future<Patient> addPatient(Patient patient) async {
    String newId = patient.patientId;
    if (newId.isEmpty) {
      newId = generateId();
    }
    final created = patient.copyWith(patientId: newId);
    await db.into(db.patientsTable).insert(
          PatientsTableCompanion(
            patientId: Value(created.patientId),
            patientCitizenId: Value(created.patientCitizenId),
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
    final rowsAffected = await (db.update(db.patientsTable)
          ..where((t) => t.patientId.equals(patient.patientId)))
        .write(
      PatientsTableCompanion(
        patientCitizenId: Value(patient.patientCitizenId),
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
    final rows = await (db.delete(db.patientsTable)
          ..where((t) => t.patientId.equals(patientId)))
        .go();
    return rows > 0;
  }

  // VHV
  @override
  Future<List<VHV>> getVhvs({String? villageId}) async {
    var query = db.select(db.vhvsTable);
    if (villageId != null && villageId.isNotEmpty) {
      query = query..where((t) => t.villageId.equals(villageId));
    }
    final rows = await query.get();
    return rows.map(_mapVhv).toList();
  }

  @override
  Future<VHV?> getVhvById(String vhvId) async {
    final query = db.select(db.vhvsTable)
      ..where((t) => t.vhvId.equals(vhvId));
    final row = await query.getSingleOrNull();
    return row != null ? _mapVhv(row) : null;
  }

  @override
  Future<VHV> addVhv(VHV vhv) async {
    String newId = vhv.vhvId;
    if (newId.isEmpty) {
      newId = generateId();
    }
    final created = vhv.copyWith(vhvId: newId);
    final passwordHash = await _hashIfNeeded(created.vhvPassword);
    await db.into(db.vhvsTable).insert(
          VhvsTableCompanion(
            vhvId: Value(created.vhvId),
            vhvCitizenId: Value(created.vhvCitizenId),
            vhvTitle: Value(created.vhvTitle),
            vhvFname: Value(created.vhvFname),
            vhvLname: Value(created.vhvLname),
            vhvMobile: Value(created.vhvMobile),
            vhvEmail: Value(created.vhvEmail),
            vhvPassword: Value(passwordHash),
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
    final passwordHash = await _hashIfNeeded(vhv.vhvPassword);
    final rowsAffected = await (db.update(db.vhvsTable)
          ..where((t) => t.vhvId.equals(vhv.vhvId)))
        .write(
      VhvsTableCompanion(
        vhvCitizenId: Value(vhv.vhvCitizenId),
        vhvTitle: Value(vhv.vhvTitle),
        vhvFname: Value(vhv.vhvFname),
        vhvLname: Value(vhv.vhvLname),
        vhvMobile: Value(vhv.vhvMobile),
        vhvEmail: Value(vhv.vhvEmail),
        vhvPassword: Value(passwordHash),
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
    return _hydrateScreenings(rows);
  }

  @override
  Future<List<Screening>> getAllScreenings({String? villageId}) async {
    final query = db.select(db.screeningsTable)
      ..orderBy([(t) => OrderingTerm.desc(t.screeningDate)]);
    if (villageId != null && villageId.isNotEmpty) {
      // Sub-select instead of a bound id list: SQLite caps bound variables
      // (999 on older Android builds), and a village can hold more patients.
      final inVillage = db.selectOnly(db.patientsTable)
        ..addColumns([db.patientsTable.patientId])
        ..where(db.patientsTable.villageId.equals(villageId));
      query.where((t) => t.patientId.isInQuery(inVillage));
    }
    return _hydrateScreenings(await query.get());
  }

  /// Attaches histories and results with two batched queries per chunk
  /// instead of two queries per screening (N+1).
  Future<List<Screening>> _hydrateScreenings(
    List<ScreeningsTableData> rows,
  ) async {
    if (rows.isEmpty) return const [];
    const chunkSize = 500;
    final histories = <String, List<ScreeningHistoriesTableData>>{};
    final results = <String, List<ScreeningResultsTableData>>{};
    for (var i = 0; i < rows.length; i += chunkSize) {
      final end = i + chunkSize < rows.length ? i + chunkSize : rows.length;
      final ids = [for (final r in rows.sublist(i, end)) r.screenId];
      final historyRows = await (db.select(db.screeningHistoriesTable)
            ..where((t) => t.screeningId.isIn(ids)))
          .get();
      for (final h in historyRows) {
        histories.putIfAbsent(h.screeningId, () => []).add(h);
      }
      final resultRows = await (db.select(db.screeningResultsTable)
            ..where((t) => t.screeningId.isIn(ids)))
          .get();
      for (final r in resultRows) {
        results.putIfAbsent(r.screeningId, () => []).add(r);
      }
    }
    return [
      for (final row in rows)
        _mapScreening(
          row,
          histories[row.screenId] ?? const [],
          results[row.screenId] ?? const [],
        ),
    ];
  }

  @override
  Future<Screening?> getScreeningById(String screeningId) async {
    final query = db.select(db.screeningsTable)
      ..where((t) => t.screenId.equals(screeningId));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    final histories = await (db.select(db.screeningHistoriesTable)
          ..where((t) => t.screeningId.equals(row.screenId)))
        .get();
    final results = await (db.select(db.screeningResultsTable)
          ..where((t) => t.screeningId.equals(row.screenId)))
        .get();
    return _mapScreening(row, histories, results);
  }

  @override
  Future<Screening> saveScreening(Screening screening) async {
    String newId = screening.screenId;
    if (newId.isEmpty) {
      newId = generateId();
    }
    final created = screening.copyWith(screenId: newId);

    await db.transaction(() async {
      await db.into(db.screeningsTable).insert(
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
          final hid =
              h.historyId.isNotEmpty ? h.historyId : 'H_${newId}_${i + 1}';
          historyCompanions.add(ScreeningHistoriesTableCompanion(
            historyId: Value(hid),
            screeningId: Value(newId),
            questionId: Value(h.questionId),
            questionText: Value(h.questionText),
            answerValue: Value(h.answerValue),
            answerText: Value(h.answerText),
          ));
        }
        await db.batch((b) {
          b.insertAll(db.screeningHistoriesTable, historyCompanions);
        });
      }

      if (created.results.isNotEmpty) {
        final resultCompanions = <ScreeningResultsTableCompanion>[];
        for (var i = 0; i < created.results.length; i++) {
          final r = created.results[i];
          final rid =
              r.resultId.isNotEmpty ? r.resultId : 'R_${newId}_${i + 1}';
          resultCompanions.add(ScreeningResultsTableCompanion(
            resultId: Value(rid),
            screeningId: Value(newId),
            diseaseName: Value(r.diseaseName),
            diseaseCode: Value(r.diseaseCode),
            score: Value(r.score),
            riskLevel: Value(r.riskLevel.name),
            adviceText: Value(r.adviceText),
            criteriaText: Value(r.criteriaText),
          ));
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
      await (db.update(db.screeningsTable)
            ..where((t) => t.screenId.equals(screeningId)))
          .write(
        ScreeningsTableCompanion(
          reviewStatus: Value(status.code),
          reviewedByNurseId: Value(nurseId),
          reviewedAt: Value(now),
        ),
      );

      if (updatedResults != null) {
        await (db.delete(db.screeningResultsTable)
              ..where((t) => t.screeningId.equals(screeningId)))
            .go();

        final resultCompanions = <ScreeningResultsTableCompanion>[];
        for (var i = 0; i < updatedResults.length; i++) {
          final r = updatedResults[i];
          final rid =
              r.resultId.isNotEmpty ? r.resultId : 'R_${screeningId}_${i + 1}';
          resultCompanions.add(ScreeningResultsTableCompanion(
            resultId: Value(rid),
            screeningId: Value(screeningId),
            diseaseName: Value(r.diseaseName),
            diseaseCode: Value(r.diseaseCode),
            score: Value(r.score),
            riskLevel: Value(r.riskLevel.name),
            adviceText: Value(r.adviceText),
            criteriaText: Value(r.criteriaText),
          ));
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

  Patient _mapPatient(PatientsTableData row) {
    return Patient(
      patientId: row.patientId,
      patientCitizenId: row.patientCitizenId,
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

  VHV _mapVhv(VhvsTableData row) {
    return VHV(
      vhvId: row.vhvId,
      vhvCitizenId: row.vhvCitizenId,
      vhvTitle: row.vhvTitle,
      vhvFname: row.vhvFname,
      vhvLname: row.vhvLname,
      vhvMobile: row.vhvMobile,
      vhvEmail: row.vhvEmail,
      vhvPassword: row.vhvPassword,
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
      nursePassword: row.nursePassword,
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
          .map((h) => ScreeningHistory(
                historyId: h.historyId,
                screeningId: h.screeningId,
                questionId: h.questionId,
                questionText: h.questionText,
                answerValue: h.answerValue,
                answerText: h.answerText,
              ))
          .toList(),
      results: results
          .map((r) => ScreeningResult(
                resultId: r.resultId,
                screeningId: r.screeningId,
                diseaseName: r.diseaseName,
                diseaseCode: r.diseaseCode,
                score: r.score,
                riskLevel: RiskLevel.fromString(r.riskLevel),
                adviceText: r.adviceText,
                criteriaText: r.criteriaText,
              ))
          .toList(),
    );
  }
}
