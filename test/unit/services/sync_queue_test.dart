import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/data/services/drift_sync_queue_service.dart';
import 'package:ncd_screening_mobile/domain/models/sync_queue_item.dart';
import 'package:ncd_screening_mobile/domain/services/sync_queue_service.dart';
import 'package:ncd_screening_mobile/shared/bloc/sync_badge_bloc.dart';

class _AcceptingTransport implements SyncTransport {
  final List<String> sent = [];

  @override
  Future<void> send(SyncQueueItem item) async {
    sent.add(item.id);
  }
}

class _FailOnSecondTransport implements SyncTransport {
  int _calls = 0;

  @override
  Future<void> send(SyncQueueItem item) async {
    _calls++;
    if (_calls == 2) throw const SyncTransportException('network down');
  }
}

SyncQueueItem _item(String id) => SyncQueueItem(
  id: id,
  entityType: 'screening',
  entityId: 'SCR_$id',
  action: 'create',
  payload: const {'weight': 65.0},
  createdAt: DateTime.now(),
);

/// Polls until [condition] holds, so assertions do not depend on exact timing
/// of the Drift queries behind the bloc.
Future<void> _waitUntil(bool Function() condition, [String label = '']) async {
  final deadline = DateTime.now().add(const Duration(seconds: 3));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('condition not met in time: $label');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

/// In-memory stand-in so the BLoC test does not depend on Drift timing.
class _MemorySyncService implements SyncQueueServiceInterface {
  final List<SyncQueueItem> _items = [];
  final _controller = StreamController<int>.broadcast();

  @override
  Stream<int> get pendingCountStream => _controller.stream;

  @override
  Future<void> enqueue(SyncQueueItem item) async {
    _items.add(item);
    _controller.add(_items.length);
  }

  @override
  Future<List<SyncQueueItem>> getPendingItems() async => List.of(_items);

  @override
  Future<int> getPendingCount() async => _items.length;

  @override
  Future<bool> processQueue() async {
    // No server configured: nothing is accepted, so nothing is removed.
    return false;
  }

  @override
  Future<void> clearSyncedItems() async {}
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('DriftSyncQueueService', () {
    test(
      'queued items survive a restart (new service on the same database)',
      () async {
        await DriftSyncQueueService(db).enqueue(_item('A'));

        final restarted = DriftSyncQueueService(db);
        expect(await restarted.getPendingCount(), 1);
        final pending = await restarted.getPendingItems();
        expect(pending.single.payload, equals({'weight': 65.0}));
      },
    );

    test('without a configured server nothing is marked synced', () async {
      final service = DriftSyncQueueService(db);
      await service.enqueue(_item('A'));
      await service.enqueue(_item('B'));

      final success = await service.processQueue();

      expect(success, isFalse);
      expect(await service.getPendingCount(), 2);
      final pending = await service.getPendingItems();
      expect(pending.first.status, SyncStatus.failed);
      expect(pending.first.errorMessage, isNotNull);
    });

    test('accepted items are removed from the queue', () async {
      final transport = _AcceptingTransport();
      final service = DriftSyncQueueService(db, transport: transport);
      await service.enqueue(_item('A'));
      await service.enqueue(_item('B'));

      expect(await service.processQueue(), isTrue);
      expect(transport.sent, containsAll(['A', 'B']));
      expect(await service.getPendingCount(), 0);
    });

    test(
      'processing stops at the first failure and keeps the rest queued',
      () async {
        final service = DriftSyncQueueService(
          db,
          transport: _FailOnSecondTransport(),
        );
        await service.enqueue(_item('A'));
        await service.enqueue(_item('B'));
        await service.enqueue(_item('C'));

        expect(await service.processQueue(), isFalse);
        final pending = await service.getPendingItems();
        expect(pending.map((i) => i.id), equals(['B', 'C']));
        final failed = pending.firstWhere((i) => i.id == 'B');
        expect(failed.retryCount, 1);
        expect(failed.errorMessage, contains('network down'));
      },
    );
  });

  group('SyncBadgeBloc', () {
    test(
      'offline item stays pending after reconnecting when no server is configured',
      () async {
        final service = _MemorySyncService();
        final bloc = SyncBadgeBloc(syncService: service);

        try {
          expect(bloc.state.pendingCount, 0);
          expect(bloc.state.isOnline, isTrue);

          bloc.add(const SyncBadgeNetworkChanged(false));
          await _waitUntil(() => !bloc.state.isOnline, 'offline');

          bloc.add(SyncBadgeItemEnqueued(_item('OFFLINE')));
          await _waitUntil(() => bloc.state.pendingCount == 1, 'enqueued');
          expect(bloc.state.isFullySynced, isFalse);

          bloc.add(const SyncBadgeNetworkChanged(true));
          await _waitUntil(() => bloc.state.message != null, 'manual sync ran');

          expect(
            bloc.state.pendingCount,
            1,
            reason: 'must not claim data was synced',
          );
          expect(bloc.state.isFullySynced, isFalse);
          expect(bloc.state.message, contains('ค้างอยู่ในเครื่อง'));
        } finally {
          await bloc.close();
        }
      },
    );
  });
}
