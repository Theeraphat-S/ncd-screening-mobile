import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/domain/models/sync_queue_item.dart';
import 'package:ncd_screening_mobile/domain/services/sync_queue_service.dart';
import 'package:ncd_screening_mobile/domain/services/sync_transport.dart';

/// Durable outbox backed by the `sync_queue` table. Items stay on disk until
/// a [SyncTransport] confirms delivery; without a server nothing is ever
/// marked as synced.
class DriftSyncQueueService implements SyncQueueServiceInterface {
  final AppDatabase _db;
  final SyncTransport _transport;
  bool _isProcessing = false;

  DriftSyncQueueService(this._db, this._transport);

  static const _unsynced = ['pending', 'failed', 'syncing'];

  @override
  bool get canSync => _transport.isConfigured;

  @override
  Stream<int> get pendingCountStream {
    final count = _db.syncQueueTable.id.count();
    final query = _db.selectOnly(_db.syncQueueTable)
      ..addColumns([count])
      ..where(_db.syncQueueTable.status.isIn(_unsynced));
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  @override
  Future<void> enqueue(SyncQueueItem item) async {
    await _db.into(_db.syncQueueTable).insertOnConflictUpdate(
          SyncQueueTableCompanion(
            id: Value(item.id),
            entityType: Value(item.entityType),
            entityId: Value(item.entityId),
            action: Value(item.action),
            payload: Value(jsonEncode(item.payload)),
            createdAt: Value(item.createdAt),
            retryCount: Value(item.retryCount),
            status: Value(item.status.name),
            errorMessage: Value(item.errorMessage),
          ),
        );
  }

  @override
  Future<List<SyncQueueItem>> getPendingItems() async {
    final query = _db.select(_db.syncQueueTable)
      ..where((t) => t.status.isIn(['pending', 'failed']))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return (await query.get()).map(_toItem).toList();
  }

  @override
  Future<int> getPendingCount() async {
    final count = _db.syncQueueTable.id.count();
    final query = _db.selectOnly(_db.syncQueueTable)
      ..addColumns([count])
      ..where(_db.syncQueueTable.status.isIn(['pending', 'failed']));
    return (await query.getSingle()).read(count) ?? 0;
  }

  @override
  Future<bool> processQueue() async {
    if (!_transport.isConfigured || _isProcessing) return false;
    _isProcessing = true;
    try {
      // A crash mid-send leaves rows in "syncing"; make them eligible again.
      await (_db.update(_db.syncQueueTable)
            ..where((t) => t.status.equals('syncing')))
          .write(const SyncQueueTableCompanion(status: Value('pending')));

      var allSucceeded = true;
      for (final item in await getPendingItems()) {
        await _setStatus(item.id, SyncStatus.syncing);
        try {
          await _transport.send(item);
          await _setStatus(item.id, SyncStatus.synced);
        } catch (e) {
          allSucceeded = false;
          await (_db.update(_db.syncQueueTable)
                ..where((t) => t.id.equals(item.id)))
              .write(SyncQueueTableCompanion(
            status: const Value('failed'),
            retryCount: Value(item.retryCount + 1),
            errorMessage: Value('$e'),
          ));
        }
      }
      return allSucceeded;
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Future<void> clearSyncedItems() async {
    await (_db.delete(_db.syncQueueTable)
          ..where((t) => t.status.equals('synced')))
        .go();
  }

  Future<void> _setStatus(String id, SyncStatus status) =>
      (_db.update(_db.syncQueueTable)..where((t) => t.id.equals(id)))
          .write(SyncQueueTableCompanion(
        status: Value(status.name),
        errorMessage: const Value(null),
      ));

  SyncQueueItem _toItem(SyncQueueTableData row) => SyncQueueItem(
        id: row.id,
        entityType: row.entityType,
        entityId: row.entityId,
        action: row.action,
        payload: jsonDecode(row.payload) as Map<String, dynamic>,
        createdAt: row.createdAt,
        retryCount: row.retryCount,
        status: SyncStatus.values.byName(row.status),
        errorMessage: row.errorMessage,
      );
}
