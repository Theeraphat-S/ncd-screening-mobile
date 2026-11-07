enum UserRole { patient, vhv, nurse }

enum RiskLevel {
  low('ต่ำ', 'Low'),
  moderate('ปานกลาง', 'Moderate'),
  high('สูง', 'High');

  final String labelTh;
  final String labelEn;

  const RiskLevel(this.labelTh, this.labelEn);

  static RiskLevel fromString(String? val) {
    if (val == null) return RiskLevel.low;
    final lower = val.toLowerCase();
    if (lower.contains('สูง') || lower.contains('high')) return RiskLevel.high;
    if (lower.contains('ปานกลาง') || lower.contains('moderate')) {
      return RiskLevel.moderate;
    }
    return RiskLevel.low;
  }
}

enum ReviewStatus {
  pending('รอพิจารณา', 'PENDING'),
  approved('อนุมัติแล้ว', 'APPROVED');

  final String labelTh;
  final String code;

  const ReviewStatus(this.labelTh, this.code);

  static ReviewStatus fromString(String? val) {
    if (val == null) return ReviewStatus.pending;
    if (val.toUpperCase() == 'APPROVED' || val.contains('อนุมัติ')) {
      return ReviewStatus.approved;
    }
    return ReviewStatus.pending;
  }
}

class Village {
  final String villageId;
  final String villageName;
  final String villageNumber;
  final String subdistrictId;
  final String subdistrictName;
  final String districtName;
  final String provinceName;

  const Village({
    required this.villageId,
    required this.villageName,
    required this.villageNumber,
    this.subdistrictId = 'SD001',
    this.subdistrictName = 'ท่าตอน',
    this.districtName = 'แม่อาย',
    this.provinceName = 'เชียงใหม่',
  });

  String get fullAddress =>
      'หมู่ $villageNumber $villageName ต.$subdistrictName อ.$districtName จ.$provinceName';

  Map<String, dynamic> toMap() => {
    'villageId': villageId,
    'villageName': villageName,
    'villageNumber': villageNumber,
    'subdistrictId': subdistrictId,
    'subdistrictName': subdistrictName,
    'districtName': districtName,
    'provinceName': provinceName,
  };

  factory Village.fromMap(Map<String, dynamic> map) => Village(
    villageId: map['villageId'] ?? '',
    villageName: map['villageName'] ?? '',
    villageNumber: map['villageNumber'] ?? '',
    subdistrictId: map['subdistrictId'] ?? 'SD001',
    subdistrictName: map['subdistrictName'] ?? 'ท่าตอน',
    districtName: map['districtName'] ?? 'แม่อาย',
    provinceName: map['provinceName'] ?? 'เชียงใหม่',
  );
}

class Patient {
  final String patientId;
  final String patientCitizenId;
  final String patientTitle;
  final String patientFname;
  final String patientLname;
  final String patientGender; // ชาย / หญิง
  final DateTime patientBirthDate;
  final String patientAddress;
  final String patientMobile;
  final String? patientImg;
  final String villageId;

  const Patient({
    required this.patientId,
    required this.patientCitizenId,
    required this.patientTitle,
    required this.patientFname,
    required this.patientLname,
    required this.patientGender,
    required this.patientBirthDate,
    required this.patientAddress,
    this.patientMobile = '',
    this.patientImg,
    required this.villageId,
  });

  String get fullName => '$patientTitle$patientFname $patientLname';

  int get age {
    final now = DateTime.now();
    int age = now.year - patientBirthDate.year;
    if (now.month < patientBirthDate.month ||
        (now.month == patientBirthDate.month &&
            now.day < patientBirthDate.day)) {
      age--;
    }
    return age;
  }

