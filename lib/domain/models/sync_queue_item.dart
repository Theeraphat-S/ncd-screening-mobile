import 'dart:convert';
import 'package:equatable/equatable.dart';

enum SyncStatus { pending, syncing, synced, failed }

class SyncQueueItem extends Equatable {
  final String id;
  final String entityType; // 'screening', 'patient', 'review'
  final String entityId;
  final String action; // 'create', 'update'
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
  final SyncStatus status;
  final String? errorMessage;

  const SyncQueueItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.status = SyncStatus.pending,
    this.errorMessage,
  });

  SyncQueueItem copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? action,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    int? retryCount,
    SyncStatus? status,
    String? errorMessage,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'action': action,
      'payload': jsonEncode(payload),
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'status': status.name,
      'errorMessage': errorMessage,
    };
  }

  factory SyncQueueItem.fromMap(Map<String, dynamic> map) {
    return SyncQueueItem(
      id: map['id'] as String,
      entityType: map['entityType'] as String,
      entityId: map['entityId'] as String,
      action: map['action'] as String,
      payload: map['payload'] is String
          ? jsonDecode(map['payload'] as String) as Map<String, dynamic>
          : map['payload'] as Map<String, dynamic>,
      createdAt: DateTime.parse(map['createdAt'] as String),
      retryCount: (map['retryCount'] as num?)?.toInt() ?? 0,
      status: SyncStatus.values.byName(map['status'] as String? ?? 'pending'),
      errorMessage: map['errorMessage'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    entityType,
    entityId,
    action,
    payload,
    createdAt,
    retryCount,
    status,
    errorMessage,
  ];
}
