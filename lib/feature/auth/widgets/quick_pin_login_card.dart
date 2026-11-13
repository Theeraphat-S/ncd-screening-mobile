import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/data/services/device_security_services.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';
import 'package:ncd_screening_mobile/feature/auth/pages/pin_login_page.dart';
import 'package:ncd_screening_mobile/locator.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

/// "Continue as NAME with PIN" shortcut shown on the role-selection page
/// when a staff member on this device already set a PIN.
class QuickPinLoginCard extends StatelessWidget {
  const QuickPinLoginCard({super.key});

  Future<({UserRole role, String userId, String name})?> _load() async {
    if (!locator.isRegistered<DeviceSessionStore>()) return null;
    final last = await locator<DeviceSessionStore>().lastUser();
    if (last == null || !await locator<PinService>().hasPin(last.userId)) {
      return null;
    }
    final repo = locator<NcdRepositoryInterface>();
    final String? name = last.role == UserRole.vhv
        ? (await repo.getVhvById(last.userId))?.fullName
        : (await repo.getNurseById(last.userId))?.fullName;
    if (name == null) return null;
    return (role: last.role, userId: last.userId, name: name);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _load(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Material(
            color: PColor.primaryLight,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: PColor.contentColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            data.name,
                            style: const TextStyle(fontSize: 14, color: PColor.textSecondary),
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