  Patient copyWith({
    String? patientId,
    String? patientCitizenId,
    String? patientTitle,
    String? patientFname,
    String? patientLname,
    String? patientGender,
    DateTime? patientBirthDate,
    String? patientAddress,
    String? patientMobile,
    String? patientImg,
    String? villageId,
  }) {
    return Patient(
      patientId: patientId ?? this.patientId,
      patientCitizenId: patientCitizenId ?? this.patientCitizenId,
      patientTitle: patientTitle ?? this.patientTitle,
      patientFname: patientFname ?? this.patientFname,
      patientLname: patientLname ?? this.patientLname,
      patientGender: patientGender ?? this.patientGender,
      patientBirthDate: patientBirthDate ?? this.patientBirthDate,
      patientAddress: patientAddress ?? this.patientAddress,
      patientMobile: patientMobile ?? this.patientMobile,
      patientImg: patientImg ?? this.patientImg,
      villageId: villageId ?? this.villageId,
    );
  }

  Map<String, dynamic> toMap() => {
    'patientId': patientId,
    'patientCitizenId': patientCitizenId,
    'patientTitle': patientTitle,
    'patientFname': patientFname,
    'patientLname': patientLname,
    'patientGender': patientGender,
    'patientBirthDate': patientBirthDate.toIso8601String(),
    'patientAddress': patientAddress,
    'patientMobile': patientMobile,
    'patientImg': patientImg,
    'villageId': villageId,
  };

  factory Patient.fromMap(Map<String, dynamic> map) => Patient(
    patientId: map['patientId'] ?? '',
    patientCitizenId: map['patientCitizenId'] ?? '',
    patientTitle: map['patientTitle'] ?? '',
    patientFname: map['patientFname'] ?? '',
    patientLname: map['patientLname'] ?? '',
    patientGender: map['patientGender'] ?? 'ชาย',
    patientBirthDate:
        DateTime.tryParse(map['patientBirthDate'] ?? '') ??
        DateTime(1980, 1, 1),
    patientAddress: map['patientAddress'] ?? '',
    patientMobile: map['patientMobile'] ?? '',
    patientImg: map['patientImg'],
    villageId: map['villageId'] ?? '',
  );
}

class VHV {
  final String vhvId;
  final String vhvCitizenId;
  final String vhvTitle;
  final String vhvFname;
  final String vhvLname;
  final String vhvMobile;
  final String vhvEmail;
  final String vhvPassword;
  final DateTime vhvBirthDate;
  final String vhvGender;
  final String vhvAddress;
  final String? vhvImg;
  final String villageId;

  const VHV({
    required this.vhvId,
    required this.vhvCitizenId,
    required this.vhvTitle,
    required this.vhvFname,
    required this.vhvLname,
    required this.vhvMobile,
    required this.vhvEmail,
    required this.vhvPassword,
    required this.vhvBirthDate,
    required this.vhvGender,
    required this.vhvAddress,
    this.vhvImg,
    required this.villageId,
  });

  String get fullName => '$vhvTitle$vhvFname $vhvLname';

  VHV copyWith({
    String? vhvId,
    String? vhvCitizenId,
    String? vhvTitle,
    String? vhvFname,
    String? vhvLname,
    String? vhvMobile,
    String? vhvEmail,
    String? vhvPassword,
    DateTime? vhvBirthDate,
    String? vhvGender,
    String? vhvAddress,
    String? vhvImg,
    String? villageId,
  }) {
    return VHV(
      vhvId: vhvId ?? this.vhvId,
      vhvCitizenId: vhvCitizenId ?? this.vhvCitizenId,
      vhvTitle: vhvTitle ?? this.vhvTitle,
      vhvFname: vhvFname ?? this.vhvFname,
      vhvLname: vhvLname ?? this.vhvLname,
      vhvMobile: vhvMobile ?? this.vhvMobile,
      vhvEmail: vhvEmail ?? this.vhvEmail,
      vhvPassword: vhvPassword ?? this.vhvPassword,
      vhvBirthDate: vhvBirthDate ?? this.vhvBirthDate,
      vhvGender: vhvGender ?? this.vhvGender,
      vhvAddress: vhvAddress ?? this.vhvAddress,
      vhvImg: vhvImg ?? this.vhvImg,
      villageId: villageId ?? this.villageId,
    );
  }

