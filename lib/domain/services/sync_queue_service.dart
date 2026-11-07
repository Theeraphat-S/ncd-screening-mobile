import 'dart:async';

import 'package:ncd_screening_mobile/domain/models/sync_queue_item.dart';

abstract class SyncQueueServiceInterface {
  Future<void> enqueue(SyncQueueItem item);
  Future<List<SyncQueueItem>> getPendingItems();
  Future<int> getPendingCount();
  Future<bool> processQueue();
  Future<void> clearSyncedItems();
  Stream<int> get pendingCountStream;
}

/// Sends one queued item to the server. Returns normally only when the server
/// has accepted the item; any exception means the item stays queued.
abstract class SyncTransport {
  Future<void> send(SyncQueueItem item);
}

class SyncTransportException implements Exception {
  final String message;
  const SyncTransportException(this.message);

  @override
  String toString() => message;
}

/// Used until a backend endpoint is configured. Nothing is ever marked as
/// synced by this transport, so data stays in the local queue.
class UnconfiguredSyncTransport implements SyncTransport {
  const UnconfiguredSyncTransport();

  @override
  Future<void> send(SyncQueueItem item) async {
    throw const SyncTransportException(
      'ยังไม่ได้เชื่อมต่อเซิร์ฟเวอร์ ข้อมูลยังค้างอยู่ในเครื่อง',
    );
  }
}
