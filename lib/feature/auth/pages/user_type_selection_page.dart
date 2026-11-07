import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/auth/bloc/auth_bloc.dart';
import 'package:ncd_screening_mobile/feature/auth/pages/login_page.dart';
import 'package:ncd_screening_mobile/shared/components/appbar/language_dropdown.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

class UserTypeSelectionPage extends StatelessWidget {
  const UserTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          SizedBox(width: 56, child: LanguageDropdown(context: context)),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  // Hospital / MOPH Emblem Container with Nordic Clinical Styling
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: PColor.neutralColor,
                      border: Border.all(
                        color: PColor.borderSubtle,
                        width: 1.5,
                      ),
                      boxShadow: PShadow.card,
                    ),
                    child: Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: PColor.primaryLight,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.local_hospital_rounded,
                            size: 44,
                            color: PColor.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'คัดกรองความเสี่ยง\n4 โรคไม่ติดต่อเรื้อรัง',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: PColor.contentColor,
                      height: 1.3,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: PColor.textNeutralColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'รพ.สต.แม่อาย จ.เชียงใหม่',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: PColor.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: PColor.surfaceSubtle,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: PColor.borderSubtle),
                    ),
                    child: const Text(
                      'เลือกประเภทผู้ใช้งานเพื่อเข้าสู่ระบบ',
                      style: TextStyle(
                        fontSize: 13,
                        color: PColor.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Role Option 1: Patient (บุคคลทั่วไป)
                  _buildRoleCard(
                    context: context,
                    role: UserRole.patient,
                    title: 'บุคคลทั่วไป',
                    subtitle: 'เข้าดูประวัติและผลการคัดกรองสุขภาพของตนเอง',
                    icon: Icons.person_outline_rounded,
                    accentColor: PColor.secondaryColor,
                    accentBg: const Color(0xFFE0F2FE),
                  ),
                  const SizedBox(height: 14),

                  // Role Option 2: VHV (อสม.)
                  _buildRoleCard(
                    context: context,
                    role: UserRole.vhv,
                    title: 'สำหรับ อสม.',
                    subtitle: 'บันทึกข้อมูลผู้ป่วยและทำแบบคัดกรองสุขภาพในชุมชน',
                    icon: Icons.volunteer_activism_outlined,
                    accentColor: PColor.primaryColor,
                    accentBg: PColor.primaryLight,
                  ),
                  const SizedBox(height: 14),

                  // Role Option 3: Nurse (พยาบาล)
                  _buildRoleCard(
                    context: context,
                    role: UserRole.nurse,
                    title: 'สำหรับพยาบาล',
                    subtitle:
                        'ดูแลข้อมูล อสม. และอนุมัติผลการประเมินความเสี่ยง',
                    icon: Icons.medical_services_outlined,
                    accentColor: const Color(0xFF4F46E5),
                    accentBg: const Color(0xFFEEF2FF),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color accentBg,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: PColor.neutralColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PColor.borderSubtle, width: 1),
        boxShadow: PShadow.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.read<AuthBloc>().add(AuthSelectRole(role));
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LoginPage(role: role)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: accentBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accentColor, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: PColor.contentColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: PColor.textNeutralColor,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: PColor.surfaceSubtle,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: PColor.textSecondary,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
