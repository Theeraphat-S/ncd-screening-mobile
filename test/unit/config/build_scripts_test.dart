import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The Dart side picks its flavor from `--dart-define=flavor=...`, not from
/// the Gradle flavor. A script that forgets it builds a prod app (no demo
/// data) even when it is called "dev".
void main() {
  const scripts = {
    'build_apk_dev.sh': 'dev',
    'build_apk_prod.sh': 'prod',
    'build_ipa_dev.sh': 'dev',
    'build_windows_dev.bat': 'dev',
    'build_windows_prod.bat': 'prod',
  };

  for (final MapEntry(key: script, value: flavor) in scripts.entries) {
    test('$script passes flavor=$flavor to Dart', () {
      final builds = File(script)
          .readAsLinesSync()
          .where((l) => l.contains('flutter build'))
          .toList();
      expect(builds, isNotEmpty);
      for (final line in builds) {
        expect(line, contains('--dart-define=flavor=$flavor'));
      }
    });
  }
}
