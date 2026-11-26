import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/shared/config/app_config.dart';

void main() {
  group('AppEnvironment', () {
    test('only local and dev are recognised; anything else is prod', () {
      expect(AppEnvironment.parseFlavor('local'), AppFlavor.local);
      expect(AppEnvironment.parseFlavor('dev'), AppFlavor.dev);
      expect(AppEnvironment.parseFlavor('prod'), AppFlavor.prod);
      expect(AppEnvironment.parseFlavor(''), AppFlavor.prod);
      expect(AppEnvironment.parseFlavor('staging'), AppFlavor.prod);
    });

    test('demo data is seeded in dev and local only', () {
      expect(AppEnvironment.flavorSeedsDemoData(AppFlavor.local), isTrue);
      expect(AppEnvironment.flavorSeedsDemoData(AppFlavor.dev), isTrue);
      expect(AppEnvironment.flavorSeedsDemoData(AppFlavor.prod), isFalse);
    });

    test('a build without --dart-define=flavor is prod', () {
      expect(AppEnvironment.flavorName, isEmpty);
      expect(AppEnvironment.flavor, AppFlavor.prod);
      expect(AppEnvironment.seedsDemoData, isFalse);
    });
  });

  group('FeatureFlags', () {
    test('export is off unless the build turns it on', () {
      expect(FeatureFlags.export, isFalse);
    });
  });

  group('demo seed', () {
    test('a prod database starts empty', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      expect(db.seedDemoData, isFalse);
      expect(await db.select(db.villagesTable).get(), isEmpty);
      expect(await db.select(db.nursesTable).get(), isEmpty);
      expect(await db.select(db.vhvsTable).get(), isEmpty);
      expect(await db.select(db.patientsTable).get(), isEmpty);
    });

    test('a dev / local database gets the demo accounts', () async {
      final db = AppDatabase(NativeDatabase.memory(), seedDemoData: true);
      addTearDown(db.close);
      final nurses = await db.select(db.nursesTable).get();
      expect(nurses.map((n) => n.nurseId), contains('NUR001'));
      expect(await db.select(db.patientsTable).get(), isNotEmpty);
    });
  });
}
