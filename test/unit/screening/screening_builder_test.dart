import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/screening_builder.dart';
import 'package:ncd_screening_mobile/domain/services/screening_validator.dart';

final _patient = Patient(
  patientId: 'P1',
  patientCitizenId: '1234567890121',
  patientTitle: 'นาย',
  patientFname: 'สมชาย',
  patientLname: 'ใจดี',
  patientGender: 'ชาย',
  patientBirthDate: DateTime(1970, 1, 1),
  patientAddress: '1',
  villageId: 'V1',
);

final _vhv = VHV(
  vhvId: 'VHV1',
  vhvCitizenId: '1111111111119',
  vhvTitle: 'นาง',
  vhvFname: 'อสม',
  vhvLname: 'ทดสอบ',
  vhvMobile: '0',
  vhvEmail: 'a@b.c',
  vhvPassword: 'x',
  vhvBirthDate: DateTime(1980, 1, 1),
  vhvGender: 'หญิง',
  vhvAddress: '-',
  villageId: 'V1',
);

ScreeningMeasurements _m({double? sugar}) => ScreeningMeasurements(
      weight: 60,
      height: 165,
      waist: 80,
      sbp: 120,
      dbp: 80,
      pulse: 72,
      bloodSugar: sugar,
    );

const _answers = ScreeningAnswers(
  personalNcd: 'ไม่มี',
  drugAllergy: 'ไม่ทราบ',
  foodAllergy: 'ไม่ทราบ',
  familyNcd: 'ไม่มี',
);

void main() {
  test('copies measurements, ids and patient/VHV into the screening', () {
    final s = ScreeningBuilder.build(
      measurements: _m(sugar: 95),
      answers: _answers,
      patient: _patient,
      vhv: _vhv,
      screeningId: 'S-1',
      now: DateTime(2026, 11, 13),
    );
    expect(s.screenId, 'S-1');
    expect(s.patientId, 'P1');
    expect(s.vhvId, 'VHV1');
    expect(s.bloodSugar, 95);
    expect(s.bmi, closeTo(22.0, 0.1));
    expect(s.screeningDate, DateTime(2026, 11, 13));
    expect(s.reviewStatus, ReviewStatus.pending);
  });

  test('creates four history answers keyed to the screening id', () {
    final s = ScreeningBuilder.build(
      measurements: _m(),
      answers: _answers,
      patient: _patient,
      vhv: _vhv,
      screeningId: 'S-1',
    );
    expect(s.histories.map((h) => h.historyId),
        ['S-1_H1', 'S-1_H2', 'S-1_H3', 'S-1_H4']);
    expect(s.histories.map((h) => h.questionId),
        ['Q001', 'Q002', 'Q003', 'Q004']);
  });

  test('Q1 "มี" records the selected diseases in the answer text', () {
    final s = ScreeningBuilder.build(
      measurements: _m(),
      answers: const ScreeningAnswers(
        personalNcd: 'มี',
        personalNcdDiseases: ['โรคเบาหวาน', 'โรคความดันโลหิตสูง'],
        drugAllergy: 'ไม่มี',
        foodAllergy: 'ไม่มี',
        familyNcd: 'ไม่มี',
      ),
      patient: _patient,
      vhv: _vhv,
    );
    expect(s.histories.first.answerText,
        'มี (โรคเบาหวาน, โรคความดันโลหิตสูง)');
  });

  test('without blood sugar the diabetes result is incomplete', () {
    final s = ScreeningBuilder.build(
      measurements: _m(),
      answers: _answers,
      patient: _patient,
      vhv: _vhv,
    );
    expect(s.bloodSugar, isNull);
    expect(
      s.results.firstWhere((r) => r.diseaseCode == 'DIABETES').isIncomplete,
      isTrue,
    );
  });

  test('family and personal NCD answers feed the risk assessment', () {
    final withHistory = ScreeningBuilder.build(
      measurements: _m(sugar: 90),
      answers: const ScreeningAnswers(
        personalNcd: 'มี',
        personalNcdDiseases: ['โรคเบาหวาน'],
        drugAllergy: 'ไม่ทราบ',
        foodAllergy: 'ไม่ทราบ',
        familyNcd: 'มี',
      ),
      patient: _patient,
      vhv: _vhv,
    );
    final dm = withHistory.results.firstWhere((r) => r.diseaseCode == 'DIABETES');
    expect(dm.riskLevel, RiskLevel.high, reason: 'known diabetes history');
  });

  test('generates a fresh id each time when none is given', () {
    final a = ScreeningBuilder.build(
        measurements: _m(), answers: _answers, patient: _patient, vhv: _vhv);
    final b = ScreeningBuilder.build(
        measurements: _m(), answers: _answers, patient: _patient, vhv: _vhv);
    expect(a.screenId, isNot(b.screenId));
  });
}
