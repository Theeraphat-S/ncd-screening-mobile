import 'package:ncd_screening_mobile/data/security/citizen_id_cipher.dart';

/// Fixed test keys so reopening a test database with the same file works.
CitizenIdCipher testCitizenIds() => CitizenIdCipher.withKeys(
  encKey: List<int>.filled(32, 7),
  indexKey: List<int>.filled(32, 9),
);
