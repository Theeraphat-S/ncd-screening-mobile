import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/repositories/repository_errors.dart';
import 'package:ncd_screening_mobile/domain/services/auth_attempt_guard.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';
import 'package:ncd_screening_mobile/feature/auth/bloc/auth_bloc.dart';
import 'package:ncd_screening_mobile/feature/auth/session_flow.dart';
import 'package:ncd_screening_mobile/feature/auth/widgets/pin_unlock_view.dart';
import 'package:ncd_screening_mobile/shared/bloc/app_lock/app_lock_cubit.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';
import 'package:ncd_screening_mobile/shared/utils/provider_lookup.dart';

/// Wraps the whole app:
/// - feeds touches to the idle timer and re-checks the idle time when the
///   app returns to the foreground;
/// - covers the UI with a lock screen once the session has been idle too
///   long. The page stack underneath is kept, so unlocking returns the user
///   exactly where they were;
/// - hides everything while the app is in the background, so the app
///   switcher never shows patient data;
/// - shows a final screen once too many wrong PINs / passwords wiped (Spoke)
///   or locked (Hub) the device.
class AppLockGate extends StatefulWidget {
  final Widget child;

  /// Hide the UI on [AppLifecycleState.inactive] too. Phones go inactive
  /// when the app switcher opens; desktops go inactive whenever the window
  /// loses focus, so by default the Hub only hides when minimised.
  final bool? hideWhenInactive;

  const AppLockGate({super.key, required this.child, this.hideWhenInactive});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  bool _inBackground = false;
  AttemptStatus? _terminal;
  StreamSubscription<AttemptStatus>? _terminalSub;

