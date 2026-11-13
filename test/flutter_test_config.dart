import 'dart:async';

import 'package:ncd_screening_mobile/domain/services/password_hasher.dart';

/// Widget tests run under a fake clock where worker-isolate results never
/// arrive, so hashing stays on the test isolate. The isolate path itself is
/// covered in password_hasher_test.dart.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  PasswordHasher.runInIsolate = false;
  await testMain();
}
