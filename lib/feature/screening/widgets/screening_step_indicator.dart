import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';

/// "Patient info → screening → result" progress strip at the top of the form.
class ScreeningStepIndicator extends StatelessWidget {
  const ScreeningStepIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PColor.borderSubtle),
        boxShadow: PShadow.card,
      ),
      child: Semantics(
        label: 'ขั้นตอนที่ 2 จาก 3 กำลังกรอกแบบคัดกรอง ข้อมูลผู้ป่วยเสร็จแล้ว',
        excludeSemantics: true,
        // A progress strip, not content: clamp so three labels still fit on a
        // narrow phone when the system text size is at its maximum. The same
        // information is read out through the Semantics label above.
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StepItem(number: '1', label: 'ข้อมูลผู้ป่วย', isDone: true),
              _StepLine(isActive: true),
              _StepItem(number: '2', label: 'แบบคัดกรอง', isActive: true),
              _StepLine(isActive: false),
              _StepItem(number: '3', label: 'ผลการประเมิน', isActive: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String label;
  final bool isActive;
  final bool isDone;

  const _StepItem({
    required this.number,
    required this.label,
    this.isActive = false,
    this.isDone = false,
  });

  @override
  Widget build(BuildContext context) {
    final highlighted = isActive || isDone;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? PColor.primaryColor
                : isActive
                    ? PColor.primaryLight
                    : PColor.surfaceSubtle,
            border: Border.all(
              color: highlighted ? PColor.primaryColor : PColor.borderSubtle,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    number,
                    style: PTypography.captionStrong.copyWith(
                      fontSize: 14,
                      color: isActive ? PColor.primaryDark : PColor.textNeutralColor,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: PTypography.captionSecondary.copyWith(
            fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
            color: highlighted ? PColor.contentColor : PColor.textNeutralColor,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isActive;
  const _StepLine({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: isActive ? PColor.primaryColor : PColor.borderSubtle,
      ),
    );
  }
}
