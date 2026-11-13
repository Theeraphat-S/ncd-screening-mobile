import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/shared/bloc/sync_badge_bloc.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

class SyncBadgeWidget extends StatelessWidget {
  const SyncBadgeWidget({super.key});

  void _showSyncDetailModal(BuildContext context, SyncBadgeState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: PColor.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.cloud_sync_rounded, color: PColor.primaryDark, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'สถานะการประสานข้อมูล (Sync)',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: PColor.contentColor,
                          ),
                        ),
                        Text(
                          'ระบบจัดเก็บออฟไลน์ปลอดภัย 100%',
                          style: TextStyle(fontSize: 13, color: PColor.textSecondary),
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: PColor.surfaceSubtle,
                  borderRadius: BorderRadius.circular(14),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        !state.canSync
                            ? 'ยังไม่มีเซิร์ฟเวอร์ ข้อมูลเก็บไว้ในเครื่องนี้'
                            : state.isOnline
                                ? 'สถานะเครือข่าย: ออนไลน์ (พร้อมซิงค์)'
                                : 'สถานะเครือข่าย: ออฟไลน์',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: !state.canSync
                              ? PColor.textSecondary
                              : state.isOnline
                                  ? PColor.riskLow
                                  : PColor.riskHigh,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Queue Status Row
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: state.pendingCount == 0 ? PColor.riskLowBg : PColor.riskModerateBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: state.pendingCount == 0 ? PColor.riskLow.withValues(alpha: 0.3) : PColor.riskModerate.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      state.pendingCount == 0 ? Icons.check_circle_outline_rounded : Icons.hourglass_top_rounded,
                      color: state.pendingCount == 0 ? PColor.riskLow : PColor.riskModerate,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.pendingCount == 0
                            ? (state.canSync
                                ? 'ข้อมูลทั้งหมดส่งขึ้นระบบเรียบร้อยแล้ว'
                                : 'ยังไม่มีข้อมูลรอส่ง')
                            : (state.canSync
                                ? 'มี ${state.pendingCount} รายการรอส่งขึ้นระบบคลาวด์'
                                : 'รอส่ง ${state.pendingCount} รายการ (ยังไม่มีเซิร์ฟเวอร์ เก็บไว้ในเครื่องนี้)'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: state.pendingCount == 0 ? PColor.riskLow : PColor.riskModerate,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Sync Now Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PColor.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
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

        if (state.pendingCount > 0) {
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _showSyncDetailModal(context, state),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: PColor.riskModerate,
                borderRadius: BorderRadius.circular(20),
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
                  const SizedBox(width: 4),
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
            tooltip: 'ยังไม่มีเซิร์ฟเวอร์ ข้อมูลเก็บไว้ในเครื่อง',
            icon: const Icon(Icons.cloud_off_rounded, color: Colors.white, size: 22),
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
