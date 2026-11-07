import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';

// EVENTS
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthSelectRole extends AuthEvent {
  final UserRole role;
  const AuthSelectRole(this.role);
  @override
  List<Object?> get props => [role];
}

class AuthLoginSubmitted extends AuthEvent {
  final UserRole role;
  final String identifier;
  final String? password;

  const AuthLoginSubmitted({
    required this.role,
    required this.identifier,
    this.password,
  });

  @override
  List<Object?> get props => [role, identifier, password];
}

class AuthLogoutRequested extends AuthEvent {}

// STATES
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserRole? selectedRole;
  final dynamic currentUser; // Patient | VHV | Nurse
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.selectedRole,
    this.currentUser,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserRole? selectedRole,
    dynamic currentUser,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      selectedRole: selectedRole ?? this.selectedRole,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, selectedRole, currentUser, errorMessage];
}

// BLOC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final NcdRepositoryInterface repository;

  AuthBloc(this.repository) : super(const AuthState()) {
    on<AuthSelectRole>((event, emit) {
      emit(
        state.copyWith(
          selectedRole: event.role,
          status: AuthStatus.unauthenticated,
          errorMessage: null,
        ),
      );
    });

    on<AuthLoginSubmitted>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
      try {
        final user = await repository.login(
          role: event.role,
          identifier: event.identifier,
          password: event.password,
        );
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            selectedRole: event.role,
            currentUser: user,
            errorMessage: null,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: e.toString().replaceAll('Exception: ', ''),
          ),
        );
      }
    });

    on<AuthLogoutRequested>((event, emit) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    });
  }
}
