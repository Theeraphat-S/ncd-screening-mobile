import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/models/village_analytics.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/services/village_analytics_calculator.dart';

// EVENTS
abstract class VillageAnalyticsEvent extends Equatable {
  const VillageAnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class VillageAnalyticsLoadRequested extends VillageAnalyticsEvent {
  final String? villageId;
  final AnalyticsSortOrder? sortOrder;

  const VillageAnalyticsLoadRequested({this.villageId, this.sortOrder});

  @override
  List<Object?> get props => [villageId, sortOrder];
}

class VillageAnalyticsFilterChanged extends VillageAnalyticsEvent {
  final String? villageId;

  const VillageAnalyticsFilterChanged(this.villageId);

  @override
  List<Object?> get props => [villageId];
}

class VillageAnalyticsSortOrderChanged extends VillageAnalyticsEvent {
  final AnalyticsSortOrder sortOrder;

  const VillageAnalyticsSortOrderChanged(this.sortOrder);

  @override
  List<Object?> get props => [sortOrder];
}

class VillageAnalyticsRefreshRequested extends VillageAnalyticsEvent {
  const VillageAnalyticsRefreshRequested();
}

// STATES
enum VillageAnalyticsStatus { initial, loading, success, failure }

class VillageAnalyticsState extends Equatable {
  final VillageAnalyticsStatus status;
  final VillageAnalytics? analytics;
  final List<Village> villages;
  final String? selectedVillageId;
  final AnalyticsSortOrder sortOrder;
  final String? errorMessage;

  const VillageAnalyticsState({
    this.status = VillageAnalyticsStatus.initial,
    this.analytics,
    this.villages = const [],
    this.selectedVillageId,
    this.sortOrder = AnalyticsSortOrder.highRiskDesc,
    this.errorMessage,
  });

  VillageAnalyticsState copyWith({
    VillageAnalyticsStatus? status,
    VillageAnalytics? analytics,
    List<Village>? villages,
    String? selectedVillageId,
    bool clearSelectedVillage = false,
    AnalyticsSortOrder? sortOrder,
    String? errorMessage,
  }) {
    return VillageAnalyticsState(
      status: status ?? this.status,
      analytics: analytics ?? this.analytics,
      villages: villages ?? this.villages,
      selectedVillageId: clearSelectedVillage
          ? null
          : (selectedVillageId ?? this.selectedVillageId),
      sortOrder: sortOrder ?? this.sortOrder,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        analytics,
        villages,
        selectedVillageId,
        sortOrder,
        errorMessage,
      ];
}

// BLOC
class VillageAnalyticsBloc
    extends Bloc<VillageAnalyticsEvent, VillageAnalyticsState> {
  final NcdRepositoryInterface repository;

  List<Village> _cachedVillages = [];
  List<Patient> _cachedPatients = [];
  List<Screening> _cachedScreenings = [];

  VillageAnalyticsBloc(this.repository)
      : super(const VillageAnalyticsState()) {
    on<VillageAnalyticsLoadRequested>(_onLoadRequested);
    on<VillageAnalyticsFilterChanged>(_onFilterChanged);
    on<VillageAnalyticsSortOrderChanged>(_onSortOrderChanged);
    on<VillageAnalyticsRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _fetchAndCompute({
    required Emitter<VillageAnalyticsState> emit,
    String? villageId,
    AnalyticsSortOrder? sortOrder,
  }) async {
    emit(state.copyWith(
      status: VillageAnalyticsStatus.loading,
      errorMessage: null,
    ));

    try {
      final results = await Future.wait([
        repository.getVillages(),
        repository.getPatients(),
        repository.getAllScreenings(),
      ]);

      _cachedVillages = results[0] as List<Village>;
      _cachedPatients = results[1] as List<Patient>;
      _cachedScreenings = results[2] as List<Screening>;

      final activeVillageId = villageId ?? state.selectedVillageId;
      final activeSortOrder = sortOrder ?? state.sortOrder;

      final analytics = VillageAnalyticsCalculator.compute(
        villages: _cachedVillages,
        patients: _cachedPatients,
        screenings: _cachedScreenings,
        selectedVillageId: activeVillageId,
        sortOrder: activeSortOrder,
      );

      emit(state.copyWith(
        status: VillageAnalyticsStatus.success,
        analytics: analytics,
        villages: _cachedVillages,
        selectedVillageId: activeVillageId,
        clearSelectedVillage: activeVillageId == null || activeVillageId.isEmpty,
        sortOrder: activeSortOrder,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VillageAnalyticsStatus.failure,
        errorMessage: 'ไม่สามารถโหลดข้อมูลสถิติสุขภาพได้ ตรวจสอบแล้วลองอีกครั้ง',
      ));
    }
  }

  Future<void> _onLoadRequested(
    VillageAnalyticsLoadRequested event,
    Emitter<VillageAnalyticsState> emit,
  ) async {
    await _fetchAndCompute(
      emit: emit,
      villageId: event.villageId,
      sortOrder: event.sortOrder,
    );
  }

  void _onFilterChanged(
    VillageAnalyticsFilterChanged event,
    Emitter<VillageAnalyticsState> emit,
  ) {
    final newVillageId = (event.villageId == null ||
            event.villageId!.isEmpty ||
            event.villageId == 'ALL')
        ? null
        : event.villageId;

    if (_cachedVillages.isEmpty && state.status != VillageAnalyticsStatus.loading) {
      add(VillageAnalyticsLoadRequested(villageId: newVillageId));
      return;
    }

    final analytics = VillageAnalyticsCalculator.compute(
      villages: _cachedVillages,
      patients: _cachedPatients,
      screenings: _cachedScreenings,
      selectedVillageId: newVillageId,
      sortOrder: state.sortOrder,
    );

    emit(state.copyWith(
      status: VillageAnalyticsStatus.success,
      analytics: analytics,
      selectedVillageId: newVillageId,
      clearSelectedVillage: newVillageId == null,
    ));
  }

  void _onSortOrderChanged(
    VillageAnalyticsSortOrderChanged event,
    Emitter<VillageAnalyticsState> emit,
  ) {
    if (_cachedVillages.isEmpty && state.status != VillageAnalyticsStatus.loading) {
      add(VillageAnalyticsLoadRequested(sortOrder: event.sortOrder));
      return;
    }

    final analytics = VillageAnalyticsCalculator.compute(
      villages: _cachedVillages,
      patients: _cachedPatients,
      screenings: _cachedScreenings,
      selectedVillageId: state.selectedVillageId,
      sortOrder: event.sortOrder,
    );

    emit(state.copyWith(
      status: VillageAnalyticsStatus.success,
      analytics: analytics,
      sortOrder: event.sortOrder,
    ));
  }

  Future<void> _onRefreshRequested(
    VillageAnalyticsRefreshRequested event,
    Emitter<VillageAnalyticsState> emit,
  ) async {
    await _fetchAndCompute(
      emit: emit,
      villageId: state.selectedVillageId,
      sortOrder: state.sortOrder,
    );
  }
}
