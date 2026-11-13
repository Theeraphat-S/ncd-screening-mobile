import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/data/services/device_security_services.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';
import 'package:ncd_screening_mobile/feature/auth/pages/pin_login_page.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';

/// "Continue as NAME with PIN" shortcut shown on the role-selection page
/// when a staff member on this device already set a PIN.
class QuickPinLoginCard extends StatelessWidget {
  const QuickPinLoginCard({super.key});

  Future<({UserRole role, String userId, String name})?> _load(
      BuildContext context) async {
    final DeviceSessionStore session;
    final PinService pins;
    final NcdRepositoryInterface repo;
    try {
      session = context.read<DeviceSessionStore>();
      pins = context.read<PinService>();
      repo = context.read<NcdRepositoryInterface>();
    } on ProviderNotFoundException {
      return null; // PIN login is not set up in this app instance
    }
    final last = await session.lastUser();
    if (last == null || !await pins.hasPin(last.userId)) return null;
    final String? name = last.role == UserRole.vhv
        ? (await repo.getVhvById(last.userId))?.fullName
        : (await repo.getNurseById(last.userId))?.fullName;
    if (name == null) return null;
    return (role: last.role, userId: last.userId, name: name);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _load(context),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Material(
            color: PColor.primaryLight,
            borderRadius: BorderRadius.circular(PRadius.lg),
            child: InkWell(
              borderRadius: BorderRadius.circular(PRadius.lg),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PinLoginPage(
                    role: data.role,
                    userId: data.userId,
                    displayName: data.name,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.lock_open_rounded, color: PColor.primaryColor, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'เข้าสู่ระบบด้วย PIN',
                            style: PTypography.sectionHeader,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            data.name,
                            style: PTypography.bodySecondary,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: PColor.primaryColor),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
