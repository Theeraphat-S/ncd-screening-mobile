import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/repositories/repository_errors.dart';
import 'package:ncd_screening_mobile/domain/services/auth_attempt_guard.dart';

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
  final DateTime? birthDate;

  const AuthLoginSubmitted({
    required this.role,
    required this.identifier,
    this.password,
    this.birthDate,
  });

  @override
  List<Object?> get props => [role, identifier, password, birthDate];
}

/// Restores a staff session after PIN / biometric verification (no password).
class AuthSessionRestored extends AuthEvent {
  final UserRole role;
  final dynamic user; // VHV | Nurse
  const AuthSessionRestored({required this.role, required this.user});
  @override
  List<Object?> get props => [role, user];
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

  /// Rate-limits staff password sign-in together with PIN unlock. Without
  /// one (some tests), staff sign-in is not limited.
  final AuthAttemptGuard? attemptGuard;

  AuthBloc(this.repository, {this.attemptGuard}) : super(const AuthState()) {
    on<AuthSelectRole>((event, emit) {
      emit(state.copyWith(
        selectedRole: event.role,
        status: AuthStatus.unauthenticated,
        errorMessage: null,
      ));
    });

    on<AuthLoginSubmitted>((event, emit) async {
      emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
      try {
        final dynamic user;
        final guard = attemptGuard;
        if (guard != null && event.role != UserRole.patient) {
          dynamic signedIn;
          var rejection = '';
          final result = await guard.attempt(() async {
            try {
              signedIn = await repository.login(
                role: event.role,
                identifier: event.identifier,
                password: event.password,
              );
              return true;
            } on InvalidCredentialsException catch (e) {
              rejection = e.message;
              return false;
            }
          });
          if (result.kind != AttemptKind.success) {
            emit(state.copyWith(
              status: AuthStatus.error,
              errorMessage: result.message(rejection),
            ));
            return;
          }
          user = signedIn;
        } else {
          user = await repository.login(
            role: event.role,
            identifier: event.identifier,
            password: event.password,
            birthDate: event.birthDate,
          );
        }
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          selectedRole: event.role,
          currentUser: user,
          errorMessage: null,
        ));
      } catch (e) {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    });

    on<AuthSessionRestored>((event, emit) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        selectedRole: event.role,
        currentUser: event.user,
        errorMessage: null,
      ));
    });

    on<AuthLogoutRequested>((event, emit) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    });
  }
}
