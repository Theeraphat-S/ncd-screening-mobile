import 'package:drift/drift.dart';

class VillagesTable extends Table {
  @override
  String get tableName => 'villages';

  TextColumn get villageId => text()();
  TextColumn get villageName => text()();
  TextColumn get villageNumber => text()();
  TextColumn get subdistrictId =>
      text().withDefault(const Constant('SD001'))();
  TextColumn get subdistrictName =>
      text().withDefault(const Constant('ท่าตอน'))();
  TextColumn get districtName =>
      text().withDefault(const Constant('แม่อาย'))();
  TextColumn get provinceName =>
      text().withDefault(const Constant('เชียงใหม่'))();

  @override
  Set<Column> get primaryKey => {villageId};
}

class NursesTable extends Table {
  @override
  String get tableName => 'nurses';

  TextColumn get nurseId => text()();
  TextColumn get nurseTitle => text()();
  TextColumn get nurseFname => text()();
  TextColumn get nurseLname => text()();
  TextColumn get nurseMobile => text()();
  TextColumn get nurseEmail => text()();
  TextColumn get nursePassword => text()();
  TextColumn get nurseGender => text()();
  DateTimeColumn get nurseBirthDate => dateTime()();
  TextColumn get nurseImg => text().nullable()();
  TextColumn get subdistrictId =>
      text().withDefault(const Constant('SD001'))();

  @override
  Set<Column> get primaryKey => {nurseId};
}

class VhvsTable extends Table {
  @override
  String get tableName => 'vhvs';

  TextColumn get vhvId => text()();
  TextColumn get vhvCitizenId => text()();
  TextColumn get vhvTitle => text()();
  TextColumn get vhvFname => text()();
  TextColumn get vhvLname => text()();
  TextColumn get vhvMobile => text()();
  TextColumn get vhvEmail => text()();
  TextColumn get vhvPassword => text()();
  DateTimeColumn get vhvBirthDate => dateTime()();
  TextColumn get vhvGender => text()();
  TextColumn get vhvAddress => text()();
  TextColumn get vhvImg => text().nullable()();
  TextColumn get villageId => text()();

  @override
  Set<Column> get primaryKey => {vhvId};
}

class PatientsTable extends Table {
  @override
  String get tableName => 'patients';

  TextColumn get patientId => text()();
  TextColumn get patientCitizenId => text()();
  TextColumn get patientTitle => text()();
  TextColumn get patientFname => text()();
  TextColumn get patientLname => text()();
  TextColumn get patientGender => text()();
  DateTimeColumn get patientBirthDate => dateTime()();
  TextColumn get patientAddress => text()();
  TextColumn get patientMobile =>
      text().withDefault(const Constant(''))();
  TextColumn get patientImg => text().nullable()();
  TextColumn get villageId => text()();

  @override
  Set<Column> get primaryKey => {patientId};
}

class ScreeningsTable extends Table {
  @override
  String get tableName => 'screenings';

  TextColumn get screenId => text()();
  TextColumn get patientId => text()();
  TextColumn get vhvId => text()();
  DateTimeColumn get screeningDate => dateTime()();
  IntColumn get ageAtScreening => integer()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get reviewStatus =>
      text().withDefault(const Constant('PENDING'))();
  TextColumn get reviewedByNurseId => text().nullable()();
  DateTimeColumn get reviewedAt => dateTime().nullable()();

  // Biometrics
  RealColumn get weight => real()();
  RealColumn get height => real()();
  RealColumn get bmi => real()();
  RealColumn get waistCm => real()();
  RealColumn get sbp => real()();
  RealColumn get dbp => real()();
  RealColumn get pulse => real()();
  RealColumn get bloodSugar => real().nullable()();

  @override
  Set<Column> get primaryKey => {screenId};
}

class ScreeningHistoriesTable extends Table {
  @override
  String get tableName => 'screening_histories';

  TextColumn get historyId => text()();
  TextColumn get screeningId => text()();
  TextColumn get questionId => text()();
  TextColumn get questionText => text()();
  RealColumn get answerValue => real().nullable()();
  TextColumn get answerText => text()();

  @override
  Set<Column> get primaryKey => {historyId};
}

class ScreeningResultsTable extends Table {
  @override
  String get tableName => 'screening_results';

  TextColumn get resultId => text()();
  TextColumn get screeningId => text()();
  TextColumn get diseaseName => text()();
  TextColumn get diseaseCode => text()();
  IntColumn get score => integer()();
  TextColumn get riskLevel => text()();
  TextColumn get adviceText => text()();
  TextColumn get criteriaText =>
      text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {resultId};
}

/// Durable offline outbox. Rows are kept until a backend confirms receipt.
class SyncQueueTable extends Table {
  @override
  String get tableName => 'sync_queue';

  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();
  TextColumn get payload => text()(); // JSON
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get errorMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Auto-saved, unsubmitted screening form input (one per patient + VHV).
class ScreeningDraftsTable extends Table {
  @override
  String get tableName => 'screening_drafts';

  TextColumn get patientId => text()();
  TextColumn get vhvId => text()();
  TextColumn get payload => text()(); // JSON of form fields
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {patientId, vhvId};
}
