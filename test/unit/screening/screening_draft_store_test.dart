import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/data/repositories/screening_draft_store.dart';

void main() {
  late AppDatabase db;
  late DateTime now;
  late ScreeningDraftStore store;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime(2026, 11, 12, 9);
    store = ScreeningDraftStore(db, now: () => now);
  });
  tearDown(() => db.close());

  test('nothing saved yet', () async {
    expect(await store.load('P001', 'VHV001'), isNull);
  });

  test('saves and restores the form data (including Thai text)', () async {
    await store.save('P001', 'VHV001', {
      'weight': '60.5',
      'q1': 'มี',
      'ncds': ['โรคเบาหวาน', 'โรคความดันโลหิตสูง'],
    });

    final draft = (await store.load('P001', 'VHV001'))!;
    expect(draft.data['weight'], '60.5');
    expect(draft.data['q1'], 'มี');
    expect(draft.data['ncds'], ['โรคเบาหวาน', 'โรคความดันโลหิตสูง']);
    expect(draft.updatedAt, now);
  });

  test('saving again overwrites instead of duplicating', () async {
    await store.save('P001', 'VHV001', {'weight': '60'});
    now = now.add(const Duration(minutes: 5));
    await store.save('P001', 'VHV001', {'weight': '61'});

    expect((await store.load('P001', 'VHV001'))!.data['weight'], '61');
    expect(await db.select(db.screeningDraftsTable).get(), hasLength(1));
  });

  test('drafts are kept apart per patient and per VHV', () async {
    await store.save('P001', 'VHV001', {'weight': '60'});
    await store.save('P002', 'VHV001', {'weight': '70'});
    await store.save('P001', 'VHV002', {'weight': '80'});

    expect((await store.load('P001', 'VHV001'))!.data['weight'], '60');
    expect((await store.load('P002', 'VHV001'))!.data['weight'], '70');
    expect((await store.load('P001', 'VHV002'))!.data['weight'], '80');
  });

  test('delete removes only that draft', () async {
    await store.save('P001', 'VHV001', {'weight': '60'});
    await store.save('P002', 'VHV001', {'weight': '70'});
    await store.delete('P001', 'VHV001');

    expect(await store.load('P001', 'VHV001'), isNull);
    expect(await store.load('P002', 'VHV001'), isNotNull);
  });

  test('drafts older than 7 days are discarded (health data is not kept forever)',
      () async {
    await store.save('P001', 'VHV001', {'weight': '60'});

    now = now.add(const Duration(days: 6, hours: 23));
    expect(await store.load('P001', 'VHV001'), isNotNull);

    now = now.add(const Duration(hours: 2));
    expect(await store.load('P001', 'VHV001'), isNull);
    expect(await db.select(db.screeningDraftsTable).get(), isEmpty,
        reason: 'expired draft is deleted on read');
  });

  test('purgeExpired clears every stale draft but keeps fresh ones', () async {
    await store.save('P001', 'VHV001', {'weight': '60'});
    now = now.add(const Duration(days: 8));
    await store.save('P002', 'VHV001', {'weight': '70'});

    await store.purgeExpired();
    final rows = await db.select(db.screeningDraftsTable).get();
    expect(rows.map((r) => r.patientId), ['P002']);
  });

  test('a corrupted payload is treated as no draft', () async {
    await store.save('P001', 'VHV001', {'weight': '60'});
    await db.customStatement("UPDATE screening_drafts SET payload = 'not json'");

    expect(await store.load('P001', 'VHV001'), isNull);
    expect(await db.select(db.screeningDraftsTable).get(), isEmpty);
  });
}
