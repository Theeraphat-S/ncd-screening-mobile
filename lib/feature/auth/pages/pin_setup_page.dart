import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/data/services/device_security_services.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';
import 'package:ncd_screening_mobile/feature/auth/widgets/pin_pad.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';

/// Lets a staff member create a 6-digit PIN (and optionally biometric unlock)
/// right after signing in with their password.
class PinSetupPage extends StatefulWidget {
  final String userId;

  /// Called after the PIN is saved or the step is skipped.
  final void Function(BuildContext context) onFinished;

  const PinSetupPage({super.key, required this.userId, required this.onFinished});

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
    return Scaffold(
      backgroundColor: PColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: PColor.primaryColor,
        automaticallyImplyLeading: false,
        title: const Text(
          'ตั้งรหัส PIN',
          style: PTypography.appBarTitle,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 40, color: PColor.primaryColor),
                  const SizedBox(height: 12),
                  Text(
                    confirming ? 'ยืนยัน PIN อีกครั้ง' : 'ตั้ง PIN 6 หลัก',
                    style: PTypography.pageTitle,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'ใช้เข้าแอปครั้งต่อไปแทนการกรอกรหัสผ่าน',
                    textAlign: TextAlign.center,
                    style: PTypography.bodyMuted,
                  ),
                  const SizedBox(height: 24),
                  PinPad(onCompleted: _onPin, enabled: !_saving, errorText: _error),
                  if (_biometricAvailable) ...[
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('ใช้ลายนิ้วมือ / ใบหน้าปลดล็อก'),
                      value: _useBiometric,
                      onChanged: (v) => setState(() => _useBiometric = v),
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _saving ? null : () => widget.onFinished(context),
                    child: const Text('ข้ามไปก่อน (ใช้รหัสผ่านครั้งหน้า)'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
