import 'package:equatable/equatable.dart';

/// Parsed result from Thai National ID Card OCR text.
class IdCardOcrResult extends Equatable {
  final String? citizenId;
  final String? prefix;
  final String? firstName;
  final String? lastName;
  final String? dateOfBirth;
  final String rawText;

  const IdCardOcrResult({
    this.citizenId,
    this.prefix,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    required this.rawText,
  });

  bool get hasValidCitizenId => citizenId != null && citizenId!.length == 13;

  String get fullName {
    final parts = [
      if (prefix != null && prefix!.isNotEmpty) prefix!,
      if (firstName != null && firstName!.isNotEmpty) firstName!,
      if (lastName != null && lastName!.isNotEmpty) lastName!,
    ];
    return parts.join(' ');
  }

  @override
  List<Object?> get props => [
    citizenId,
    prefix,
    firstName,
    lastName,
    dateOfBirth,
    rawText,
  ];
}

/// On-device regex-based parser for Thai National ID card text.
class IdCardOcrParser {
  // Regex matching Thai 13-digit citizen ID format with optional spaces/hyphens
  static final RegExp _citizenIdRegex = RegExp(
    r'(?:เลขประจำตัวประชาชน|Identification Number|ID)?\s*([0-9][\s\-]?[0-9]{4}[\s\-]?[0-9]{5}[\s\-]?[0-9]{2}[\s\-]?[0-9])',
    caseSensitive: false,
  );

  static final RegExp _digitsOnly13 = RegExp(r'\b\d{13}\b');

  // Thai Name matching (e.g. ชื่อ นาย สมชาย นามสกุล ใจดี or Name Mr. Somchai)
  static final RegExp _thaiNameWithPrefixRegex = RegExp(
    r'(?:ชื่อ\s*)?(นาย|นาง|นางสาว|ด\.ช\.|ด\.ญ\.|นายแพทย์|แพทย์หญิง)\s+([ก-๙]+)\s+([ก-๙]+)',
  );

  static final RegExp _englishNameRegex = RegExp(
    r'(?:Name|Mr\.|Mrs\.|Miss)\s+([A-Za-z]+)\s+([A-Za-z]+)',
    caseSensitive: false,
  );

  /// Parse raw extracted OCR text into structured `IdCardOcrResult`.
  static IdCardOcrResult parse(String rawText) {
    if (rawText.trim().isEmpty) {
      return const IdCardOcrResult(rawText: '');
    }

    String? citizenId;
    String? prefix;
    String? firstName;
    String? lastName;
    String? dateOfBirth;

    // 1. Extract 13-digit Citizen ID
    final matchId = _citizenIdRegex.firstMatch(rawText);
    if (matchId != null && matchId.groupCount >= 1) {
      final rawDigits = matchId.group(1)!.replaceAll(RegExp(r'[\s\-]'), '');
      if (rawDigits.length == 13) {
        citizenId = rawDigits;
      }
    }

    if (citizenId == null) {
      final standaloneMatch = _digitsOnly13.firstMatch(
        rawText.replaceAll('-', ' '),
      );
      if (standaloneMatch != null) {
        citizenId = standaloneMatch.group(0);
      }
    }

    // 2. Extract Thai Name & Prefix
    final nameMatch = _thaiNameWithPrefixRegex.firstMatch(rawText);
    if (nameMatch != null && nameMatch.groupCount >= 3) {
      prefix = nameMatch.group(1);
      firstName = nameMatch.group(2);
      lastName = nameMatch.group(3);
    } else {
      // Try fallback english name
      final enNameMatch = _englishNameRegex.firstMatch(rawText);
      if (enNameMatch != null && enNameMatch.groupCount >= 2) {
        firstName = enNameMatch.group(1);
        lastName = enNameMatch.group(2);
      }
    }

    // 3. Extract DOB if present (e.g. เกิดวันที่ 15 ม.ค. 2505 or 15 Jan 1962)
    final dobMatch = RegExp(
      r'(?:เกิดวันที่|Date of Birth)\s*([0-9]{1,2}\s+[^\n0-9]+\s+[0-9]{4})',
    ).firstMatch(rawText);
    if (dobMatch != null && dobMatch.groupCount >= 1) {
      dateOfBirth = dobMatch.group(1)!.trim();
    }

    return IdCardOcrResult(
      citizenId: citizenId,
      prefix: prefix,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      rawText: rawText,
    );
  }
}
