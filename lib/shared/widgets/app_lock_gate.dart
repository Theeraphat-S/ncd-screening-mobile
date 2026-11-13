import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';
import 'package:ncd_screening_mobile/feature/auth/bloc/auth_bloc.dart';
import 'package:ncd_screening_mobile/feature/auth/session_flow.dart';
import 'package:ncd_screening_mobile/feature/auth/widgets/pin_unlock_view.dart';
import 'package:ncd_screening_mobile/shared/bloc/app_lock/app_lock_cubit.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';

/// Wraps the whole app: feeds touches to the idle timer, re-checks the idle
/// time when the app returns to the foreground, and covers the UI with a lock
/// screen once the session has been idle too long. The page stack underneath
/// is kept, so unlocking returns the user exactly where they were.
class AppLockGate extends StatefulWidget {
  final Widget child;
  const AppLockGate({super.key, required this.child});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<AppLockCubit>().onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => context.read<AppLockCubit>().onUserActivity(),
      child: BlocBuilder<AppLockCubit, AppLockState>(
        buildWhen: (a, b) => (a.status == AppLockStatus.locked) != (b.status == AppLockStatus.locked),
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
    try {
      await context
          .read<NcdRepositoryInterface>()
          .login(role: role, identifier: id, password: _controller.text);
      if (mounted) context.read<AppLockCubit>().unlock();
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'รหัสผ่านไม่ถูกต้อง';
        });
      }
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_rounded, size: 40, color: PColor.primaryColor),
              const SizedBox(height: 12),
              const Text(
                'หน้าจอถูกล็อก',
                textAlign: TextAlign.center,
                style: PTypography.pageTitle,
              ),
              if (widget.name.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(widget.name, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 24),
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
              const SizedBox(height: 16),
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
