import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/data/services/device_security_services.dart';
import 'package:ncd_screening_mobile/domain/services/auth_attempt_guard.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';
import 'package:ncd_screening_mobile/feature/auth/widgets/pin_pad.dart';
import 'package:ncd_screening_mobile/shared/utils/provider_lookup.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

/// PIN (or biometric) challenge shared by the cold-start quick login and the
/// idle lock screen.
class PinUnlockView extends StatefulWidget {
  final String userId;
  final String title;
  final String? subtitle;
  final VoidCallback onUnlocked;

  /// No PIN is set for [userId]: the caller must fall back to a full
  /// password login.
  final VoidCallback onPinUnavailable;
  final VoidCallback onUsePassword;

  const PinUnlockView({
    super.key,
    required this.userId,
    required this.title,
    this.subtitle,
    required this.onUnlocked,
    required this.onPinUnavailable,
    required this.onUsePassword,
  });

  @override
  State<PinUnlockView> createState() => _PinUnlockViewState();
}

class _PinUnlockViewState extends State<PinUnlockView> {
  String? _error;
  bool _busy = false;
  bool _biometricReady = false;

  static const _wrongPin = 'PIN ไม่ถูกต้อง';

  AuthAttemptGuard? _guard;

  @override
  void initState() {
    super.initState();
    _guard = tryRead<AuthAttemptGuard>(context);
    _showPendingWait();
    _prepareBiometric();
  }

  /// A wait started before this screen opened (e.g. before a restart) is
  /// shown straight away instead of after the next wrong PIN.
  Future<void> _showPendingWait() async {
    final status = await _guard?.status();
    if (status == null || status.allowsAttempt || !mounted) return;
    setState(() => _error = status.message(_wrongPin));
  }

  Future<void> _prepareBiometric() async {
    final session = context.read<DeviceSessionStore>();
    final biometric = context.read<BiometricService>();
    final enabled = await session.isBiometricEnabled(widget.userId);
    final available = enabled && await biometric.isAvailable();
    if (!mounted) return;
    setState(() => _biometricReady = available);
    if (available) _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    final guard = _guard;
    // Biometrics may not skip a wait or a lock-out, and a cancelled prompt
    // is not a wrong credential, so only a success goes through the guard.
    if (guard != null && !(await guard.status()).allowsAttempt) return;
    if (!mounted) return;
    final ok = await context.read<BiometricService>().authenticate('ยืนยันตัวตนเพื่อเข้าใช้งาน');
    if (!ok || !mounted) return;
    if (guard != null && (await guard.attempt(() async => true)).kind != AttemptKind.success) {
      return;
    }
    if (mounted) widget.onUnlocked();
  }

  Future<void> _onPin(String pin) async {
    setState(() => _busy = true);
    final pins = context.read<PinService>();
    if (!await pins.hasPin(widget.userId)) {
      if (mounted) widget.onPinUnavailable();
      return;
    }
    final guard = _guard;
    if (guard == null) {
      final ok = await pins.verifyPin(widget.userId, pin) == PinResult.ok;
      if (!mounted) return;
      ok ? widget.onUnlocked() : _showError(_wrongPin);
      return;
    }
    final result = await guard.attempt(
      () async => await pins.verifyPin(widget.userId, pin) == PinResult.ok,
    );
    if (!mounted) return;
    if (result.kind == AttemptKind.success) {
      widget.onUnlocked();
    } else {
      _showError(result.message(_wrongPin));
    }
  }

  void _showError(String message) {
    setState(() {
      _busy = false;
      _error = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(PSpacing.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            children: [
              const Icon(Icons.lock_rounded, size: 40, color: PColor.primaryColor),
              PSpacing.gapVerticalMd,
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: PTypography.pageTitle,
              ),
              if (widget.subtitle != null) ...[
                PSpacing.gapVerticalSm,
                Text(
                  widget.subtitle!,
                  textAlign: TextAlign.center,
                  style: PTypography.bodyMuted,
                ),
              ],
              PSpacing.gapVerticalXxl,
              PinPad(
                onCompleted: _onPin,
                enabled: !_busy,
                errorText: _error,
                leadingAction: _biometricReady
                    ? IconButton(
                        tooltip: 'ใช้ลายนิ้วมือ / ใบหน้า',
                        onPressed: _tryBiometric,
                        icon: const Icon(Icons.fingerprint_rounded, size: 30),
                      )
                    : null,
              ),
              PSpacing.gapVerticalSm,
              TextButton(
                onPressed: widget.onUsePassword,
                child: const Text('ใช้รหัสผ่านแทน / ออกจากระบบ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
