import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/shared/bloc/sync_badge_bloc.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

class SyncBadgeWidget extends StatelessWidget {
  const SyncBadgeWidget({super.key});

  void _showSyncDetailModal(BuildContext context, SyncBadgeState state) {
    // With no server nothing is "pending": the data is saved on this device.
    final queueClear = state.pendingCount == 0 || !state.canSync;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PSpacing.xxl, vertical: PSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(PSpacing.md),
                    decoration: BoxDecoration(
                      color: PColor.primaryLight,
                      borderRadius: BorderRadius.circular(PRadius.md),
                    ),
                    child: const Icon(Icons.cloud_sync_rounded, color: PColor.primaryDark, size: 24),
                  ),
                  PSpacing.gapHorizontalLg,
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'สถานะการประสานข้อมูล (Sync)',
                          style: PTypography.sectionHeader,
                        ),
                        Text(
                          'บันทึกในเครื่องนี้ ใช้งานได้โดยไม่ต้องมีสัญญาณ',
                          style: PTypography.captionSecondary,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: PColor.textNeutralColor),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Network Status Row
              Container(
                padding: const EdgeInsets.all(PSpacing.lg),
                decoration: BoxDecoration(
                  color: PColor.surfaceSubtle,
                  borderRadius: BorderRadius.circular(PRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(
                      !state.canSync
                          ? Icons.cloud_off_rounded
                          : state.isOnline
                              ? Icons.wifi_rounded
                              : Icons.wifi_off_rounded,
                      color: !state.canSync
                          ? PColor.textNeutralColor
                          : state.isOnline
                              ? PColor.riskLow
                              : PColor.riskHigh,
                      size: 22,
                    ),
                    PSpacing.gapHorizontalMd,
                    Expanded(
                      child: Text(
                        !state.canSync
                            ? 'ยังไม่มีเซิร์ฟเวอร์ ข้อมูลเก็บไว้ในเครื่องนี้'
                            : state.isOnline
                                ? 'สถานะเครือข่าย: ออนไลน์ (พร้อมซิงค์)'
                                : 'สถานะเครือข่าย: ออฟไลน์',
                        style: PTypography.labelSmall.copyWith(color: !state.canSync ? PColor.textSecondary : state.isOnline ? PColor.riskLow : PColor.riskHigh, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
              PSpacing.gapVerticalLg,

              // Queue Status Row
              Container(
                padding: const EdgeInsets.all(PSpacing.lg),
                decoration: BoxDecoration(
                  color: queueClear ? PColor.riskLowBg : PColor.riskModerateBg,
                  borderRadius: BorderRadius.circular(PRadius.md),
                  border: Border.all(
                    color: queueClear ? PColor.riskLow.withValues(alpha: 0.3) : PColor.riskModerate.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      queueClear ? Icons.check_circle_outline_rounded : Icons.hourglass_top_rounded,
                      color: queueClear ? PColor.riskLow : PColor.riskModerate,
                      size: 22,
                    ),
                    PSpacing.gapHorizontalMd,
                    Expanded(
                      child: Text(
                        !state.canSync
                            ? (state.pendingCount == 0
                                ? 'ยังไม่มีข้อมูลที่บันทึก'
                                : 'บันทึกในเครื่องนี้แล้ว ${state.pendingCount} รายการ (ยังไม่มีเซิร์ฟเวอร์)')
                            : (state.pendingCount == 0
                                ? 'ข้อมูลทั้งหมดส่งขึ้นระบบเรียบร้อยแล้ว'
                                : 'มี ${state.pendingCount} รายการรอส่งขึ้นระบบคลาวด์'),
                        style: PTypography.labelSmall.copyWith(color: queueClear ? PColor.riskLow : PColor.riskModerate, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              PSpacing.gapVerticalXxl,

              // Action Sync Now Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PColor.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: PSpacing.lg),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PRadius.md)),
                  ),
                  icon: state.isSyncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.sync_rounded, color: Colors.white, size: 20),
                  label: Text(
                    state.isSyncing
                        ? 'กำลังส่งข้อมูล...'
                        : state.canSync
                            ? 'สั่งซิงค์ข้อมูลทันที'
                            : 'ยังไม่เปิดให้ซิงค์',
                    style: PTypography.buttonOnPrimary,
                  ),
                  onPressed: (state.isSyncing || !state.canSync)
                      ? null
                      : () {
                          context.read<SyncBadgeBloc>().add(const SyncBadgeManualSyncRequested());
                          Navigator.pop(ctx);
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SyncBadgeBloc? bloc;
    try {
      bloc = context.read<SyncBadgeBloc>();
    } catch (_) {
      bloc = null;
    }

    if (bloc == null) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<SyncBadgeBloc, SyncBadgeState>(
      builder: (context, state) {
        if (state.isSyncing) {
          return IconButton(
            tooltip: 'กำลังซิงค์ข้อมูล...',
            icon: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Colors.white,
              ),
            ),
            onPressed: () => _showSyncDetailModal(context, state),
          );
        }

        if (state.canSync && state.pendingCount > 0) {
          return InkWell(
            borderRadius: BorderRadius.circular(PRadius.xl),
            onTap: () => _showSyncDetailModal(context, state),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: PSpacing.md, horizontal: PSpacing.sm),
              padding: const EdgeInsets.symmetric(horizontal: PSpacing.md, vertical: PSpacing.xs),
              decoration: BoxDecoration(
                color: PColor.riskModerate,
                borderRadius: BorderRadius.circular(PRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 14),
                  PSpacing.gapHorizontalXs,
                  Text(
                    '${state.pendingCount} รอส่ง',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // No server yet: never show the "synced" check.
        if (!state.canSync) {
          return IconButton(
            tooltip: 'บันทึกในเครื่องนี้แล้ว (ยังไม่มีเซิร์ฟเวอร์)',
            icon: const Icon(Icons.offline_pin_rounded, color: Colors.white, size: 22),
            onPressed: () => _showSyncDetailModal(context, state),
          );
        }

        // Synced green pill/icon
        return IconButton(
          tooltip: 'ข้อมูลเชื่อมโยงเรียบร้อย',
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.cloud_done_rounded, color: Colors.white, size: 22),
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: PColor.riskLow,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () => _showSyncDetailModal(context, state),
        );
      },
    );
  }
}
