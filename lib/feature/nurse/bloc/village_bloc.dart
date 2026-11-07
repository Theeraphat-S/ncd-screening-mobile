import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';

// EVENTS
abstract class VillageEvent extends Equatable {
  const VillageEvent();
  @override
  List<Object?> get props => [];
}

class VillageListLoadRequested extends VillageEvent {}

class VillageSelected extends VillageEvent {
  final Village village;
  const VillageSelected(this.village);
  @override
  List<Object?> get props => [village];
}

// STATES
enum VillageStatus { initial, loading, success, failure }

class VillageState extends Equatable {
  final VillageStatus status;
  final List<Village> villages;
  final Village? selectedVillage;
  final String? errorMessage;

  const VillageState({
    this.status = VillageStatus.initial,
    this.villages = const [],
    this.selectedVillage,
    this.errorMessage,
  });

  VillageState copyWith({
    VillageStatus? status,
    List<Village>? villages,
    Village? selectedVillage,
    String? errorMessage,
  }) {
    return VillageState(
      status: status ?? this.status,
      villages: villages ?? this.villages,
      selectedVillage: selectedVillage ?? this.selectedVillage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, villages, selectedVillage, errorMessage];
}

// BLOC
class VillageBloc extends Bloc<VillageEvent, VillageState> {
  final NcdRepositoryInterface repository;

  VillageBloc(this.repository) : super(const VillageState()) {
    on<VillageListLoadRequested>((event, emit) async {
      emit(state.copyWith(status: VillageStatus.loading, errorMessage: null));
      try {
        final list = await repository.getVillages();
        emit(state.copyWith(status: VillageStatus.success, villages: list));
      } catch (e) {
        emit(
          state.copyWith(
            status: VillageStatus.failure,
            errorMessage: 'ไม่พบข้อมูล',
          ),
        );
      }
    });

    on<VillageSelected>((event, emit) {
      emit(state.copyWith(selectedVillage: event.village));
    });
  }
}
