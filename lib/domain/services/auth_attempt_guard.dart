import 'dart:async';

import 'package:ncd_screening_mobile/domain/services/pin_service.dart';

/// Where this install sits in the offline sync design (ADR 0010).
enum DeviceRole {
  /// The รพ.สต. Windows PC. Holds the master copy, so it never wipes itself.
  hub,

  /// An อสม. / nurse phone. Can be re-provisioned from the Hub.
  spoke,
}

/// Erases everything this app keeps on the device.
abstract class DeviceWiper {
  Future<void> wipe();
}

enum AttemptKind {
  /// No wait: a credential may be checked now.
  ready,

  /// The credential was correct.
  success,

  /// Wrong credential; another try is allowed straight away.
  rejected,

  /// Too many failures: wait [AttemptStatus.wait] before the next try.
  delayed,

  /// Hub only: the failure limit was reached and the device stays locked.
  lockedOut,

  /// Spoke only: the failure limit was reached and local data was erased.
  wiped,
}

class AttemptStatus {
  final AttemptKind kind;

  /// Consecutive failures counted so far.
  final int failures;

  /// Time left before another try is accepted ([AttemptKind.delayed]).
  final Duration wait;

  final DeviceRole role;

  const AttemptStatus(
    this.kind, {
    required this.role,
    this.failures = 0,
    this.wait = Duration.zero,
  });

  bool get isTerminal =>
      kind == AttemptKind.lockedOut || kind == AttemptKind.wiped;

  /// True when a credential may be checked now.
  bool get allowsAttempt =>
      kind == AttemptKind.ready ||
      kind == AttemptKind.success ||
      kind == AttemptKind.rejected;

  /// Thai text for the user. [rejectedMessage] is used for a plain wrong
  /// credential (it differs between the PIN pad and the password form).
  String message(String rejectedMessage) {
    switch (kind) {
      case AttemptKind.ready:
      case AttemptKind.success:
        return '';
      case AttemptKind.rejected:
        final left = AuthAttemptGuard.freeFailures - failures;
        if (left > 0 && left <= 2) {
          return '$rejectedMessage (ผิดอีก $left ครั้งจะต้องรอก่อนลองใหม่)';
        }
        return rejectedMessage;
      case AttemptKind.delayed:
        final left = AuthAttemptGuard.maxFailures - failures;
        final consequence = role == DeviceRole.spoke
            ? 'ถ้าผิดอีก $left ครั้ง ข้อมูลในเครื่องนี้จะถูกลบ'
            : 'ถ้าผิดอีก $left ครั้ง เครื่องนี้จะถูกล็อก';
        return 'ใส่รหัสผิดหลายครั้ง กรุณารอ ${formatWait(wait)} แล้วลองใหม่ · $consequence';
      case AttemptKind.lockedOut:
        return 'เครื่องนี้ถูกล็อก เพราะใส่รหัสผิด ${AuthAttemptGuard.maxFailures} ครั้ง '
            'กรุณาติดต่อผู้ดูแลระบบ';
      case AttemptKind.wiped:
        return 'ใส่รหัสผิด ${AuthAttemptGuard.maxFailures} ครั้ง '
            'ข้อมูลในเครื่องนี้ถูกลบแล้ว';
    }
  }

  static String formatWait(Duration d) {
    final seconds = d.inSeconds + (d.inMilliseconds % 1000 > 0 ? 1 : 0);
    if (seconds < 60) return '$seconds วินาที';
    final minutes = (seconds / 60).ceil();
    return '$minutes นาที';
  }
}

/// One failure counter for every staff credential on this device, PIN and
/// password alike (ADR 0011).
///
/// - Failures 1–4: retry at once.
/// - From the 5th failure: a growing wait before the next try.
/// - The 10th consecutive failure wipes a Spoke and locks a Hub for good
///   (a Hub recovery code is planned, not built yet).
///
/// The counter and the wait survive an app restart: they live in the
/// [SecureStore], not in memory.
class AuthAttemptGuard {
  static const freeFailures = 5;
  static const maxFailures = 10;

