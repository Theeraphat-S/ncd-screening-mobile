import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/domain/models/sync_queue_item.dart';
import 'package:ncd_screening_mobile/domain/services/sync_queue_service.dart';

/// Durable outbox backed by the `sync_queue` table, so pending items survive
/// app restarts. Items are only removed after the transport confirms them.
class DriftSyncQueueService implements SyncQueueServiceInterface {
  final AppDatabase _db;
  final SyncTransport _transport;
  final _countController = StreamController<int>.broadcast();
  bool _isProcessing = false;

  DriftSyncQueueService(
    this._db, {
    SyncTransport transport = const UnconfiguredSyncTransport(),
  }) : _transport = transport;

  @override
  Stream<int> get pendingCountStream => _countController.stream;

  @override
  Future<void> enqueue(SyncQueueItem item) async {
    await _db
        .into(_db.syncQueueTable)
        .insertOnConflictUpdate(_toCompanion(item));
    await _notifyCount();
  }

  @override
  Future<List<SyncQueueItem>> getPendingItems() async {
    final rows =
        await (_db.select(_db.syncQueueTable)
              ..where((t) => t.status.isIn(['pending', 'failed']))
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    return rows.map(_toItem).toList();
  }

  @override
  Future<int> getPendingCount() async {
    final count = _db.syncQueueTable.id.count();
    final query = _db.selectOnly(_db.syncQueueTable)
      ..addColumns([count])
      ..where(_db.syncQueueTable.status.isIn(['pending', 'failed']));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  @override
  Future<bool> processQueue() async {
    if (_isProcessing) return false;
    _isProcessing = true;

    try {
      final pending = await getPendingItems();
      for (final item in pending) {
        await _setStatus(item.id, SyncStatus.syncing);
        try {
          await _transport.send(item);
          await (_db.delete(
            _db.syncQueueTable,
          )..where((t) => t.id.equals(item.id))).go();
        } catch (e) {
          await (_db.update(
            _db.syncQueueTable,
          )..where((t) => t.id.equals(item.id))).write(
            SyncQueueTableCompanion(
              status: const Value('failed'),
              retryCount: Value(item.retryCount + 1),
              errorMessage: Value(e.toString()),
            ),
          );
          // Stop on the first failure; the remaining items would fail the same way.
          await _notifyCount();
          return false;
        }
        await _notifyCount();
      }
      return true;
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Future<void> clearSyncedItems() async {
    // Confirmed items are deleted immediately in processQueue.
    await _notifyCount();
  }

  Future<void> _setStatus(String id, SyncStatus status) async {
    await (_db.update(_db.syncQueueTable)..where((t) => t.id.equals(id))).write(
      SyncQueueTableCompanion(status: Value(status.name)),
    );
  }

  Future<void> _notifyCount() async {
    if (!_countController.isClosed) {
      _countController.add(await getPendingCount());
    }
  }

  SyncQueueTableCompanion _toCompanion(SyncQueueItem item) {
    return SyncQueueTableCompanion(
      id: Value(item.id),
      entityType: Value(item.entityType),
      entityId: Value(item.entityId),
      action: Value(item.action),
      payload: Value(jsonEncode(item.payload)),
      createdAt: Value(item.createdAt),
      retryCount: Value(item.retryCount),
      status: Value(item.status.name),
      errorMessage: Value(item.errorMessage),
    );
  }

  SyncQueueItem _toItem(SyncQueueTableData row) {
    return SyncQueueItem(
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

  void dispose() {
    _countController.close();
  }
}
