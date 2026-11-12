import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/data/repositories/drift_sync_queue_service.dart';
import 'package:ncd_screening_mobile/domain/models/sync_queue_item.dart';
import 'package:ncd_screening_mobile/domain/services/sync_transport.dart';
import 'package:ncd_screening_mobile/shared/bloc/sync_badge_bloc.dart';

class FakeTransport implements SyncTransport {
  final List<String> sent = [];
  final Set<String> failIds;
  FakeTransport({this.failIds = const {}});

  @override
  bool get isConfigured => true;

  @override
  Future<void> send(SyncQueueItem item) async {
    if (failIds.contains(item.id)) throw Exception('network down');
    sent.add(item.id);
  }
}

SyncQueueItem _item(String id, {DateTime? at, Map<String, dynamic>? payload}) =>
    SyncQueueItem(
      id: id,
      entityType: 'screening',
      entityId: 'SCR_$id',
      action: 'create',
      payload: payload ?? const {},
      createdAt: at ?? DateTime(2026, 11, 12, 9),
    );

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('DriftSyncQueueService - persistence', () {
    test('enqueued items survive creating a new service (app restart)',
        () async {
      final first = DriftSyncQueueService(db, const NoServerTransport());
      await first.enqueue(_item('A', payload: const {'weight': 65.5, 'n': 'ก'}));

      final second = DriftSyncQueueService(db, const NoServerTransport());
      final pending = await second.getPendingItems();
      expect(pending.map((e) => e.id), ['A']);
      expect(pending.single.payload, {'weight': 65.5, 'n': 'ก'});
      expect(await second.getPendingCount(), 1);
    });

    test('enqueueing the same id replaces instead of duplicating', () async {
      final service = DriftSyncQueueService(db, const NoServerTransport());
      await service.enqueue(_item('A'));
      await service.enqueue(_item('A', payload: const {'v': 2}));
      expect(await service.getPendingCount(), 1);
      expect((await service.getPendingItems()).single.payload, {'v': 2});
    });

    test('pending items come back oldest first', () async {
      final service = DriftSyncQueueService(db, const NoServerTransport());
      await service.enqueue(_item('new', at: DateTime(2026, 11, 12, 10)));
      await service.enqueue(_item('old', at: DateTime(2026, 11, 12, 8)));
      expect((await service.getPendingItems()).map((e) => e.id), ['old', 'new']);
    });

    test('pendingCountStream reports the count as items are added', () async {
      final service = DriftSyncQueueService(db, const NoServerTransport());
      final counts = <int>[];
      final sub = service.pendingCountStream.listen(counts.add);
      await service.enqueue(_item('A'));
      await service.enqueue(_item('B'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();
      expect(counts.last, 2);
    });
  });

  group('DriftSyncQueueService - no server configured', () {
    test('canSync is false and processQueue never claims success', () async {
      final service = DriftSyncQueueService(db, const NoServerTransport());
      await service.enqueue(_item('A'));

      expect(service.canSync, isFalse);
      expect(await service.processQueue(), isFalse);
      expect(await service.getPendingCount(), 1);
      expect((await service.getPendingItems()).single.status, SyncStatus.pending);
    });
  });

  group('DriftSyncQueueService - with a transport', () {
    test('sends pending items in order and marks them synced', () async {
      final transport = FakeTransport();
      final service = DriftSyncQueueService(db, transport);
      await service.enqueue(_item('second', at: DateTime(2026, 11, 12, 10)));
      await service.enqueue(_item('first', at: DateTime(2026, 11, 12, 8)));

      expect(await service.processQueue(), isTrue);
      expect(transport.sent, ['first', 'second']);
      expect(await service.getPendingCount(), 0);
    });

    test('a failing item is marked failed and does not block the others',
        () async {
      final transport = FakeTransport(failIds: {'bad'});
      final service = DriftSyncQueueService(db, transport);
      await service.enqueue(_item('bad', at: DateTime(2026, 11, 12, 8)));
      await service.enqueue(_item('good', at: DateTime(2026, 11, 12, 9)));

      expect(await service.processQueue(), isFalse);
      expect(transport.sent, ['good']);

      final pending = await service.getPendingItems();
      expect(pending.map((e) => e.id), ['bad']);
      expect(pending.single.status, SyncStatus.failed);
      expect(pending.single.retryCount, 1);
      expect(pending.single.errorMessage, contains('network down'));
    });

    test('failed items are retried on the next run', () async {
      final service = DriftSyncQueueService(db, FakeTransport(failIds: {'bad'}));
      await service.enqueue(_item('bad'));
      await service.processQueue();
      await service.processQueue();
      expect((await service.getPendingItems()).single.retryCount, 2);

      final healthy = DriftSyncQueueService(db, FakeTransport());
      expect(await healthy.processQueue(), isTrue);
      expect(await healthy.getPendingCount(), 0);
    });

    test('items left in "syncing" by a crash are picked up again', () async {
      final service = DriftSyncQueueService(db, FakeTransport());
      await service.enqueue(_item('A'));
      await db.customStatement("UPDATE sync_queue SET status = 'syncing'");

      expect(await service.processQueue(), isTrue);
      expect(await service.getPendingCount(), 0);
    });

    test('clearSyncedItems removes only synced rows', () async {
      final service = DriftSyncQueueService(db, FakeTransport(failIds: {'bad'}));
      await service.enqueue(_item('ok'));
      await service.enqueue(_item('bad'));
      await service.processQueue();
      await service.clearSyncedItems();

      final rows = await db.select(db.syncQueueTable).get();
      expect(rows.map((r) => r.id), ['bad']);
    });
  });

  group('SyncBadgeBloc', () {
    test('without a server: no fake success, count stays, message explains',
        () async {
      final service = DriftSyncQueueService(db, const NoServerTransport());
      final bloc = SyncBadgeBloc(syncService: service);
      addTearDown(bloc.close);
      await service.enqueue(_item('A'));

      bloc.add(const SyncBadgeStarted());
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.canSync, isFalse);
      expect(bloc.state.pendingCount, 1);

      bloc.add(const SyncBadgeManualSyncRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.pendingCount, 1);
      expect(bloc.state.isFullySynced, isFalse);
      expect(bloc.state.lastSyncedAt, isNull);
      expect(bloc.state.message, contains('ยังไม่มีเซิร์ฟเวอร์'));
    });

    test('enqueuing without a server does not trigger a sync attempt',
        () async {
      final service = DriftSyncQueueService(db, const NoServerTransport());
      final bloc = SyncBadgeBloc(syncService: service);
      addTearDown(bloc.close);

      bloc.add(SyncBadgeItemEnqueued(_item('A')));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(bloc.state.pendingCount, 1);
      expect(bloc.state.isSyncing, isFalse);
      expect(bloc.state.lastSyncedAt, isNull);
    });

    test('with a transport: offline queues, reconnect syncs', () async {
      final service = DriftSyncQueueService(db, FakeTransport());
      final bloc = SyncBadgeBloc(syncService: service);
      addTearDown(bloc.close);

      bloc.add(const SyncBadgeNetworkChanged(false));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.isOnline, isFalse);

      bloc.add(SyncBadgeItemEnqueued(_item('A')));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(bloc.state.pendingCount, 1);

      bloc.add(const SyncBadgeNetworkChanged(true));
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(bloc.state.pendingCount, 0);
      expect(bloc.state.isFullySynced, isTrue);
      expect(bloc.state.lastSyncedAt, isNotNull);
    });

    test('initial state', () {
      final bloc = SyncBadgeBloc(
        syncService: DriftSyncQueueService(db, const NoServerTransport()),
      );
      addTearDown(bloc.close);
      expect(bloc.state.pendingCount, 0);
      expect(bloc.state.isOnline, isTrue);
      expect(bloc.state.isFullySynced, isTrue);
    });
  });
}
