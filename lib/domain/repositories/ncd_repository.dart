import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';

abstract class NcdRepositoryInterface {
  // Session & Auth
  Future<dynamic> login({
    required UserRole role,
    required String identifier,
    String? password,
  });

  // Villages
  Future<List<Village>> getVillages();
  Future<Village?> getVillageById(String villageId);

  // Patients
  Future<List<Patient>> getPatients({String? villageId, String? searchQuery});
  Future<Patient?> getPatientById(String patientId);
  Future<Patient?> getPatientByCitizenId(String citizenId);
  Future<Patient> addPatient(Patient patient);
  Future<Patient> updatePatient(Patient patient);
  Future<bool> deletePatient(String patientId);

  // VHV
  Future<List<VHV>> getVhvs({String? villageId});
  Future<VHV?> getVhvById(String vhvId);
  Future<VHV> addVhv(VHV vhv);
  Future<VHV> updateVhv(VHV vhv);

  // Nurse
  Future<Nurse?> getNurseById(String nurseId);
  Future<bool> verifyNursePassword({
    required String nurseId,
    required String password,
  });

  // Screenings
  Future<List<Screening>> getScreeningsByPatient(String patientId);
  Future<List<Screening>> getAllScreenings({String? villageId});
  Future<Screening?> getScreeningById(String screeningId);
  Future<Screening> saveScreening(Screening screening);
  Future<Screening> updateScreeningReview({
    required String screeningId,
    required ReviewStatus status,
    required String nurseId,
    List<ScreeningResult>? updatedResults,
  });
}
