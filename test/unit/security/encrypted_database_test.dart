import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/encrypted_database.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';
import 'package:sqlite3/sqlite3.dart';

/// Opens [file] through drift with the SQLCipher key, as the app does.
AppDatabase _openApp(File file, String key, {bool seed = true}) => AppDatabase(
      NativeDatabase(file, setup: (db) => db.execute(sqlCipherKeyPragma(key))),
      seedDemoData: seed,
    );

/// Drift opens lazily: run a query so the file is really created.
Future<void> _createWithDrift(File file, String key) async {
  final db = _openApp(file, key);
  await db.select(db.villagesTable).get();
  await db.close();
}

void _writePlaintextDb(File file) {
  final db = sqlite3.open(file.path);
  db.execute('CREATE TABLE notes (id INTEGER PRIMARY KEY, body TEXT)');
  db.execute("INSERT INTO notes (body) VALUES ('ความดัน 150/95'), ('น้ำตาล 130')");
  db.execute('PRAGMA user_version = 5');
  db.close();
}

void main() {
  late Directory dir;
  late File file;
  late InMemorySecureStore store;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('enc_db_test');
    file = File('${dir.path}/db.sqlite');
    store = InMemorySecureStore();
  });
  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  test('the build links SQLCipher', () {
    expect(sqlCipherAvailable(), isTrue);
  });

  group('DatabaseKeyStore', () {
    test('creates a random 256-bit key once and keeps it', () async {
      final keys = DatabaseKeyStore(store);
      final first = await keys.obtainKey();
      expect(first, matches(RegExp(r'^[0-9a-f]{64}$')));
      expect(await keys.obtainKey(), first);
      expect(await store.read(DatabaseKeyStore.keyName), first);
      expect(await DatabaseKeyStore(InMemorySecureStore()).obtainKey(),
          isNot(first));
    });
  });

  group('prepareEncryptedDatabase', () {
    test('a new database is encrypted and unreadable without the key',
        () async {
      final key = await prepareEncryptedDatabase(file, store);
      final db = _openApp(file, key);
      expect(await db.select(db.nursesTable).get(), isNotEmpty);
      await db.close();

      expect(isPlaintextSqlite(file), isFalse);
      expect(opensWithKey(file, key), isTrue);
      final raw = sqlite3.open(file.path);
      expect(() => raw.select('SELECT count(*) FROM sqlite_master'),
          throwsA(isA<SqliteException>()));
      raw.close();
      // Patient names are not stored as readable text.
      expect(String.fromCharCodes(file.readAsBytesSync()), isNot(contains('NUR001')));
    });

    test('an existing plaintext database is encrypted in place, data kept',
        () async {
      _writePlaintextDb(file);
      expect(isPlaintextSqlite(file), isTrue);

      final key = await prepareEncryptedDatabase(file, store);

      expect(isPlaintextSqlite(file), isFalse);
      final db = sqlite3.open(file.path)..execute(sqlCipherKeyPragma(key));
      expect(db.select('SELECT body FROM notes ORDER BY id').map((r) => r['body']),
          ['ความดัน 150/95', 'น้ำตาล 130']);
      expect(db.select('PRAGMA user_version').first.values.first, 5);
      db.close();
      expect(dir.listSync().map((e) => e.path.split(Platform.pathSeparator).last),
          ['db.sqlite'], reason: 'no plaintext copy or temp file is left');
    });

    test('a migrated app database still opens and upgrades through drift',
        () async {
      // Plaintext v5 database written by the pre-M1 app.
      final plain = AppDatabase(NativeDatabase(file), seedDemoData: true);
      expect(await plain.select(plain.patientsTable).get(), isNotEmpty);
      await plain.close();

      final key = await prepareEncryptedDatabase(file, store);
      final db = _openApp(file, key, seed: false);
      expect(await db.select(db.patientsTable).get(), isNotEmpty);
      await db.close();
    });

    test('running twice is a no-op', () async {
      final key = await prepareEncryptedDatabase(file, store);
      await _createWithDrift(file, key);
      final before = file.readAsBytesSync();
      expect(await prepareEncryptedDatabase(file, store), key);
      expect(file.readAsBytesSync(), before);
    });

    test('a database the stored key cannot open is moved aside', () async {
      final oldKey = await prepareEncryptedDatabase(file, store);
      await _createWithDrift(file, oldKey);

      final otherStore = InMemorySecureStore(); // key lost
      final newKey = await prepareEncryptedDatabase(file, otherStore);

      expect(newKey, isNot(oldKey));
      expect(file.existsSync(), isFalse, reason: 'a fresh database is started');
      final aside = dir.listSync().whereType<File>().where((f) => f.path.contains('.unreadable-'));
      expect(aside, hasLength(1));
      expect(opensWithKey(aside.single, oldKey), isTrue);
    });

    test('recovers from a crash in the middle of the swap', () async {
      _writePlaintextDb(file);
      // Crash after the plaintext file was renamed, before the swap ended.
      file.renameSync('${file.path}.plaintext-backup');
      File('${file.path}.encrypting').writeAsStringSync('partial');

      final key = await prepareEncryptedDatabase(file, store);

      expect(isPlaintextSqlite(file), isFalse);
      final db = sqlite3.open(file.path)..execute(sqlCipherKeyPragma(key));
      expect(db.select('SELECT count(*) AS n FROM notes').first['n'], 2);
      db.close();
      expect(File('${file.path}.plaintext-backup').existsSync(), isFalse);
      expect(File('${file.path}.encrypting').existsSync(), isFalse);
    });
  });
}
