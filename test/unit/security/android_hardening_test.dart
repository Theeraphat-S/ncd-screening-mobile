import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards Android settings that no Dart test can exercise at run time.
void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

  test('backups are off and device transfer uses the exclusion rules', () {
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:dataExtractionRules="@xml/data_extraction_rules"'));
  });

  test('the extraction rules exclude the database, prefs and app files', () {
    final rules =
        File('android/app/src/main/res/xml/data_extraction_rules.xml').readAsStringSync();
    for (final section in ['cloud-backup', 'device-transfer']) {
      final body = RegExp('<$section>(.*?)</$section>', dotAll: true)
          .firstMatch(rules)!
          .group(1)!;
      for (final domain in ['root', 'file', 'database', 'sharedpref']) {
        expect(body, contains('<exclude domain="$domain" path="." />'),
            reason: '$section / $domain');
      }
      expect(body, isNot(contains('<include')));
    }
  });

  test('MainActivity sets FLAG_SECURE', () {
    final activity = Directory('android/app/src/main')
        .listSync(recursive: true)
        .whereType<File>()
        .singleWhere((f) => f.path.endsWith('MainActivity.kt'));
    expect(activity.readAsStringSync(), contains('WindowManager.LayoutParams.FLAG_SECURE'));
  });
}