  /// Wait imposed after failure number 5, 6, 7, 8 and 9.
  static const delays = [
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 2),
    Duration(minutes: 5),
    Duration(minutes: 15),
  ];

  static const _failuresKey = 'auth_failures';
  static const _blockedUntilKey = 'auth_blocked_until';

  final SecureStore _store;
  final DeviceRole role;
  final DeviceWiper _wiper;
  final DateTime Function() _now;

  final _terminal = StreamController<AttemptStatus>.broadcast();
  bool _wiped = false;
  Future<void> _queue = Future.value();

  AuthAttemptGuard({
    required SecureStore store,
    required this.role,
    required DeviceWiper wiper,
    DateTime Function()? now,
  })  : _store = store,
        _wiper = wiper,
        _now = now ?? DateTime.now;

  /// Emits once when the device is locked out or wiped.
  Stream<AttemptStatus> get terminalStates => _terminal.stream;

  static Duration delayAfter(int failures) {
    if (failures < freeFailures) return Duration.zero;
    final i = (failures - freeFailures).clamp(0, delays.length - 1);
    return delays[i];
  }

  /// Whether a credential may be checked right now.
  Future<AttemptStatus> status() => _serial(_status);

  /// Runs [verify] (true = correct credential) when allowed, and counts the
  /// result. Errors thrown by [verify] are not counted and are rethrown.
  Future<AttemptStatus> attempt(Future<bool> Function() verify) =>
      _serial(() async {
        final gate = await _status();
        if (!gate.allowsAttempt) return gate;

        if (await verify()) {
          await _store.delete(_failuresKey);
          await _store.delete(_blockedUntilKey);
          return AttemptStatus(AttemptKind.success, role: role);
        }
        return _recordFailure(gate.failures + 1);
      });

  Future<AttemptStatus> _status() async {
    if (_wiped) {
      return AttemptStatus(AttemptKind.wiped, role: role, failures: maxFailures);
    }
    final failures = int.tryParse(await _store.read(_failuresKey) ?? '') ?? 0;
    if (failures >= maxFailures) {
      // Only a Hub can get here: a Spoke erases the counter with its data.
      return AttemptStatus(AttemptKind.lockedOut, role: role, failures: failures);
    }
    final until = int.tryParse(await _store.read(_blockedUntilKey) ?? '');
    if (until != null) {
      final wait = DateTime.fromMillisecondsSinceEpoch(until).difference(_now());
      if (wait > Duration.zero) {
        // A clock moved backwards must not stretch the wait.
        final capped = wait > delayAfter(failures) ? delayAfter(failures) : wait;
        return AttemptStatus(AttemptKind.delayed,
            role: role, failures: failures, wait: capped);
      }
    }
    return AttemptStatus(AttemptKind.ready, role: role, failures: failures);
  }

  Future<AttemptStatus> _recordFailure(int failures) async {
    await _store.write(_failuresKey, '$failures');

    if (failures >= maxFailures) {
      final AttemptStatus result;
      if (role == DeviceRole.spoke) {
        await _wiper.wipe();
        _wiped = true;
        result = AttemptStatus(AttemptKind.wiped, role: role, failures: failures);
      } else {
        await _store.delete(_blockedUntilKey);
        result =
            AttemptStatus(AttemptKind.lockedOut, role: role, failures: failures);
      }
      _terminal.add(result);
      return result;
    }

    final delay = delayAfter(failures);
    if (delay == Duration.zero) {
      return AttemptStatus(AttemptKind.rejected, role: role, failures: failures);
    }
    await _store.write(
      _blockedUntilKey,
      '${_now().add(delay).millisecondsSinceEpoch}',
    );
    return AttemptStatus(AttemptKind.delayed,
        role: role, failures: failures, wait: delay);
  }

  Future<T> _serial<T>(Future<T> Function() action) {
    final result = _queue.then((_) => action());
    _queue = result.then((_) {}, onError: (_) {});
    return result;
  }

  Future<void> dispose() => _terminal.close();
}
