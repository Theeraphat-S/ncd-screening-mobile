import 'package:ncd_screening_mobile/domain/services/ncd_risk_calculator.dart';

enum ScreeningField { weight, height, waist, sbp, dbp, pulse, bloodSugar }

enum BpLevel { normal, elevated, high, crisis }

/// Raw text as typed by the VHV, one entry per measurement field.
class ScreeningInput {
  final String weight;
  final String height;
  final String waist;
  final String sbp;
  final String dbp;
  final String pulse;
  final String bloodSugar;

  const ScreeningInput({
    this.weight = '',
    this.height = '',
    this.waist = '',
    this.sbp = '',
    this.dbp = '',
    this.pulse = '',
    this.bloodSugar = '',
  });
}

/// Parsed, validated measurements. [bloodSugar] is null when it was not taken.
class ScreeningMeasurements {
  final double weight;
  final double height;
  final double waist;
  final double sbp;
  final double dbp;
  final double pulse;
  final double? bloodSugar;

  const ScreeningMeasurements({
    required this.weight,
    required this.height,
    required this.waist,
    required this.sbp,
    required this.dbp,
    required this.pulse,
    this.bloodSugar,
  });
}

class ScreeningValidation {
  /// Problems that block saving, keyed by the field they belong to.
  final Map<ScreeningField, String> errors;

  /// Suspicious-but-possible values: shown to the user, never block saving.
  final Map<ScreeningField, String> warnings;

  const ScreeningValidation({required this.errors, required this.warnings});

  bool get isValid => errors.isEmpty;
}

class _Range {
  final String label;
  final String unit;
  final double min;
  final double max;
  const _Range(this.label, this.unit, this.min, this.max);
}

/// Pure validation for the screening form, kept out of the widget so the
/// clinical limits are unit-tested.
class ScreeningValidator {
  ScreeningValidator._();

  static const _ranges = <ScreeningField, _Range>{
    ScreeningField.weight: _Range('น้ำหนัก', 'กก.', 20, 300),
    ScreeningField.height: _Range('ส่วนสูง', 'ซม.', 100, 250),
    ScreeningField.waist: _Range('รอบเอว', 'ซม.', 30, 200),
    ScreeningField.sbp: _Range('ความดันตัวบน (SBP)', 'mmHg', 60, 300),
    ScreeningField.dbp: _Range('ความดันตัวล่าง (DBP)', 'mmHg', 30, 200),
    ScreeningField.pulse: _Range('ชีพจร', 'ครั้ง/นาที', 20, 250),
    ScreeningField.bloodSugar: _Range('ระดับน้ำตาลในเลือด', 'mg/dL', 20, 800),
  };

  static final _numberPattern = RegExp(r'^\d+(\.\d+)?$');

  /// Parses typed text; accepts a decimal comma. Returns null if not a plain
  /// non-negative number.
  static double? parseNumber(String raw) {
    final text = raw.trim().replaceAll(',', '.');
    if (!_numberPattern.hasMatch(text)) return null;
    return double.tryParse(text);
  }

  static String _raw(ScreeningInput i, ScreeningField f) => switch (f) {
        ScreeningField.weight => i.weight,
        ScreeningField.height => i.height,
        ScreeningField.waist => i.waist,
        ScreeningField.sbp => i.sbp,
        ScreeningField.dbp => i.dbp,
        ScreeningField.pulse => i.pulse,
        ScreeningField.bloodSugar => i.bloodSugar,
      };

  /// [lenient] is for live feedback while typing: empty fields are not
  /// reported, only values that are present but wrong.
  static ScreeningValidation validate(ScreeningInput input, {bool lenient = false}) {
    final errors = <ScreeningField, String>{};
    final values = <ScreeningField, double>{};

    for (final field in ScreeningField.values) {
      final range = _ranges[field]!;
      final raw = _raw(input, field).trim();

      if (raw.isEmpty) {
        if (field != ScreeningField.bloodSugar && !lenient) {
          errors[field] = 'กรุณากรอก${range.label}';
        }
        continue;
      }

      final value = parseNumber(raw);
      if (value == null) {
        errors[field] = 'กรุณากรอก${range.label}เป็นตัวเลข';
        continue;
      }

      if (field == ScreeningField.height && value < 3) {
        errors[field] = 'ส่วนสูงต้องกรอกเป็นเซนติเมตร (เช่น 160 ไม่ใช่ 1.60)';
        continue;
      }
      if (value < range.min || value > range.max) {
        errors[field] =
            '${range.label}ต้องอยู่ระหว่าง ${_fmt(range.min)}–${_fmt(range.max)} ${range.unit}';
        continue;
      }
      values[field] = value;
    }

    final sbp = values[ScreeningField.sbp];
    final dbp = values[ScreeningField.dbp];
    if (sbp != null && dbp != null && dbp >= sbp) {
      errors[ScreeningField.dbp] = 'DBP ต้องน้อยกว่า SBP (อาจกรอกสลับกัน)';
      values.remove(ScreeningField.dbp);
    }

    return ScreeningValidation(errors: errors, warnings: _warnings(values));
  }