  bool get _hideWhenInactive =>
      widget.hideWhenInactive ??
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final guard = tryRead<AuthAttemptGuard>(context);
    if (guard != null) {
      _terminalSub = guard.terminalStates.listen(_onTerminal);
      // A Hub that was locked out before a restart stays locked.
      guard.status().then((s) {
        if (s.isTerminal) _onTerminal(s);
      });
    }
  }

  @override
  void dispose() {
    _terminalSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onTerminal(AttemptStatus status) {
    if (!mounted) return;
    setState(() => _terminal = status);
    endSessionAfterLockout();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final hidden = switch (state) {
      AppLifecycleState.resumed => false,
      AppLifecycleState.inactive => _hideWhenInactive,
      AppLifecycleState.hidden ||
      AppLifecycleState.paused ||
      AppLifecycleState.detached =>
        true,
    };
    if (hidden != _inBackground) setState(() => _inBackground = hidden);
    if (state == AppLifecycleState.resumed) {
      context.read<AppLockCubit>().onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final terminal = _terminal;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => context.read<AppLockCubit>().onUserActivity(),
      child: Stack(
        children: [
          // Offstage keeps the page stack alive but paints nothing.
          Offstage(
            offstage: _inBackground || terminal != null,
            child: TickerMode(
              enabled: !_inBackground && terminal == null,
              child: BlocBuilder<AppLockCubit, AppLockState>(
                buildWhen: (a, b) =>
                    (a.status == AppLockStatus.locked) != (b.status == AppLockStatus.locked),
                builder: (context, lock) {
                  return Stack(
                    children: [
                      widget.child,
                      if (lock.status == AppLockStatus.locked)
                        Positioned.fill(
                          // Own Overlay so text fields / tooltips work above the Navigator.
                          child: Overlay(
                            initialEntries: [
                              OverlayEntry(builder: (_) => const LockScreen()),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          if (terminal != null)
            Positioned.fill(child: DeviceBlockedScreen(status: terminal))
          else if (_inBackground)
            const Positioned.fill(child: PrivacyCover()),
        ],
      ),
    );
  }
}

/// Shown instead of the app while it is in the background.
class PrivacyCover extends StatelessWidget {
  const PrivacyCover({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      key: Key('privacy_cover'),
      color: PColor.backgroundColor,
      child: Center(
        child: Icon(Icons.health_and_safety_rounded, size: 64, color: PColor.primaryColor),
      ),
    );
  }
}

/// Final screen after the attempt limit: data wiped (Spoke) or the device
/// locked (Hub). There is no way back into the app from here.
class DeviceBlockedScreen extends StatelessWidget {
  final AttemptStatus status;
  const DeviceBlockedScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final wiped = status.kind == AttemptKind.wiped;
    final canClose = defaultTargetPlatform == TargetPlatform.android;
    return Material(
      color: PColor.backgroundColor,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(PSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  Icon(
                    wiped ? Icons.delete_forever_rounded : Icons.lock_rounded,
                    size: 48,
                    color: PColor.riskHigh,
                  ),
                  PSpacing.gapVerticalMd,
                  Text(
                    status.message(''),
                    textAlign: TextAlign.center,
                    style: PTypography.pageTitle,
                  ),
                  PSpacing.gapVerticalMd,
                  Text(
                    wiped
                        ? 'ปิดแอปแล้วนำเครื่องไปให้ รพ.สต. ตั้งค่าใหม่จากเครื่อง Hub '
                            'ข้อมูลที่ยังไม่ได้ส่งเข้า Hub กู้คืนไม่ได้'
                        : 'เครื่อง Hub ไม่ลบข้อมูลเอง เพราะเป็นสำเนาหลักของ รพ.สต. '
                            'ข้อมูลยังอยู่ครบ แต่ต้องให้ผู้ดูแลระบบปลดล็อก',
                    textAlign: TextAlign.center,
                    style: PTypography.bodyMuted,
                  ),
                  if (wiped && canClose) ...[
                    PSpacing.gapVerticalXxl,
                    const ElevatedButton(
                      onPressed: SystemNavigator.pop,
                      child: Text('ปิดแอป'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _passwordMode = false;
  Future<bool>? _hasPin;

  @override
  void initState() {
    super.initState();
    final userId = staffUserId(context.read<AuthBloc>().state.currentUser);
    _hasPin = userId == null
        ? Future.value(false)
        : context.read<PinService>().hasPin(userId);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.currentUser;
    final userId = staffUserId(user);
    final name = user is VHV ? user.fullName : (user is Nurse ? user.fullName : '');

    return Scaffold(
      backgroundColor: PColor.backgroundColor,
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: _hasPin,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (userId != null && snapshot.data! && !_passwordMode) {
              return PinUnlockView(
                userId: userId,
                title: 'หน้าจอถูกล็อก',
                subtitle: name.isEmpty ? 'กรอก PIN เพื่อใช้งานต่อ' : '$name\nกรอก PIN เพื่อใช้งานต่อ',
                onUnlocked: () => context.read<AppLockCubit>().unlock(),
                onPinUnavailable: () => setState(() => _passwordMode = true),
                onUsePassword: () => setState(() => _passwordMode = true),
              );
            }
            return _PasswordUnlock(user: user, name: name);
          },
        ),
      ),
    );
  }
}

class _PasswordUnlock extends StatefulWidget {
  final dynamic user;
  final String name;
  const _PasswordUnlock({required this.user, required this.name});

  @override
  State<_PasswordUnlock> createState() => _PasswordUnlockState();
}

class _PasswordUnlockState extends State<_PasswordUnlock> {
  final _controller = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = widget.user;
    final role = user is VHV ? UserRole.vhv : UserRole.nurse;
    final id = staffUserId(user);
    if (id == null) {
      signOut();
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    const wrongPassword = 'รหัสผ่านไม่ถูกต้อง';
    final repo = context.read<NcdRepositoryInterface>();
    final guard = tryRead<AuthAttemptGuard>(context);
    Future<bool> verify() async {
      try {
        await repo.login(role: role, identifier: id, password: _controller.text);
        return true;
      } on InvalidCredentialsException {
        return false;
      }
    }

    String? error;
    try {
      if (guard == null) {
        if (!await verify()) error = wrongPassword;
      } else {
        final result = await guard.attempt(verify);
        if (result.kind != AttemptKind.success) {
          error = result.message(wrongPassword);
        }
      }
    } catch (_) {
      error = 'ปลดล็อกไม่สำเร็จ กรุณาลองใหม่';
    }
    if (!mounted) return;
    if (error == null) {
      context.read<AppLockCubit>().unlock();
    } else {
      setState(() {
        _busy = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(PSpacing.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_rounded, size: 40, color: PColor.primaryColor),
              PSpacing.gapVerticalMd,
              const Text(
                'หน้าจอถูกล็อก',
                textAlign: TextAlign.center,
                style: PTypography.pageTitle,
              ),
              if (widget.name.isNotEmpty) ...[
                PSpacing.gapVerticalSm,
                Text(widget.name, textAlign: TextAlign.center),
              ],
              PSpacing.gapVerticalXxl,
              TextField(
                controller: _controller,
                obscureText: true,
                autofocus: true,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'รหัสผ่าน',
                  errorText: _error,
                  border: const OutlineInputBorder(),
                ),
              ),
              PSpacing.gapVerticalLg,
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _busy ? null : _submit,
                  child: const Text('ปลดล็อก'),
                ),
              ),
              const TextButton(
                onPressed: signOut,
                child: Text('ออกจากระบบ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
