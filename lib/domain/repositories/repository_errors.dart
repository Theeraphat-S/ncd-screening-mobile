/// Errors repositories throw for expected, user-correctable problems. Each
/// carries the Thai message to show; `toString()` returns it unchanged so
/// existing `e.toString()` call sites keep working.
abstract class RepositoryError implements Exception {
  final String message;
  const RepositoryError(this.message);

  @override
  String toString() => message;
}

/// Unknown user or wrong password / birth date. These, and only these, count
/// as failed sign-in attempts.
class InvalidCredentialsException extends RepositoryError {
  const InvalidCredentialsException(super.message);
}

/// Another patient already uses this citizen ID.
class DuplicateCitizenIdException extends RepositoryError {
  const DuplicateCitizenIdException()
      : super('เลขบัตรประชาชนนี้มีอยู่ในระบบแล้ว กรุณาค้นหาผู้ป่วยเดิมแทนการเพิ่มใหม่');
}

/// The record breaks a data rule (range, format, check digit).
class InvalidRecordException extends RepositoryError {
  const InvalidRecordException(super.message);
}
