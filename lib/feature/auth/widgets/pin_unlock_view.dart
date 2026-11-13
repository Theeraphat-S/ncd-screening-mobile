import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/data/services/device_security_services.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';
import 'package:ncd_screening_mobile/feature/auth/widgets/pin_pad.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';

/// PIN (or biometric) challenge shared by the cold-start quick login and the
/// idle lock screen.
class PinUnlockView extends StatefulWidget {
  final String userId;
  final String title;
  final String? subtitle;
  final VoidCallback onUnlocked;

  /// The PIN can no longer be used (not set, or too many wrong attempts):
  /// the caller must fall back to a full password login.
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

  @override
  void initState() {
    super.initState();
    _prepareBiometric();
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
    final ok = await context.read<BiometricService>().authenticate('ยืนยันตัวตนเพื่อเข้าใช้งาน');
    if (ok && mounted) widget.onUnlocked();
  }

  Future<void> _onPin(String pin) async {
    setState(() => _busy = true);
    final result = await context.read<PinService>().verifyPin(widget.userId, pin);
    if (!mounted) return;
    switch (result) {
      case PinResult.ok:
        widget.onUnlocked();
      case PinResult.wrong:
        setState(() {
          _busy = false;
          _error = 'PIN ไม่ถูกต้อง';
        });
      case PinResult.notSet:
      case PinResult.tooManyAttempts:
        widget.onPinUnavailable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            children: [
              const Icon(Icons.lock_rounded, size: 40, color: PColor.primaryColor),
              const SizedBox(height: 12),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: PTypography.pageTitle,
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  widget.subtitle!,
                  textAlign: TextAlign.center,
                  style: PTypography.bodyMuted,
                ),
              ],
              const SizedBox(height: 24),
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
              const SizedBox(height: 8),
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
