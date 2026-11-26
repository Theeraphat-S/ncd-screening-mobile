import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/data/services/device_security_services.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';
import 'package:ncd_screening_mobile/feature/auth/widgets/pin_pad.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

/// Makes a staff member create a 6-digit PIN (and optionally biometric
/// unlock) right after signing in with their password. The PIN is mandatory
/// for staff (ADR 0011), so this step cannot be skipped.
class PinSetupPage extends StatefulWidget {
  final String userId;

  /// Called after the PIN is saved.
  final void Function(BuildContext context) onFinished;

  /// Signs out instead of setting a PIN. Back navigation is blocked, so this
  /// is the only other way off the page.
  final VoidCallback? onSignOut;

  const PinSetupPage({
    super.key,
    required this.userId,
    required this.onFinished,
    this.onSignOut,
  });

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  String? _firstEntry;
  String? _error;
  bool _biometricAvailable = false;
  bool _useBiometric = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    context.read<BiometricService>().isAvailable().then((available) {
      if (mounted) setState(() => _biometricAvailable = available);
    });
  }

  Future<void> _onPin(String pin) async {
    if (_firstEntry == null) {
      setState(() {
        _firstEntry = pin;
        _error = null;
      });
      return;
    }
    if (pin != _firstEntry) {
      setState(() {
        _firstEntry = null;
        _error = 'PIN ไม่ตรงกัน กรุณาตั้งใหม่';
      });
      return;
    }
    setState(() => _saving = true);
    final pins = context.read<PinService>();
    final session = context.read<DeviceSessionStore>();
    try {
      await pins.setPin(widget.userId, pin);
      await session.setBiometricEnabled(widget.userId, _useBiometric);
      if (mounted) widget.onFinished(context);
    } on PinFormatError catch (e) {
      setState(() {
        _firstEntry = null;
        _saving = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final confirming = _firstEntry != null;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: PColor.backgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('ตั้งรหัส PIN'),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(PSpacing.xxl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 40,
                      color: PColor.primaryColor,
                    ),
                    PSpacing.gapVerticalMd,
                    Text(
                      confirming ? 'ยืนยัน PIN อีกครั้ง' : 'ตั้ง PIN 6 หลัก',
                      style: PTypography.pageTitle,
                    ),
                    PSpacing.gapVerticalSm,
                    const Text(
                      'ใช้ปลดล็อกแอปและเข้าใช้ครั้งต่อไป ทุกบัญชีเจ้าหน้าที่ต้องตั้ง PIN',
                      textAlign: TextAlign.center,
                      style: PTypography.bodyMuted,
                    ),
                    PSpacing.gapVerticalXxl,
                    PinPad(
                      onCompleted: _onPin,
                      enabled: !_saving,
                      errorText: _error,
                    ),
                    if (_biometricAvailable) ...[
                      PSpacing.gapVerticalSm,
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('ใช้ลายนิ้วมือ / ใบหน้าปลดล็อก'),
                        value: _useBiometric,
                        onChanged: (v) => setState(() => _useBiometric = v),
                      ),
                    ],
                    if (widget.onSignOut != null) ...[
                      PSpacing.gapVerticalSm,
                      TextButton(
                        onPressed: _saving ? null : widget.onSignOut,
                        child: const Text('ออกจากระบบ'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
