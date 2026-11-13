import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';

/// Matching rules for the patient search box. Shared by every repository so
/// the mock and the Drift implementation cannot drift apart.
///
/// The query is split into words; every word must match the title, name,
/// surname, citizen ID (dashes ignored) or address (house number).
class PatientSearch {
  const PatientSearch._();

  static bool matches(Patient p, String query) {
    final words = query
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return true;

    final text = [
      p.patientTitle,
      p.patientFname,
      p.patientLname,
      '${p.patientTitle}${p.patientFname}',
      p.patientAddress,
    ].map((s) => s.toLowerCase()).toList();
    final citizenId = p.patientCitizenId;

    return words.every((w) {
      final digits = w.replaceAll('-', '');
      return text.any((t) => t.contains(w)) ||
          (digits.isNotEmpty && citizenId.contains(digits));
    });
  }
}
