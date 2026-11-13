import 'dart:async';
import 'package:ncd_screening_mobile/domain/models/sync_queue_item.dart';

abstract class SyncQueueServiceInterface {
  /// Whether a server is available to receive queued items at all.
  bool get canSync;

  Future<void> enqueue(SyncQueueItem item);
  Future<List<SyncQueueItem>> getPendingItems();
  Future<int> getPendingCount();

  /// Tries to deliver pending items. Returns true only if every item was
  /// delivered; false when there is no server or any delivery failed.
  Future<bool> processQueue();
  Future<void> clearSyncedItems();
  Stream<int> get pendingCountStream;
}
