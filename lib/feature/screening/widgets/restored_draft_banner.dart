import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';

/// Tells the VHV that earlier input was restored, with a "start over" action.
class RestoredDraftBanner extends StatelessWidget {
  final DateTime savedAt;
  final VoidCallback onStartOver;

  const RestoredDraftBanner({
    super.key,
    required this.savedAt,
    required this.onStartOver,
  });

  String _when() {
    String two(int n) => n.toString().padLeft(2, '0');
    final today = DateTime.now();
    final sameDay = savedAt.year == today.year &&
        savedAt.month == today.month &&
        savedAt.day == today.day;
    final time = '${two(savedAt.hour)}:${two(savedAt.minute)} น.';
    return sameDay ? time : '${two(savedAt.day)}/${two(savedAt.month)} $time';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PColor.riskModerateBg,
        borderRadius: BorderRadius.circular(PRadius.md),
        border: Border.all(color: PColor.riskModerate.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.history_rounded, color: PColor.riskModerate),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'กู้คืนข้อมูลที่กรอกค้างไว้เมื่อ ${_when()}',
              style: PTypography.bodyBold,
            ),
          ),
          TextButton(
            key: const Key('start_over'),
            onPressed: onStartOver,
            child: const Text('เริ่มใหม่'),
          ),
        ],
      ),
    );
  }
}
