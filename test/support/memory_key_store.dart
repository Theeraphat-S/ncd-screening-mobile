import 'package:ncd_screening_mobile/data/security/citizen_id_cipher.dart';

/// In-memory key store so tests never touch the platform keystore.
class MemoryKeyStore implements SecretKeyStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String name) async => _values[name];

  @override
  Future<void> write(String name, String value) async {
    _values[name] = value;
  }
}
