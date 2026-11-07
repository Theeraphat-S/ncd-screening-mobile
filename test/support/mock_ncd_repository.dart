// Test-only in-memory repository. Lives under test/ so no plaintext
// credentials or fake data ship in the production library.
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_risk_calculator.dart';

class MockNcdRepository implements NcdRepositoryInterface {
  final List<Village> _villages = [];
  final List<Patient> _patients = [];
  final List<VHV> _vhvs = [];
  final List<Nurse> _nurses = [];
  final List<Screening> _screenings = [];

  MockNcdRepository() {
    _seedData();
  }

  void _seedData() {
    // 1. Villages
    _villages.addAll([
      const Village(
        villageId: 'V001',
        villageName: 'บ้านท่าตอน',
        villageNumber: '1',
      ),
      const Village(
        villageId: 'V002',
        villageName: 'บ้านใหม่หมอกจ๋าม',
        villageNumber: '2',
      ),
      const Village(
        villageId: 'V003',
        villageName: 'บ้านห้วยปู',
        villageNumber: '3',
      ),
      const Village(
        villageId: 'V004',
        villageName: 'บ้านแม่ฮ่าง',
        villageNumber: '4',
      ),
      const Village(
        villageId: 'V005',
        villageName: 'บ้านร่มไทย',
        villageNumber: '5',
      ),
    ]);

    // 2. Nurses
    _nurses.addAll([
      Nurse(
        nurseId: 'NUR001',
        nurseTitle: 'นางพยาบาล',
        nurseFname: 'กานดา',
        nurseLname: 'ใจดี',
        nurseMobile: '0823456789',
        nurseEmail: 'nurse01@example.com',
        nursePassword: 'password123',
        nurseGender: 'หญิง',
        nurseBirthDate: DateTime(1990, 10, 15),
      ),
    ]);

    // 3. VHVs
    _vhvs.addAll([
      VHV(
        vhvId: 'VHV001',
        vhvCitizenId: '1111111111111',
        vhvTitle: 'นาย',
        vhvFname: 'อสม',
        vhvLname: 'ตัวอย่าง1',
        vhvMobile: '0800000001',
        vhvEmail: 'vhv001@example.com',
        vhvPassword: 'password123',
        vhvBirthDate: DateTime(1995, 5, 20),
        vhvGender: 'ชาย',
        vhvAddress: 'เลขที่ 60 หมู่ 1 บ้านท่าตอน ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่',
        villageId: 'V001',
      ),
      VHV(
        vhvId: 'VHV002',
        vhvCitizenId: '0647700893123',
        vhvTitle: 'นาง',
        vhvFname: 'สมใจ',
        vhvLname: 'จิตอาสา',
        vhvMobile: '0647700893',
        vhvEmail: 'somjai@example.com',
        vhvPassword: 'password123',
        vhvBirthDate: DateTime(1988, 3, 12),
        vhvGender: 'หญิง',
        vhvAddress: 'หมู่ 1 บ้านท่าตอน อ.แม่อาย',
        villageId: 'V001',
      ),
      VHV(
        vhvId: 'VHV003',
        vhvCitizenId: '0812345678123',
        vhvTitle: 'นาย',
        vhvFname: 'มานะ',
        vhvLname: 'ช่วยหมู่บ้าน',
        vhvMobile: '0812345678',
        vhvEmail: 'mana@example.com',
        vhvPassword: 'password123',
        vhvBirthDate: DateTime(1982, 8, 25),
        vhvGender: 'ชาย',
        vhvAddress: 'หมู่ 1 บ้านท่าตอน อ.แม่อาย',
        villageId: 'V001',
      ),
    ]);

    // 4. Patients
    _patients.addAll([
      Patient(
        patientId: 'P001',
        patientCitizenId: '1234567890123',
        patientTitle: 'นาย',
        patientFname: 'สมชาย',
        patientLname: 'ใจดี',
        patientGender: 'ชาย',
        patientBirthDate: DateTime(1980, 2, 1),
        patientAddress: '60 หมู่ 1 บ้านตัวอย่าง ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่',
        patientMobile: '0891234567',
        villageId: 'V001',
      ),
      Patient(
        patientId: 'P002',
        patientCitizenId: '2222222222222',
        patientTitle: 'นาย',
        patientFname: 'ว่าน',
        patientLname: 'ตัวอย่าง',
        patientGender: 'ชาย',
        patientBirthDate: DateTime(1996, 4, 15),
        patientAddress: '15 หมู่ 1 บ้านท่าตอน ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่',
        patientMobile: '0812222222',
        villageId: 'V001',
      ),
      Patient(
        patientId: 'P003',
        patientCitizenId: '3250184930571',
        patientTitle: 'นาง',
        patientFname: 'สมศรี',
        patientLname: 'มีสุข',
        patientGender: 'หญิง',
        patientBirthDate: DateTime(1975, 7, 20),
        patientAddress: '42 หมู่ 1 บ้านท่าตอน ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่',
        patientMobile: '0834567890',
        villageId: 'V001',
      ),
      Patient(
        patientId: 'P004',
        patientCitizenId: '1459900234889',
        patientTitle: 'นาย',
        patientFname: 'มั่นคง',
        patientLname: 'ทรหด',
        patientGender: 'ชาย',
        patientBirthDate: DateTime(1989, 10, 5),
        patientAddress: '78 หมู่ 1 บ้านท่าตอน ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่',
        patientMobile: '0867891234',
        villageId: 'V001',
      ),
      Patient(
        patientId: 'P005',
        patientCitizenId: '2304055671004',
        patientTitle: 'นาง',
        patientFname: 'วิไล',
        patientLname: 'งามตา',
        patientGender: 'หญิง',
        patientBirthDate: DateTime(1986, 3, 14),
        patientAddress: '23 หมู่ 1 บ้านท่าตอน ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่',
        patientMobile: '0878901234',
        villageId: 'V001',
      ),
      Patient(
        patientId: 'P006',
        patientCitizenId: '3102299845662',
        patientTitle: 'นาย',
        patientFname: 'ศักดิ์ดา',
        patientLname: 'กล้าหาญ',
        patientGender: 'ชาย',
        patientBirthDate: DateTime(1966, 6, 8),
        patientAddress: '55 หมู่ 1 บ้านท่าตอน ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่',
        patientMobile: '0890123456',
        villageId: 'V001',
      ),
    ]);

    // 5. Seed initial Screenings
    final initialResults = NcdRiskCalculator.evaluateRisk(
      screeningId: 'S001',
      weight: 60,
      height: 175,
      bmi: 19.6,
      waistCm: 72,
      sbp: 125,
      dbp: 65,
      pulse: 72,
      bloodSugar: 100,
      gender: 'ชาย',
      hasPersonalNcd: true,
      personalNcdDetail: 'เบาหวาน',
    );

    final initialHistories = [
      const ScreeningHistory(
        historyId: 'H001',
        screeningId: 'S001',
        questionId: 'Q001',
        questionText: '1) ประวัติป่วย/พบแพทย์ด้วยโรค NCDs',
        answerText: 'มี (เบาหวาน)',
      ),
      const ScreeningHistory(
        historyId: 'H002',
        screeningId: 'S001',
        questionId: 'Q002',
        questionText: '2) ประวัติแพ้ยา',
        answerText: 'มี (ยาชา)',
      ),
      const ScreeningHistory(
        historyId: 'H003',
        screeningId: 'S001',
        questionId: 'Q003',
        questionText: '3) ประวัติแพ้อาหาร',
        answerText: 'ไม่ทราบ',
      ),
      const ScreeningHistory(
        historyId: 'H004',
        screeningId: 'S001',
        questionId: 'Q004',
        questionText: '4) ญาติตรงสาย (พ่อ/แม่/พี่/น้อง) ป่วยเป็นโรค NCDs',
        answerText: 'ไม่ทราบ',
      ),
    ];

    _screenings.addAll([
      Screening(
        screenId: 'S001',
        patientId: 'P001',
        vhvId: 'VHV001',
        screeningDate: DateTime(2026, 2, 7, 10, 55),
        ageAtScreening: 46,
        createdAt: DateTime(2026, 2, 7, 10, 55),
        reviewStatus: ReviewStatus.pending,
        weight: 60,
        height: 175,
        bmi: 19.6,
        waistCm: 72,
        sbp: 125,
        dbp: 65,
        pulse: 72,
        bloodSugar: 100,
        histories: initialHistories,
        results: initialResults,
      ),
      Screening(
        screenId: 'S002',
        patientId: 'P001',
        vhvId: 'VHV001',
        screeningDate: DateTime(2026, 2, 11, 14, 22),
        ageAtScreening: 46,
        createdAt: DateTime(2026, 2, 11, 14, 22),
        reviewStatus: ReviewStatus.pending,
        weight: 60,
        height: 175,
        bmi: 19.6,
        waistCm: 72,
        sbp: 120,
        dbp: 75,
        pulse: 70,
        bloodSugar: 98,
        histories: initialHistories,
        results: NcdRiskCalculator.evaluateRisk(
          screeningId: 'S002',
          weight: 60,
          height: 175,
          bmi: 19.6,
          waistCm: 72,
          sbp: 120,
          dbp: 75,
          pulse: 70,
          bloodSugar: 98,
          gender: 'ชาย',
        ),
      ),
    ]);
  }

