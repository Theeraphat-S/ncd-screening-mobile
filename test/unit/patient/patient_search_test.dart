import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/patient_search.dart';

Patient _p({
  String fname = 'สมชาย',
  String lname = 'ใจดี',
  String cid = '1509900123456',
  String address = '123/4 หมู่ 5 ต.แม่อาย',
}) =>
    Patient(
      patientId: 'P1',
      patientCitizenId: cid,
      patientTitle: 'นาย',
      patientFname: fname,
      patientLname: lname,
      patientGender: 'ชาย',
      patientBirthDate: DateTime(1970, 1, 1),
      patientAddress: address,
      villageId: 'V1',
    );

void main() {
  test('empty query matches everyone', () {
    expect(PatientSearch.matches(_p(), ''), isTrue);
    expect(PatientSearch.matches(_p(), '   '), isTrue);
  });

  test('matches part of the first name or surname', () {
    expect(PatientSearch.matches(_p(), 'สมช'), isTrue);
    expect(PatientSearch.matches(_p(), 'ใจ'), isTrue);
    expect(PatientSearch.matches(_p(), 'มานะ'), isFalse);
  });

  test('matches full name typed with a space between name and surname', () {
    expect(PatientSearch.matches(_p(), 'สมชาย ใจดี'), isTrue);
    expect(PatientSearch.matches(_p(), 'สมชาย ใจร้าย'), isFalse);
  });

  test('matches title + name', () {
    expect(PatientSearch.matches(_p(), 'นายสมชาย'), isTrue);
  });

  test('matches a partial citizen id, with or without dashes', () {
    expect(PatientSearch.matches(_p(), '1509900'), isTrue);
    expect(PatientSearch.matches(_p(), '1-5099-00123-45-6'), isTrue);
    expect(PatientSearch.matches(_p(), '9999'), isFalse);
  });

  test('matches house number in the address', () {
    expect(PatientSearch.matches(_p(), '123/4'), isTrue);
    expect(PatientSearch.matches(_p(), '123'), isTrue);
    expect(PatientSearch.matches(_p(), 'หมู่ 5'), isTrue);
    expect(PatientSearch.matches(_p(), '999'), isFalse);
  });

  test('is case-insensitive for latin text and ignores extra spaces', () {
    final p = _p(fname: 'John', lname: 'Smith');
    expect(PatientSearch.matches(p, '  jOhN   smith '), isTrue);
  });

  test('every word must match something (AND, not OR)', () {
    expect(PatientSearch.matches(_p(), 'สมชาย 999'), isFalse);
  });
}
