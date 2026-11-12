import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';

// EVENTS
abstract class PatientEvent extends Equatable {
  const PatientEvent();
  @override
  List<Object?> get props => [];
}

class PatientLoadRequested extends PatientEvent {
  final String? villageId;
  final String? searchQuery;
  const PatientLoadRequested({this.villageId, this.searchQuery});
  @override
  List<Object?> get props => [villageId, searchQuery];
}

class PatientSearchChanged extends PatientEvent {
  final String query;
  final String? villageId;
  const PatientSearchChanged(this.query, {this.villageId});
  @override
  List<Object?> get props => [query, villageId];
}

class PatientSelected extends PatientEvent {
  final Patient patient;
  const PatientSelected(this.patient);
  @override
  List<Object?> get props => [patient];
}

class PatientAddRequested extends PatientEvent {
  final Patient patient;
  const PatientAddRequested(this.patient);
  @override
  List<Object?> get props => [patient];
}

class PatientUpdateRequested extends PatientEvent {
  final Patient patient;
  const PatientUpdateRequested(this.patient);
  @override
  List<Object?> get props => [patient];
}

class PatientDeleteRequested extends PatientEvent {
  final String patientId;
  const PatientDeleteRequested(this.patientId);
  @override
  List<Object?> get props => [patientId];
}

// STATES
enum PatientStatus { initial, loading, success, failure }

class PatientState extends Equatable {
  final PatientStatus status;
  final List<Patient> patients;
  final Patient? selectedPatient;
  final String? currentVillageId;
  final String? searchQuery;
  final String? message;
  final String? errorMessage;

  const PatientState({
    this.status = PatientStatus.initial,
    this.patients = const [],
    this.selectedPatient,
    this.currentVillageId,
    this.searchQuery,
    this.message,
    this.errorMessage,
  });

  PatientState copyWith({
    PatientStatus? status,
    List<Patient>? patients,
    Patient? selectedPatient,
    String? currentVillageId,
    String? searchQuery,
    String? message,
    String? errorMessage,
  }) {
    return PatientState(
      status: status ?? this.status,
      patients: patients ?? this.patients,
      selectedPatient: selectedPatient ?? this.selectedPatient,
      currentVillageId: currentVillageId ?? this.currentVillageId,
      searchQuery: searchQuery ?? this.searchQuery,
      message: message,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        patients,
        selectedPatient,
        currentVillageId,
        searchQuery,
        message,
        errorMessage,
      ];
}

// BLOC
class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final NcdRepositoryInterface repository;

  PatientBloc(this.repository) : super(const PatientState()) {
    on<PatientLoadRequested>((event, emit) async {
      emit(state.copyWith(
        status: PatientStatus.loading,
        currentVillageId: event.villageId,
        searchQuery: event.searchQuery,
        errorMessage: null,
      ));
      try {
        final patients = await repository.getPatients(
          villageId: event.villageId,
          searchQuery: event.searchQuery,
        );
        emit(state.copyWith(
          status: PatientStatus.success,
          patients: patients,
          errorMessage: null,
        ));
      } catch (e) {
        emit(state.copyWith(
          status: PatientStatus.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    });

    on<PatientSearchChanged>((event, emit) async {
      emit(state.copyWith(
        status: PatientStatus.loading,
        searchQuery: event.query,
      ));
      try {
        final patients = await repository.getPatients(
          villageId: event.villageId ?? state.currentVillageId,
          searchQuery: event.query,
        );
        // A newer keystroke already started another search: drop this stale
        // answer so slow results cannot overwrite fresher ones.
        if (state.searchQuery != event.query) return;
        emit(state.copyWith(
          status: PatientStatus.success,
          patients: patients,
          searchQuery: event.query,
        ));
      } catch (e) {
        emit(state.copyWith(
          status: PatientStatus.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    });

    on<PatientSelected>((event, emit) {
      emit(state.copyWith(selectedPatient: event.patient));
    });

    on<PatientAddRequested>((event, emit) async {
      emit(state.copyWith(status: PatientStatus.loading));
      try {
        final newPatient = await repository.addPatient(event.patient);
        final updatedList = [newPatient, ...state.patients];
        emit(state.copyWith(
          status: PatientStatus.success,
          patients: updatedList,
          selectedPatient: newPatient,
          message: 'บันทึกข้อมูลผู้ป่วยสำเร็จ',
        ));
      } catch (e) {
        emit(state.copyWith(
          status: PatientStatus.failure,
          errorMessage: 'บันทึกข้อมูล ผู้ป่วย ไม่สำเร็จ',
        ));
      }
    });

    on<PatientUpdateRequested>((event, emit) async {
      emit(state.copyWith(status: PatientStatus.loading));
      try {
        final updated = await repository.updatePatient(event.patient);
        final updatedList = state.patients
            .map((p) => p.patientId == updated.patientId ? updated : p)
            .toList();
        emit(state.copyWith(
          status: PatientStatus.success,
          patients: updatedList,
          selectedPatient: updated,
          message: 'แก้ไขข้อมูลผู้ป่วยสำเร็จ',
        ));
      } catch (e) {
        emit(state.copyWith(
          status: PatientStatus.failure,
          errorMessage: 'แก้ไขผู้ป่วย ไม่สำเร็จ',
        ));
      }
    });

    on<PatientDeleteRequested>((event, emit) async {
      emit(state.copyWith(status: PatientStatus.loading));
      try {
        final success = await repository.deletePatient(event.patientId);
        if (success) {
          final updatedList = state.patients
              .where((p) => p.patientId != event.patientId)
              .toList();
          emit(state.copyWith(
            status: PatientStatus.success,
            patients: updatedList,
            selectedPatient: null,
            message: 'ลบข้อมูลผู้ป่วยสำเร็จ',
          ));
        } else {
          emit(state.copyWith(
            status: PatientStatus.failure,
            errorMessage: 'ลบผู้ป่วย ไม่สำเร็จ',
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          status: PatientStatus.failure,
          errorMessage: 'ลบผู้ป่วย ไม่สำเร็จ',
        ));
      }
    });
  }
}