  Map<String, dynamic> toMap() => {
    'vhvId': vhvId,
    'vhvCitizenId': vhvCitizenId,
    'vhvTitle': vhvTitle,
    'vhvFname': vhvFname,
    'vhvLname': vhvLname,
    'vhvMobile': vhvMobile,
    'vhvEmail': vhvEmail,
    'vhvPassword': vhvPassword,
    'vhvBirthDate': vhvBirthDate.toIso8601String(),
    'vhvGender': vhvGender,
    'vhvAddress': vhvAddress,
    'vhvImg': vhvImg,
    'villageId': villageId,
  };

  factory VHV.fromMap(Map<String, dynamic> map) => VHV(
    vhvId: map['vhvId'] ?? '',
    vhvCitizenId: map['vhvCitizenId'] ?? '',
    vhvTitle: map['vhvTitle'] ?? '',
    vhvFname: map['vhvFname'] ?? '',
    vhvLname: map['vhvLname'] ?? '',
    vhvMobile: map['vhvMobile'] ?? '',
    vhvEmail: map['vhvEmail'] ?? '',
    vhvPassword: map['vhvPassword'] ?? '',
    vhvBirthDate:
        DateTime.tryParse(map['vhvBirthDate'] ?? '') ?? DateTime(1985, 1, 1),
    vhvGender: map['vhvGender'] ?? 'หญิง',
    vhvAddress: map['vhvAddress'] ?? '',
    vhvImg: map['vhvImg'],
    villageId: map['villageId'] ?? '',
  );
}

class Nurse {
  final String nurseId;
  final String nurseTitle;
  final String nurseFname;
  final String nurseLname;
  final String nurseMobile;
  final String nurseEmail;
  final String nursePassword;
  final String nurseGender;
  final DateTime nurseBirthDate;
  final String? nurseImg;
  final String subdistrictId;

  const Nurse({
    required this.nurseId,
    required this.nurseTitle,
    required this.nurseFname,
    required this.nurseLname,
    required this.nurseMobile,
    required this.nurseEmail,
    required this.nursePassword,
    required this.nurseGender,
    required this.nurseBirthDate,
    this.nurseImg,
    this.subdistrictId = 'SD001',
  });

  String get fullName => '$nurseTitle$nurseFname $nurseLname';

  Map<String, dynamic> toMap() => {
    'nurseId': nurseId,
    'nurseTitle': nurseTitle,
    'nurseFname': nurseFname,
    'nurseLname': nurseLname,
    'nurseMobile': nurseMobile,
    'nurseEmail': nurseEmail,
    'nursePassword': nursePassword,
    'nurseGender': nurseGender,
    'nurseBirthDate': nurseBirthDate.toIso8601String(),
    'nurseImg': nurseImg,
    'subdistrictId': subdistrictId,
  };

  factory Nurse.fromMap(Map<String, dynamic> map) => Nurse(
    nurseId: map['nurseId'] ?? '',
    nurseTitle: map['nurseTitle'] ?? '',
    nurseFname: map['nurseFname'] ?? '',
    nurseLname: map['nurseLname'] ?? '',
    nurseMobile: map['nurseMobile'] ?? '',
    nurseEmail: map['nurseEmail'] ?? '',
    nursePassword: map['nursePassword'] ?? '',
    nurseGender: map['nurseGender'] ?? 'หญิง',
    nurseBirthDate:
        DateTime.tryParse(map['nurseBirthDate'] ?? '') ?? DateTime(1990, 1, 1),
    nurseImg: map['nurseImg'],
    subdistrictId: map['subdistrictId'] ?? 'SD001',
  );
}

class Question {
  final String questionId;
  final String questionCode;
  final String questionText;
  final String unit;

  const Question({
    required this.questionId,
    required this.questionCode,
    required this.questionText,
    required this.unit,
  });

  Map<String, dynamic> toMap() => {
    'questionId': questionId,
    'questionCode': questionCode,
    'questionText': questionText,
    'unit': unit,
  };

  factory Question.fromMap(Map<String, dynamic> map) => Question(
    questionId: map['questionId'] ?? '',
    questionCode: map['questionCode'] ?? '',
    questionText: map['questionText'] ?? '',
    unit: map['unit'] ?? '',
  );
}

