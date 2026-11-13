import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/shared/tokens/tokens.dart';

/// Banner widget displaying the review status (Pending or Approved) and screening date.
class ScreeningStatusBanner extends StatelessWidget {
  final ReviewStatus reviewStatus;
  final DateTime screeningDate;

  const ScreeningStatusBanner({
    super.key,
    required this.reviewStatus,
    required this.screeningDate,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = reviewStatus == ReviewStatus.pending;
    final dateStr =
        '${screeningDate.day.toString().padLeft(2, '0')}/${screeningDate.month.toString().padLeft(2, '0')}/${screeningDate.year + 543}';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PSpacing.lg,
        vertical: PSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isPending ? PColor.statusPendingBg : PColor.statusApprovedBg,
        borderRadius: PRadius.borderMd,
        border: Border.all(
          color: isPending ? PColor.statusPending : PColor.statusApproved,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPending
                ? Icons.hourglass_top_rounded
                : Icons.check_circle_rounded,
            color: isPending ? PColor.statusPending : PColor.statusApproved,
            size: 24,
          ),
          PSpacing.gapHorizontalMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPending
                      ? 'รอพยาบาลตรวจสอบและรับรองผล'
                      : 'ผ่านการรับรองโดยพยาบาลแล้ว',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: isPending
                        ? PColor.statusPending
                        : PColor.statusApproved,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'วันที่ตรวจ: $dateStr',
                  style: const TextStyle(
                    fontSize: 14,
                    color: PColor.textNeutralColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
