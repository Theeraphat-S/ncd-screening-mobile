import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AppLockStatus { signedOut, unlocked, locked }

class AppLockState extends Equatable {
  final AppLockStatus status;
  const AppLockState(this.status);

  @override
  List<Object?> get props => [status];
}

/// Locks the app after a period of inactivity while a staff user is signed in.
class AppLockCubit extends Cubit<AppLockState> {
  static const defaultIdleTimeout = Duration(minutes: 15);

  final Duration idleTimeout;
  final DateTime Function() _now;
  Timer? _timer;
  DateTime? _lastActivity;

  AppLockCubit({
    this.idleTimeout = defaultIdleTimeout,
    DateTime Function()? now,
  })  : _now = now ?? DateTime.now,
        super(const AppLockState(AppLockStatus.signedOut));

  void startSession() {
    _emitAndArm(AppLockStatus.unlocked);
  }

  void endSession() {
    _timer?.cancel();
    _lastActivity = null;
    emit(const AppLockState(AppLockStatus.signedOut));
  }

  void unlock() {
    if (state.status == AppLockStatus.signedOut) return;
    _emitAndArm(AppLockStatus.unlocked);
  }

  void lock() {
    if (state.status != AppLockStatus.unlocked) return;
    _timer?.cancel();
    emit(const AppLockState(AppLockStatus.locked));
  }

  /// Call on any touch / key event. Ignored unless currently unlocked.
  void onUserActivity() {
    if (state.status != AppLockStatus.unlocked) return;
    _arm();
  }

  /// Timers can be suspended while the app is in the background, so compare
  /// wall-clock time when the app comes back to the foreground.
  void onAppResumed() {
    final last = _lastActivity;
    if (state.status == AppLockStatus.unlocked &&
        last != null &&
        _now().difference(last) >= idleTimeout) {
      lock();
    }
  }

  void _emitAndArm(AppLockStatus status) {
    emit(AppLockState(status));
    _arm();
  }

  void _arm() {
    _lastActivity = _now();
    _timer?.cancel();
    _timer = Timer(idleTimeout, lock);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
