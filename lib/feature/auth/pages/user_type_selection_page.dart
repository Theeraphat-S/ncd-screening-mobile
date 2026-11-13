import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/auth/bloc/auth_bloc.dart';
import 'package:ncd_screening_mobile/feature/auth/pages/login_page.dart';
import 'package:ncd_screening_mobile/feature/auth/widgets/quick_pin_login_card.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

class UserTypeSelectionPage extends StatelessWidget {
  const UserTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColor.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: PSpacing.xxl, vertical: PSpacing.xxxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PSpacing.gapVerticalMd,
                  // Hospital / MOPH Emblem Container with Nordic Clinical Styling
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: PColor.borderSubtle, width: 1.5),
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
                  PSpacing.gapVerticalXxl,
                  const Text(
                    'คัดกรองความเสี่ยง\n4 โรคไม่ติดต่อเรื้อรัง',
                    textAlign: TextAlign.center,
                    style: PTypography.heroTitle,
                  ),
                  PSpacing.gapVerticalSm,
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: PColor.textNeutralColor),
                      PSpacing.gapHorizontalXs,
                      Text(
                        'รพ.สต.แม่อาย จ.เชียงใหม่',
                        style: PTypography.bodySecondary,
                      ),
                    ],
                  ),
                  PSpacing.gapVerticalLg,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: PSpacing.lg, vertical: PSpacing.sm),
                    decoration: BoxDecoration(
                      color: PColor.surfaceSubtle,
                      borderRadius: BorderRadius.circular(PRadius.xl),
                      border: Border.all(color: PColor.borderSubtle),
                    ),
                    child: Text(
                      'เลือกประเภทผู้ใช้งานเพื่อเข้าสู่ระบบ',
                      style: PTypography.labelSmall.copyWith(color: PColor.textSecondary, fontSize: 13),
                    ),
                  ),
                  PSpacing.gapVerticalXxxl,

                  const QuickPinLoginCard(),

                  // Role Option 1: Patient (บุคคลทั่วไป)
                  _buildRoleCard(
                    context: context,
                    role: UserRole.patient,
                    title: 'บุคคลทั่วไป',
                    subtitle: 'เข้าดูประวัติและผลการคัดกรองสุขภาพของตนเอง',
                    icon: Icons.person_outline_rounded,
                    accentColor: PColor.secondaryColor,
                    accentBg: PColor.roleSelfBg,
                  ),
                  PSpacing.gapVerticalLg,

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
                  PSpacing.gapVerticalLg,

                  // Role Option 3: Nurse (พยาบาล)
                  _buildRoleCard(
                    context: context,
                    role: UserRole.nurse,
                    title: 'สำหรับพยาบาล',
                    subtitle: 'ดูแลข้อมูล อสม. และอนุมัติผลการประเมินความเสี่ยง',
                    icon: Icons.medical_services_outlined,
                    accentColor: PColor.roleNurse,
                    accentBg: PColor.roleNurseBg,
                  ),
                  PSpacing.gapVerticalXxxl,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(PRadius.lg),
        border: Border.all(color: PColor.borderSubtle, width: 1),
        boxShadow: PShadow.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(PRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(PRadius.lg),
          onTap: () {
            context.read<AuthBloc>().add(AuthSelectRole(role));
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LoginPage(role: role),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PSpacing.xl, vertical: PSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: accentBg,
                    borderRadius: BorderRadius.circular(PRadius.md),
                  ),
                  child: Icon(icon, color: accentColor, size: 26),
                ),
                PSpacing.gapHorizontalLg,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: PTypography.sectionHeader,
                      ),
                      PSpacing.gapVerticalXs,
                      Text(
                        subtitle,
                        style: PTypography.caption,
                      ),
                    ],
                  ),
                ),
                PSpacing.gapHorizontalSm,
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