class ScreeningHistory {
  final String historyId;
  final String screeningId;
  final String questionId;
  final String questionText;
  final double? answerValue;
  final String answerText;

  const ScreeningHistory({
    required this.historyId,
    required this.screeningId,
    required this.questionId,
    required this.questionText,
    this.answerValue,
    required this.answerText,
  });

  Map<String, dynamic> toMap() => {
    'historyId': historyId,
    'screeningId': screeningId,
    'questionId': questionId,
    'questionText': questionText,
    'answerValue': answerValue,
    'answerText': answerText,
  };

  factory ScreeningHistory.fromMap(Map<String, dynamic> map) =>
      ScreeningHistory(
        historyId: map['historyId'] ?? '',
        screeningId: map['screeningId'] ?? '',
        questionId: map['questionId'] ?? '',
        questionText: map['questionText'] ?? '',
        answerValue: map['answerValue'] != null
            ? (map['answerValue'] as num).toDouble()
            : null,
        answerText: map['answerText'] ?? '',
      );
}

class ScreeningResult {
  final String resultId;
  final String screeningId;
  final String diseaseName;
  final String diseaseCode; // DIABETES, HYPERTENSION, CVD, METABOLIC_OBESITY
  final int score;
  final RiskLevel riskLevel;
  final String adviceText;
  final String criteriaText;

  const ScreeningResult({
    required this.resultId,
    required this.screeningId,
    required this.diseaseName,
    required this.diseaseCode,
    required this.score,
    required this.riskLevel,
    required this.adviceText,
    this.criteriaText = '',
  });

  ScreeningResult copyWith({
    String? resultId,
    String? screeningId,
    String? diseaseName,
    String? diseaseCode,
    int? score,
    RiskLevel? riskLevel,
    String? adviceText,
    String? criteriaText,
  }) {
    return ScreeningResult(
      resultId: resultId ?? this.resultId,
      screeningId: screeningId ?? this.screeningId,
      diseaseName: diseaseName ?? this.diseaseName,
      diseaseCode: diseaseCode ?? this.diseaseCode,
      score: score ?? this.score,
      riskLevel: riskLevel ?? this.riskLevel,
      adviceText: adviceText ?? this.adviceText,
      criteriaText: criteriaText ?? this.criteriaText,
    );
  }

  Map<String, dynamic> toMap() => {
    'resultId': resultId,
    'screeningId': screeningId,
    'diseaseName': diseaseName,
    'diseaseCode': diseaseCode,
    'score': score,
    'riskLevel': riskLevel.name,
    'adviceText': adviceText,
    'criteriaText': criteriaText,
  };

  factory ScreeningResult.fromMap(Map<String, dynamic> map) => ScreeningResult(
    resultId: map['resultId'] ?? '',
    screeningId: map['screeningId'] ?? '',
    diseaseName: map['diseaseName'] ?? '',
    diseaseCode: map['diseaseCode'] ?? '',
    score: map['score'] ?? 0,
    riskLevel: RiskLevel.fromString(map['riskLevel']),
    adviceText: map['adviceText'] ?? '',
    criteriaText: map['criteriaText'] ?? '',
  );
}

class Screening {
  final String screenId;
  final String patientId;
  final String vhvId;
  final DateTime screeningDate;
  final int ageAtScreening;
  final DateTime createdAt;
  final ReviewStatus reviewStatus;
  final String? reviewedByNurseId;
  final DateTime? reviewedAt;

  // Biometrics
  final double weight; // kg
  final double height; // cm
  final double bmi; // kg/m2
  final double waistCm; // cm
  final double sbp; // mmHg
  final double dbp; // mmHg
  final double pulse; // bpm
  final double bloodSugar; // mg/dL

  final List<ScreeningHistory> histories;
  final List<ScreeningResult> results;

