import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/data/services/local_data_wiper.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';

void main() {
  late Directory dir;

  setUp(() async => dir = await Directory.systemTemp.createTemp('wipe_test'));
  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  test('erases secrets, closes and deletes the database and its sidecars',
      () async {
    final db = File('${dir.path}/db.sqlite')..writeAsStringSync('data');
    final wal = File('${db.path}-wal')..writeAsStringSync('wal');
    final shm = File('${db.path}-shm')..writeAsStringSync('shm');
    final other = File('${dir.path}/unrelated.txt')..writeAsStringSync('keep');
    final store = InMemorySecureStore();
    await store.write('db_key', 'k');
    await store.write('pin_hash_VHV001', 'h');
    var closed = 0;

    await LocalDataWiper(
      store: store,
      closeDatabase: () async => closed++,
      databaseFile: () async => db,
    ).wipe();

    expect(store.dump(), isEmpty);
    expect(closed, 1);
    expect(db.existsSync(), isFalse);
    expect(wal.existsSync(), isFalse);
    expect(shm.existsSync(), isFalse);
    expect(other.existsSync(), isTrue);
  });

  test('a failing step does not stop the others', () async {
    final db = File('${dir.path}/db.sqlite')..writeAsStringSync('data');
    final store = InMemorySecureStore();
    await store.write('db_key', 'k');

    await LocalDataWiper(
      store: store,
      closeDatabase: () async => throw StateError('already closed'),
      databaseFile: () async => db,
    ).wipe();

    expect(store.dump(), isEmpty);
    expect(db.existsSync(), isFalse);
  });
}