  static Map<ScreeningField, String> _warnings(Map<ScreeningField, double> v) {
    final warnings = <ScreeningField, String>{};
    final sbp = v[ScreeningField.sbp];
    final dbp = v[ScreeningField.dbp];

    if (sbp != null && sbp >= 180) {
      warnings[ScreeningField.sbp] =
          'ความดันสูงมาก (SBP ≥ 180) ควรให้พบแพทย์ทันทีและวัดซ้ำ';
    } else if (dbp != null && dbp >= 110) {
      warnings[ScreeningField.dbp] =
          'ความดันสูงมาก (DBP ≥ 110) ควรให้พบแพทย์ทันทีและวัดซ้ำ';
    } else if (sbp != null && sbp < 90) {
      warnings[ScreeningField.sbp] = 'ความดันตัวบนต่ำ (< 90) ควรวัดซ้ำและสอบถามอาการ';
    }

    final pulse = v[ScreeningField.pulse];
    if (pulse != null && (pulse > 120 || pulse < 50)) {
      warnings[ScreeningField.pulse] = 'ชีพจรผิดปกติ (ปกติ 50–120) ควรวัดซ้ำ';
    }

    final sugar = v[ScreeningField.bloodSugar];
    if (sugar != null) {
      if (sugar >= 250) {
        warnings[ScreeningField.bloodSugar] =
            'น้ำตาลสูงมาก (≥ 250) ควรให้พบแพทย์โดยเร็ว';
      } else if (sugar < 70) {
        warnings[ScreeningField.bloodSugar] =
            'น้ำตาลต่ำ (< 70) ระวังภาวะน้ำตาลต่ำ ควรให้รับประทานอาหาร/น้ำหวาน';
      }
    }

    final w = v[ScreeningField.weight];
    final h = v[ScreeningField.height];
    if (w != null && h != null) {
      final bmi = NcdRiskCalculator.calculateBmi(w, h);
      if (bmi < 16 || bmi >= 40) {
        warnings[ScreeningField.weight] =
            'BMI ผิดปกติมาก ($bmi) ตรวจสอบน้ำหนักและส่วนสูงอีกครั้ง';
      }
    }
    return warnings;
  }

  /// Returns the parsed measurements, or null while the form is not valid.
  static ScreeningMeasurements? parse(ScreeningInput input) {
    if (!validate(input).isValid) return null;
    return ScreeningMeasurements(
      weight: parseNumber(input.weight)!,
      height: parseNumber(input.height)!,
      waist: parseNumber(input.waist)!,
      sbp: parseNumber(input.sbp)!,
      dbp: parseNumber(input.dbp)!,
      pulse: parseNumber(input.pulse)!,
      bloodSugar: parseNumber(input.bloodSugar),
    );
  }

  // ---- live readings -------------------------------------------------

  static double? bmi(String weight, String height) {
    final w = parseNumber(weight);
    final h = parseNumber(height);
    if (w == null || h == null || w <= 0 || h <= 0) return null;
    return NcdRiskCalculator.calculateBmi(w, h);
  }

  /// Asian-Pacific BMI cut-offs (same ones the risk calculator uses).
  static String bmiCategory(double bmi) {
    if (bmi < 18.5) return 'น้ำหนักต่ำกว่าเกณฑ์';
    if (bmi < 23) return 'น้ำหนักปกติ';
    if (bmi < 25) return 'น้ำหนักเกิน';
    if (bmi < 30) return 'อ้วน';
    return 'อ้วนมาก';
  }

  /// Same thresholds as [NcdRiskCalculator]: ≥140/90 high, ≥120/80 elevated.
  static BpLevel? bpLevel(double? sbp, double? dbp) {
    if (sbp == null || dbp == null) return null;
    if (sbp >= 180 || dbp >= 110) return BpLevel.crisis;
    if (sbp >= 140 || dbp >= 90) return BpLevel.high;
    if (sbp >= 120 || dbp >= 80) return BpLevel.elevated;
    return BpLevel.normal;
  }

  static String bpLabel(BpLevel level) => switch (level) {
        BpLevel.normal => 'ความดันปกติ',
        BpLevel.elevated => 'ความดันเริ่มสูง',
        BpLevel.high => 'ความดันสูง',
        BpLevel.crisis => 'ความดันสูงมาก',
      };

  static String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : '$v';
}
