import 'package:ncd_screening_mobile/domain/services/citizen_id.dart';

/// Field validators shared by the forms. Each returns the Thai message to
/// show under the field, or null when the value is acceptable. Messages say
/// what to fix, not only that something is wrong.
class FormValidators {
  FormValidators._();

  static final RegExp _digits = RegExp(r'^\d+$');
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? required(String? value, String message) =>
      (value == null || value.trim().isEmpty) ? message : null;

  /// 13 digits; [checkDigit] also verifies the Thai ID checksum.
  static String? citizenId(String? value, {bool checkDigit = true}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'กรุณากรอกเลขบัตรประชาชน';
    if (v.length != 13 || !_digits.hasMatch(v)) {
      return 'เลขบัตรประชาชนต้องเป็นตัวเลข 13 หลัก (กรอกแล้ว ${v.length} หลัก)';
    }
    if (checkDigit && !CitizenId.isValid(v)) {
      return 'เลขบัตรประชาชนไม่ถูกต้อง กรุณาตรวจสอบตัวเลขอีกครั้ง';
    }
    return null;
  }

  static String? personName(String? value, String fieldName) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'กรุณากรอก$fieldName';
    if (v.length < 2 || v.length > 100) {
      return '$fieldNameต้องมีความยาว 2 ถึง 100 ตัวอักษร';
    }
    return null;
  }

  /// Thai mobile number: 10 digits starting with 06, 08 or 09.
  static String? thaiMobile(String? value, {bool optional = false}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return optional ? null : 'กรุณากรอกเบอร์มือถือ';
    final prefixOk =
        v.startsWith('06') || v.startsWith('08') || v.startsWith('09');
    if (v.length != 10 || !_digits.hasMatch(v) || !prefixOk) {
      return 'เบอร์มือถือต้องเป็นตัวเลข 10 หลัก ขึ้นต้นด้วย 06, 08 หรือ 09';
    }
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'กรุณากรอกอีเมล';
    if (!_email.hasMatch(v)) return 'รูปแบบอีเมลไม่ถูกต้อง เช่น name@example.com';
    return null;
  }

  static String? password(String? value, {bool optional = false}) {
    final v = value ?? '';
    if (v.isEmpty) return optional ? null : 'กรุณากรอกรหัสผ่าน';
    if (v.length < 4 || v.length > 16) {
      return 'รหัสผ่านต้องมีความยาว 4-16 ตัวอักษร';
    }
    return null;
  }
}