  @override
  Future<dynamic> login({
    required UserRole role,
    required String identifier,
    String? password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final trimmedId = identifier.trim();
    if (role == UserRole.patient) {
      final patient = _patients.firstWhere(
        (p) => p.patientCitizenId == trimmedId,
        orElse: () => throw Exception('รหัสบัตรประชาชนไม่ถูกต้อง'),
      );
      return patient;
    } else if (role == UserRole.vhv) {
      final vhv = _vhvs.firstWhere(
        (v) =>
            v.vhvCitizenId == trimmedId ||
            v.vhvMobile == trimmedId ||
            v.vhvId == trimmedId,
        orElse: () => throw Exception('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง'),
      );
      if (password != null &&
          password.isNotEmpty &&
          vhv.vhvPassword != password) {
        throw Exception('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง');
      }
      return vhv;
    } else if (role == UserRole.nurse) {
      final nurse = _nurses.firstWhere(
        (n) =>
            n.nurseId == trimmedId ||
            n.nurseMobile == trimmedId ||
            n.nurseEmail == trimmedId,
        orElse: () => throw Exception('รหัสพยาบาลหรือรหัสผ่านไม่ถูกต้อง'),
      );
      if (password != null &&
          password.isNotEmpty &&
          nurse.nursePassword != password) {
        throw Exception('รหัสพยาบาลหรือรหัสผ่านไม่ถูกต้อง');
      }
      return nurse;
    }
    throw Exception('ไม่พบบทบาทผู้ใช้');
  }

  @override
  Future<List<Village>> getVillages() async {
    return List.unmodifiable(_villages);
  }

  @override
  Future<Village?> getVillageById(String villageId) async {
    try {
      return _villages.firstWhere((v) => v.villageId == villageId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Patient>> getPatients({
    String? villageId,
    String? searchQuery,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var list = _patients.toList();
    if (villageId != null && villageId.isNotEmpty) {
      list = list.where((p) => p.villageId == villageId).toList();
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((p) {
        return p.patientCitizenId.contains(q) ||
            p.patientFname.toLowerCase().contains(q) ||
            p.patientLname.toLowerCase().contains(q) ||
            p.fullName.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  @override
  Future<Patient?> getPatientById(String patientId) async {
    try {
      return _patients.firstWhere((p) => p.patientId == patientId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Patient?> getPatientByCitizenId(String citizenId) async {
    try {
      return _patients.firstWhere(
        (p) => p.patientCitizenId == citizenId.trim(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Patient> addPatient(Patient patient) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final newId = 'P${(_patients.length + 1).toString().padLeft(3, '0')}';
    final created = patient.copyWith(patientId: newId);
    _patients.insert(0, created);
    return created;
  }

  @override
  Future<Patient> updatePatient(Patient patient) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _patients.indexWhere((p) => p.patientId == patient.patientId);
    if (index >= 0) {
      _patients[index] = patient;
      return patient;
    }
    throw Exception('แก้ไขผู้ป่วย ไม่สำเร็จ');
  }

  @override
  Future<bool> deletePatient(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final initialCount = _patients.length;
    _patients.removeWhere((p) => p.patientId == patientId);
    return _patients.length < initialCount;
  }

  @override
  Future<List<VHV>> getVhvs({String? villageId}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (villageId != null && villageId.isNotEmpty) {
      return _vhvs.where((v) => v.villageId == villageId).toList();
    }
    return List.unmodifiable(_vhvs);
  }

  @override
  Future<VHV?> getVhvById(String vhvId) async {
    try {
      return _vhvs.firstWhere((v) => v.vhvId == vhvId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<VHV> addVhv(VHV vhv) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final newId = 'VHV${(_vhvs.length + 1).toString().padLeft(3, '0')}';
    final created = vhv.copyWith(vhvId: newId);
    _vhvs.insert(0, created);
    return created;
  }

  @override
  Future<VHV> updateVhv(VHV vhv) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _vhvs.indexWhere((v) => v.vhvId == vhv.vhvId);
    if (index >= 0) {
      _vhvs[index] = vhv;
      return vhv;
    }
    throw Exception('แก้ไขอสม ไม่สำเร็จ');
  }

  @override
  Future<bool> verifyNursePassword({
    required String nurseId,
    required String password,
  }) async {
    if (password.isEmpty) return false;
    final nurse = _nurses.where((n) => n.nurseId == nurseId).firstOrNull;
    return nurse != null && nurse.nursePassword == password;
  }

  @override
  Future<Nurse?> getNurseById(String nurseId) async {
    try {
      return _nurses.firstWhere((n) => n.nurseId == nurseId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Screening>> getScreeningsByPatient(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _screenings.where((s) => s.patientId == patientId).toList()
      ..sort((a, b) => b.screeningDate.compareTo(a.screeningDate));
  }

  @override
  Future<List<Screening>> getAllScreenings({String? villageId}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (villageId != null && villageId.isNotEmpty) {
      final patientIdsInVillage = _patients
          .where((p) => p.villageId == villageId)
          .map((p) => p.patientId)
          .toSet();
      return _screenings
          .where((s) => patientIdsInVillage.contains(s.patientId))
          .toList()
        ..sort((a, b) => b.screeningDate.compareTo(a.screeningDate));
    }
    return _screenings.toList()
      ..sort((a, b) => b.screeningDate.compareTo(a.screeningDate));
  }

  @override
  Future<Screening?> getScreeningById(String screeningId) async {
    try {
      return _screenings.firstWhere((s) => s.screenId == screeningId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Screening> saveScreening(Screening screening) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newId = 'S${(_screenings.length + 1).toString().padLeft(3, '0')}';
    final created = screening.copyWith(screenId: newId);
    _screenings.insert(0, created);
    return created;
  }

  @override
  Future<Screening> updateScreeningReview({
    required String screeningId,
    required ReviewStatus status,
    required String nurseId,
    List<ScreeningResult>? updatedResults,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _screenings.indexWhere((s) => s.screenId == screeningId);
    if (index >= 0) {
      final existing = _screenings[index];
      final updated = existing.copyWith(
        reviewStatus: status,
        reviewedByNurseId: nurseId,
        reviewedAt: DateTime.now(),
        results: updatedResults ?? existing.results,
      );
      _screenings[index] = updated;
      return updated;
    }
    throw Exception('บันทึกผลประเมิน ไม่สำเร็จ');
  }
}
