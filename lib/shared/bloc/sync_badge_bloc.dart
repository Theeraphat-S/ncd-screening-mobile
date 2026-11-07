import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/sync_queue_item.dart';
import 'package:ncd_screening_mobile/domain/services/sync_queue_service.dart';

// --- Events ---
abstract class SyncBadgeEvent extends Equatable {
  const SyncBadgeEvent();

  @override
  List<Object?> get props => [];
}

class SyncBadgeStarted extends SyncBadgeEvent {
  const SyncBadgeStarted();
}

class SyncBadgeRefreshRequested extends SyncBadgeEvent {
  const SyncBadgeRefreshRequested();
}

class SyncBadgeManualSyncRequested extends SyncBadgeEvent {
  const SyncBadgeManualSyncRequested();
}

class SyncBadgeNetworkChanged extends SyncBadgeEvent {
  final bool isOnline;
  const SyncBadgeNetworkChanged(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}

class SyncBadgeItemEnqueued extends SyncBadgeEvent {
  final SyncQueueItem item;
  const SyncBadgeItemEnqueued(this.item);

  @override
  List<Object?> get props => [item];
}

// --- State ---
class SyncBadgeState extends Equatable {
  final int pendingCount;
  final bool isSyncing;
  final bool isOnline;
  final DateTime? lastSyncedAt;
  final String? message;

  const SyncBadgeState({
    this.pendingCount = 0,
    this.isSyncing = false,
    this.isOnline = true,
    this.lastSyncedAt,
    this.message,
  });

  bool get isFullySynced => pendingCount == 0 && !isSyncing;

  SyncBadgeState copyWith({
    int? pendingCount,
    bool? isSyncing,
    bool? isOnline,
    DateTime? lastSyncedAt,
    String? message,
  }) {
    return SyncBadgeState(
      pendingCount: pendingCount ?? this.pendingCount,
      isSyncing: isSyncing ?? this.isSyncing,
      isOnline: isOnline ?? this.isOnline,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    pendingCount,
    isSyncing,
    isOnline,
    lastSyncedAt,
    message,
  ];
}

// --- BLoC ---
class SyncBadgeBloc extends Bloc<SyncBadgeEvent, SyncBadgeState> {
  final SyncQueueServiceInterface _syncService;
  StreamSubscription<int>? _subscription;

  SyncBadgeBloc({required SyncQueueServiceInterface syncService})
    : _syncService = syncService,
      super(const SyncBadgeState()) {
    on<SyncBadgeStarted>(_onStarted);
    on<SyncBadgeRefreshRequested>(_onRefresh);
    on<SyncBadgeManualSyncRequested>(_onManualSync);
    on<SyncBadgeNetworkChanged>(_onNetworkChanged);
    on<SyncBadgeItemEnqueued>(_onItemEnqueued);

    _subscription = _syncService.pendingCountStream.listen((count) {
      add(const SyncBadgeRefreshRequested());
    });
  }

  Future<void> _onStarted(
    SyncBadgeStarted event,
    Emitter<SyncBadgeState> emit,
  ) async {
    final count = await _syncService.getPendingCount();
    emit(state.copyWith(pendingCount: count));
  }

  Future<void> _onRefresh(
    SyncBadgeRefreshRequested event,
    Emitter<SyncBadgeState> emit,
  ) async {
    final count = await _syncService.getPendingCount();
    emit(state.copyWith(pendingCount: count));
  }

  Future<void> _onItemEnqueued(
    SyncBadgeItemEnqueued event,
    Emitter<SyncBadgeState> emit,
  ) async {
    await _syncService.enqueue(event.item);
    final count = await _syncService.getPendingCount();
    emit(state.copyWith(pendingCount: count));

    // If online, auto trigger background sync
    if (state.isOnline) {
      add(const SyncBadgeManualSyncRequested());
    }
  }

  Future<void> _onManualSync(
    SyncBadgeManualSyncRequested event,
    Emitter<SyncBadgeState> emit,
  ) async {
    if (state.isSyncing) return;
    if (!state.isOnline) {
      emit(state.copyWith(message: 'ไม่มีสัญญาณอินเทอร์เน็ต'));
      return;
    }

    emit(
      state.copyWith(
        isSyncing: true,
        message: 'กำลังซิงค์ข้อมูลกับเซิร์ฟเวอร์...',
      ),
    );
    final success = await _syncService.processQueue();
    final count = await _syncService.getPendingCount();

    emit(
      state.copyWith(
        isSyncing: false,
        pendingCount: count,
        lastSyncedAt: success ? DateTime.now() : state.lastSyncedAt,
        message: success
            ? 'ซิงค์ข้อมูลเรียบร้อยแล้ว'
            : 'ซิงค์ไม่สำเร็จ ข้อมูล $count รายการยังค้างอยู่ในเครื่อง',
      ),
    );
  }

  void _onNetworkChanged(
    SyncBadgeNetworkChanged event,
    Emitter<SyncBadgeState> emit,
  ) {
    emit(state.copyWith(isOnline: event.isOnline));
    if (event.isOnline && state.pendingCount > 0) {
      add(const SyncBadgeManualSyncRequested());
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
