import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';
import 'package:ncd_screening_mobile/feature/auth/bloc/auth_bloc.dart';
import 'package:ncd_screening_mobile/feature/auth/pages/login_page.dart';
import 'package:ncd_screening_mobile/feature/auth/session_flow.dart';
import 'package:ncd_screening_mobile/feature/auth/widgets/pin_unlock_view.dart';
import 'package:ncd_screening_mobile/shared/bloc/app_lock/app_lock_cubit.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

/// Cold-start quick login for a staff member who already set a PIN.
class PinLoginPage extends StatelessWidget {
  final UserRole role;
  final String userId;
  final String displayName;

  const PinLoginPage({
    super.key,
    required this.role,
    required this.userId,
    required this.displayName,
  });

  Future<void> _onUnlocked(BuildContext context) async {
    final repo = context.read<NcdRepositoryInterface>();
    final pins = context.read<PinService>();
    final dynamic user =
        role == UserRole.vhv ? await repo.getVhvById(userId) : await repo.getNurseById(userId);
    if (!context.mounted) return;
    if (user == null) {
      await pins.clearPin(userId);
      if (context.mounted) _usePassword(context);
      return;
    }
    context.read<AuthBloc>().add(AuthSessionRestored(role: role, user: user));
    context.read<AppLockCubit>().startSession();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => homeFor(context, user)),
    );
  }

  void _usePassword(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginPage(role: role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColor.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('เข้าสู่ระบบด้วย PIN'),
      ),
      body: SafeArea(
        child: PinUnlockView(
          userId: userId,
          title: displayName,
          subtitle: 'กรอก PIN 6 หลักเพื่อเข้าใช้งาน',
          onUnlocked: () => _onUnlocked(context),
          onPinUnavailable: () => _usePassword(context),
          onUsePassword: () => _usePassword(context),
        ),
      ),
    );
  }
}
