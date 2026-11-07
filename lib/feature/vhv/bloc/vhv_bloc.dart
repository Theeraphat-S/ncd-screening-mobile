import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';

// EVENTS
abstract class VhvEvent extends Equatable {
  const VhvEvent();
  @override
  List<Object?> get props => [];
}

class VhvListLoadRequested extends VhvEvent {
  final String? villageId;
  const VhvListLoadRequested({this.villageId});
  @override
  List<Object?> get props => [villageId];
}

class VhvSelected extends VhvEvent {
  final VHV vhv;
  const VhvSelected(this.vhv);
  @override
  List<Object?> get props => [vhv];
}

class VhvAddRequested extends VhvEvent {
  final VHV vhv;
  const VhvAddRequested(this.vhv);
  @override
  List<Object?> get props => [vhv];
}

class VhvUpdateRequested extends VhvEvent {
  final VHV vhv;
  const VhvUpdateRequested(this.vhv);
  @override
  List<Object?> get props => [vhv];
}

// STATES
enum VhvStatus { initial, loading, success, failure }

class VhvState extends Equatable {
  final VhvStatus status;
  final List<VHV> vhvs;
  final VHV? selectedVhv;
  final String? currentVillageId;
  final String? message;
  final String? errorMessage;

  const VhvState({
    this.status = VhvStatus.initial,
    this.vhvs = const [],
    this.selectedVhv,
    this.currentVillageId,
    this.message,
    this.errorMessage,
  });

  VhvState copyWith({
    VhvStatus? status,
    List<VHV>? vhvs,
    VHV? selectedVhv,
    String? currentVillageId,
    String? message,
    String? errorMessage,
  }) {
    return VhvState(
      status: status ?? this.status,
      vhvs: vhvs ?? this.vhvs,
      selectedVhv: selectedVhv ?? this.selectedVhv,
      currentVillageId: currentVillageId ?? this.currentVillageId,
      message: message,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    vhvs,
    selectedVhv,
    currentVillageId,
    message,
    errorMessage,
  ];
}

// BLOC
class VhvBloc extends Bloc<VhvEvent, VhvState> {
  final NcdRepositoryInterface repository;

  VhvBloc(this.repository) : super(const VhvState()) {
    on<VhvListLoadRequested>((event, emit) async {
      emit(
        state.copyWith(
          status: VhvStatus.loading,
          currentVillageId: event.villageId,
          errorMessage: null,
        ),
      );
      try {
        final list = await repository.getVhvs(villageId: event.villageId);
        emit(state.copyWith(status: VhvStatus.success, vhvs: list));
      } catch (e) {
        emit(
          state.copyWith(
            status: VhvStatus.failure,
            errorMessage: 'ไม่พบข้อมูล',
          ),
        );
      }
    });

    on<VhvSelected>((event, emit) {
      emit(state.copyWith(selectedVhv: event.vhv));
    });

    on<VhvAddRequested>((event, emit) async {
      emit(state.copyWith(status: VhvStatus.loading));
      try {
        final newVhv = await repository.addVhv(event.vhv);
        emit(
          state.copyWith(
            status: VhvStatus.success,
            vhvs: [newVhv, ...state.vhvs],
            selectedVhv: newVhv,
            message: 'บันทึกข้อมูล อสม. สำเร็จ',
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            status: VhvStatus.failure,
            errorMessage: 'บันทึกการข้อมูล อสม ไม่สำเร็จ',
          ),
        );
      }
    });

    on<VhvUpdateRequested>((event, emit) async {
      emit(state.copyWith(status: VhvStatus.loading));
      try {
        final updated = await repository.updateVhv(event.vhv);
        final list = state.vhvs
            .map((v) => v.vhvId == updated.vhvId ? updated : v)
            .toList();
        emit(
          state.copyWith(
            status: VhvStatus.success,
            vhvs: list,
            selectedVhv: updated,
            message: 'แก้ไขข้อมูล อสม. สำเร็จ',
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            status: VhvStatus.failure,
            errorMessage: 'แก้ไขอสม ไม่สำเร็จ',
          ),
        );
      }
    });
  }
}