  const Screening({
    required this.screenId,
    required this.patientId,
    required this.vhvId,
    required this.screeningDate,
    required this.ageAtScreening,
    required this.createdAt,
    this.reviewStatus = ReviewStatus.pending,
    this.reviewedByNurseId,
    this.reviewedAt,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.waistCm,
    required this.sbp,
    required this.dbp,
    required this.pulse,
    required this.bloodSugar,
    this.histories = const [],
    this.results = const [],
  });

  Screening copyWith({
    String? screenId,
    String? patientId,
    String? vhvId,
    DateTime? screeningDate,
    int? ageAtScreening,
    DateTime? createdAt,
    ReviewStatus? reviewStatus,
    String? reviewedByNurseId,
    DateTime? reviewedAt,
    double? weight,
    double? height,
    double? bmi,
    double? waistCm,
    double? sbp,
    double? dbp,
    double? pulse,
    double? bloodSugar,
    List<ScreeningHistory>? histories,
    List<ScreeningResult>? results,
  }) {
    return Screening(
      screenId: screenId ?? this.screenId,
      patientId: patientId ?? this.patientId,
      vhvId: vhvId ?? this.vhvId,
      screeningDate: screeningDate ?? this.screeningDate,
      ageAtScreening: ageAtScreening ?? this.ageAtScreening,
      createdAt: createdAt ?? this.createdAt,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      reviewedByNurseId: reviewedByNurseId ?? this.reviewedByNurseId,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bmi: bmi ?? this.bmi,
      waistCm: waistCm ?? this.waistCm,
      sbp: sbp ?? this.sbp,
      dbp: dbp ?? this.dbp,
      pulse: pulse ?? this.pulse,
      bloodSugar: bloodSugar ?? this.bloodSugar,
      histories: histories ?? this.histories,
      results: results ?? this.results,
    );
  }

  Map<String, dynamic> toMap() => {
    'screenId': screenId,
    'patientId': patientId,
    'vhvId': vhvId,
    'screeningDate': screeningDate.toIso8601String(),
    'ageAtScreening': ageAtScreening,
    'createdAt': createdAt.toIso8601String(),
    'reviewStatus': reviewStatus.code,
    'reviewedByNurseId': reviewedByNurseId,
    'reviewedAt': reviewedAt?.toIso8601String(),
    'weight': weight,
    'height': height,
    'bmi': bmi,
    'waistCm': waistCm,
    'sbp': sbp,
    'dbp': dbp,
    'pulse': pulse,
    'bloodSugar': bloodSugar,
    'histories': histories.map((x) => x.toMap()).toList(),
    'results': results.map((x) => x.toMap()).toList(),
  };

  factory Screening.fromMap(Map<String, dynamic> map) => Screening(
    screenId: map['screenId'] ?? '',
    patientId: map['patientId'] ?? '',
    vhvId: map['vhvId'] ?? '',
    screeningDate:
        DateTime.tryParse(map['screeningDate'] ?? '') ?? DateTime.now(),
    ageAtScreening: map['ageAtScreening'] ?? 0,
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    reviewStatus: ReviewStatus.fromString(map['reviewStatus']),
    reviewedByNurseId: map['reviewedByNurseId'],
    reviewedAt: map['reviewedAt'] != null
        ? DateTime.tryParse(map['reviewedAt'])
        : null,
    weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
    height: (map['height'] as num?)?.toDouble() ?? 0.0,
    bmi: (map['bmi'] as num?)?.toDouble() ?? 0.0,
    waistCm: (map['waistCm'] as num?)?.toDouble() ?? 0.0,
    sbp: (map['sbp'] as num?)?.toDouble() ?? 0.0,
    dbp: (map['dbp'] as num?)?.toDouble() ?? 0.0,
    pulse: (map['pulse'] as num?)?.toDouble() ?? 0.0,
    bloodSugar: (map['bloodSugar'] as num?)?.toDouble() ?? 0.0,
    histories:
        (map['histories'] as List<dynamic>?)
            ?.map((x) => ScreeningHistory.fromMap(x))
            .toList() ??
        [],
    results:
        (map['results'] as List<dynamic>?)
            ?.map((x) => ScreeningResult.fromMap(x))
            .toList() ??
        [],
  );
}
