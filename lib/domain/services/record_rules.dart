import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/repository_errors.dart';
import 'package:ncd_screening_mobile/domain/services/citizen_id.dart';
import 'package:ncd_screening_mobile/domain/services/screening_validator.dart';

/// Data rules every repository applies before writing, so a record that
/// skipped the form (another screen, a future sync import, a bug) cannot be
/// stored. The forms show the same rules earlier, field by field.
class RecordRules {
  RecordRules._();

  static const invalidCitizenIdMessage =
      'เลขบัตรประชาชนไม่ถูกต้อง กรุณาตรวจสอบตัวเลขอีกครั้ง';

  /// The citizen ID as it is stored: surrounding spaces removed.
  static String normalizeCitizenId(String id) => id.trim();

  /// Throws [InvalidRecordException] if [patient]'s citizen ID fails the
  /// format or check digit. On an edit, pass the stored ID as
  /// [previousCitizenId]: an unchanged ID is accepted as it is, so records
  /// entered before the check existed can still be edited.
  static void checkPatient(Patient patient, {String? previousCitizenId}) {
    final id = normalizeCitizenId(patient.patientCitizenId);
    if (previousCitizenId != null &&
        id == normalizeCitizenId(previousCitizenId)) {
      return;
    }
    if (!CitizenId.isValid(id)) {
      throw const InvalidRecordException(invalidCitizenIdMessage);
    }
  }

  /// Throws [InvalidRecordException] with the first problem if [screening]'s
  /// measurements are outside what [ScreeningValidator] accepts.
  static void checkScreening(Screening screening) {
    final result = ScreeningValidator.validate(screeningInputOf(screening));
    if (result.isValid) return;
    final first = ScreeningField.values.firstWhere(result.errors.containsKey);
    throw InvalidRecordException(result.errors[first]!);
  }

  /// The stored values as the validator's text input.
  static ScreeningInput screeningInputOf(Screening s) => ScreeningInput(
    weight: _text(s.weight),
    height: _text(s.height),
    waist: _text(s.waistCm),
    sbp: _text(s.sbp),
    dbp: _text(s.dbp),
    pulse: _text(s.pulse),
    bloodSugar: s.bloodSugar == null ? '' : _text(s.bloodSugar!),
  );

  // NaN / infinity / negatives become text the validator rejects.
  static String _text(double v) => v.isFinite ? v.toString() : 'x';
}
