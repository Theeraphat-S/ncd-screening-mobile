import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/shared/utils/form_validators.dart';

void main() {
  group('citizenId', () {
    test('asks for the number when empty', () {
      expect(FormValidators.citizenId(''), 'กรุณากรอกเลขบัตรประชาชน');
    });

    test('says how many digits were entered when the length is wrong', () {
      expect(FormValidators.citizenId('12345'), contains('กรอกแล้ว 5 หลัก'));
    });

    test('rejects a wrong check digit, accepts a correct one', () {
      expect(FormValidators.citizenId('1234567890123'), isNotNull);
      expect(FormValidators.citizenId('1234567890121'), isNull);
    });

    test('checkDigit: false only checks the shape', () {
      expect(
        FormValidators.citizenId('1234567890123', checkDigit: false),
        isNull,
      );
    });
  });

  group('personName', () {
    test('the message states the limit the check enforces', () {
      expect(FormValidators.personName('ก', 'ชื่อ'), contains('2 ถึง 100'));
      expect(FormValidators.personName('กร', 'ชื่อ'), isNull);
      expect(FormValidators.personName('ก' * 101, 'ชื่อ'), isNotNull);
    });

    test('empty names the field', () {
      expect(FormValidators.personName('  ', 'นามสกุล'), 'กรุณากรอกนามสกุล');
    });
  });

  group('thaiMobile', () {
    test('accepts 06/08/09 numbers of 10 digits', () {
      for (final n in ['0612345678', '0812345678', '0912345678']) {
        expect(FormValidators.thaiMobile(n), isNull, reason: n);
      }
    });

    test('rejects other prefixes, lengths and letters', () {
      for (final n in ['0212345678', '081234567', '08123456789', '08123x5678']) {
        expect(FormValidators.thaiMobile(n), isNotNull, reason: n);
      }
    });

    test('empty is allowed only when optional', () {
      expect(FormValidators.thaiMobile(''), isNotNull);
      expect(FormValidators.thaiMobile('', optional: true), isNull);
    });
  });

  test('email needs a name, an @ and a domain', () {
    expect(FormValidators.email('vhv01@example.com'), isNull);
    for (final e in ['', 'vhv01', 'vhv01@', '@example.com', 'a@b']) {
      expect(FormValidators.email(e), isNotNull, reason: e);
    }
  });

  test('password is 4-16 characters, blank allowed when optional', () {
    expect(FormValidators.password('abc'), isNotNull);
    expect(FormValidators.password('abcd'), isNull);
    expect(FormValidators.password('a' * 17), isNotNull);
    expect(FormValidators.password(''), isNotNull);
    expect(FormValidators.password('', optional: true), isNull);
  });
}
