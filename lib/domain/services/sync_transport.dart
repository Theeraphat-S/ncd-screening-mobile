import 'package:ncd_screening_mobile/domain/models/sync_queue_item.dart';

/// Delivers one queued change to a server. Implementations throw on failure.
abstract class SyncTransport {
  /// False when there is no server to talk to (nothing may be marked synced).
  bool get isConfigured;

  Future<void> send(SyncQueueItem item);
}

/// Placeholder until a backend exists: data stays queued on the device.
class NoServerTransport implements SyncTransport {
  const NoServerTransport();

  @override
  bool get isConfigured => false;

  @override
  Future<void> send(SyncQueueItem item) =>
      Future.error(StateError('ยังไม่มีเซิร์ฟเวอร์สำหรับซิงค์ข้อมูล'));
}
