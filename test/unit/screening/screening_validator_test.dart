import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/services/screening_validator.dart';

ScreeningInput _valid({
  String weight = '60',
  String height = '170',
  String waist = '80',
  String sbp = '120',
  String dbp = '80',
  String pulse = '72',
  String bloodSugar = '95',
}) =>
    ScreeningInput(
      weight: weight,
      height: height,
      waist: waist,
      sbp: sbp,
      dbp: dbp,
      pulse: pulse,
      bloodSugar: bloodSugar,
    );

void main() {
  group('parseNumber', () {
    test('accepts integers, decimals and a Thai-keyboard comma', () {
      expect(ScreeningValidator.parseNumber('72'), 72);
      expect(ScreeningValidator.parseNumber(' 72.5 '), 72.5);
      expect(ScreeningValidator.parseNumber('72,5'), 72.5);
    });

    test('rejects empty, negative, scientific and junk input', () {
      for (final bad in ['', ' ', '-5', '1e3', 'abc', '7 2', '.', '5.', 'NaN']) {
        expect(ScreeningValidator.parseNumber(bad), isNull, reason: bad);
      }
    });
  });

  group('required fields', () {
    test('a fully valid form has no errors', () {
      final result = ScreeningValidator.validate(_valid());
      expect(result.errors, isEmpty);
      expect(result.isValid, isTrue);
    });

    test('every measurement except blood sugar is required', () {
      final result = ScreeningValidator.validate(const ScreeningInput());
      expect(
        result.errors.keys,
        unorderedEquals([
          ScreeningField.weight,
          ScreeningField.height,
          ScreeningField.waist,
          ScreeningField.sbp,
          ScreeningField.dbp,
          ScreeningField.pulse,
        ]),
      );
    });

    test('blood sugar is optional', () {
      final result = ScreeningValidator.validate(_valid(bloodSugar: ''));
      expect(result.isValid, isTrue);
      expect(result.errors.containsKey(ScreeningField.bloodSugar), isFalse);
    });

    test('while typing (lenient) empty fields are not flagged', () {
      final result =
          ScreeningValidator.validate(const ScreeningInput(weight: '70'), lenient: true);
      expect(result.errors, isEmpty);
    });

    test('non-numeric text is an error even in lenient mode', () {
      final result = ScreeningValidator.validate(
        const ScreeningInput(weight: 'abc'),
        lenient: true,
      );
      expect(result.errors[ScreeningField.weight], contains('ตัวเลข'));
    });
  });

  group('ranges', () {
    test('rejects implausible values with a message under the right field', () {
      final cases = <ScreeningField, ScreeningInput>{
        ScreeningField.weight: _valid(weight: '600'),
        ScreeningField.height: _valid(height: '400'),
        ScreeningField.waist: _valid(waist: '5'),
        ScreeningField.sbp: _valid(sbp: '400'),
        ScreeningField.dbp: _valid(dbp: '10'),
        ScreeningField.pulse: _valid(pulse: '500'),
        ScreeningField.bloodSugar: _valid(bloodSugar: '5000'),
      };
      cases.forEach((field, input) {
        final result = ScreeningValidator.validate(input);
        expect(result.errors.containsKey(field), isTrue, reason: '$field');
        expect(result.isValid, isFalse, reason: '$field');
      });
    });

    test('boundary values are accepted', () {
      expect(ScreeningValidator.validate(_valid(weight: '20')).isValid, isTrue);
      expect(ScreeningValidator.validate(_valid(weight: '300')).isValid, isTrue);
      expect(ScreeningValidator.validate(_valid(pulse: '20', sbp: '120')).isValid, isTrue);
    });

    test('height typed in metres is explained', () {
      final result = ScreeningValidator.validate(_valid(height: '1.75'));
      expect(result.errors[ScreeningField.height], contains('เซนติเมตร'));
    });

    test('DBP must be lower than SBP (swapped values)', () {
      final result = ScreeningValidator.validate(_valid(sbp: '80', dbp: '120'));
      expect(result.errors[ScreeningField.dbp], contains('SBP'));
    });
  });

  group('warnings (non-blocking)', () {
    test('normal values produce no warnings', () {
      expect(ScreeningValidator.validate(_valid()).warnings, isEmpty);
    });

    test('very high blood pressure warns but stays valid', () {
      final result = ScreeningValidator.validate(_valid(sbp: '185', dbp: '115'));
      expect(result.isValid, isTrue);
      expect(result.warnings[ScreeningField.sbp], contains('พบแพทย์'));
    });

    test('high diastolic alone also warns', () {
      final result = ScreeningValidator.validate(_valid(sbp: '150', dbp: '112'));
      expect(result.isValid, isTrue);
      expect(result.warnings.keys, anyOf(contains(ScreeningField.sbp), contains(ScreeningField.dbp)));
    });

    test('low blood pressure, abnormal pulse and glucose extremes warn', () {
      expect(
        ScreeningValidator.validate(_valid(sbp: '85', dbp: '55')).warnings,
        contains(ScreeningField.sbp),
      );
      expect(
        ScreeningValidator.validate(_valid(pulse: '130')).warnings,
        contains(ScreeningField.pulse),
      );
      expect(
        ScreeningValidator.validate(_valid(pulse: '45')).warnings,
        contains(ScreeningField.pulse),
      );
      expect(
        ScreeningValidator.validate(_valid(bloodSugar: '300')).warnings,
        contains(ScreeningField.bloodSugar),
      );
      expect(
        ScreeningValidator.validate(_valid(bloodSugar: '55')).warnings,
        contains(ScreeningField.bloodSugar),
      );
    });

    test('an extreme BMI warns on weight so the pair gets re-checked', () {
      final result = ScreeningValidator.validate(_valid(weight: '25', height: '180'));
      expect(result.warnings[ScreeningField.weight], contains('BMI'));
    });

    test('invalid fields do not also produce warnings', () {
      final result = ScreeningValidator.validate(_valid(sbp: '400', dbp: '115'));
      expect(result.warnings.containsKey(ScreeningField.sbp), isFalse);
    });
  });

  group('measurements', () {
    test('parses a valid form, leaving blood sugar null when blank', () {
      final m = ScreeningValidator.parse(_valid(bloodSugar: ''))!;
      expect(m.weight, 60);
      expect(m.height, 170);
      expect(m.sbp, 120);
      expect(m.bloodSugar, isNull);
    });

    test('returns null when the form is invalid', () {
      expect(ScreeningValidator.parse(_valid(sbp: '')), isNull);
    });
  });

  group('live readings', () {
    test('bmi is null until both weight and height are usable', () {
      expect(ScreeningValidator.bmi('', '170'), isNull);
      expect(ScreeningValidator.bmi('60', '0'), isNull);
      expect(ScreeningValidator.bmi('60', '170'), 20.8);
    });

    test('bmi category uses the Asian cut-offs', () {
      expect(ScreeningValidator.bmiCategory(17), 'น้ำหนักต่ำกว่าเกณฑ์');
      expect(ScreeningValidator.bmiCategory(21), 'น้ำหนักปกติ');
      expect(ScreeningValidator.bmiCategory(23.5), 'น้ำหนักเกิน');
      expect(ScreeningValidator.bmiCategory(27), 'อ้วน');
      expect(ScreeningValidator.bmiCategory(31), 'อ้วนมาก');
    });

    test('blood pressure level follows the risk calculator thresholds', () {
      expect(ScreeningValidator.bpLevel(118, 76), BpLevel.normal);
      expect(ScreeningValidator.bpLevel(125, 70), BpLevel.elevated);
      expect(ScreeningValidator.bpLevel(135, 85), BpLevel.elevated);
      expect(ScreeningValidator.bpLevel(140, 80), BpLevel.high);
      expect(ScreeningValidator.bpLevel(120, 90), BpLevel.high);
      expect(ScreeningValidator.bpLevel(180, 100), BpLevel.crisis);
      expect(ScreeningValidator.bpLevel(150, 110), BpLevel.crisis);
      expect(ScreeningValidator.bpLevel(null, 80), isNull);
    });
  });
}
