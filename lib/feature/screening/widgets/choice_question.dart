import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';

/// A question with a row of large tap targets (มี / ไม่มี / ไม่ทราบ).
///
/// [value] is null while unanswered; [showMissing] then adds a red hint.
/// Option keys are `<keyPrefix>_<option>` so tests can tap them.
class ChoiceQuestion extends StatelessWidget {
  final String title;
  final String keyPrefix;
  final String? value;
  final List<String> options;
  final bool showMissing;
  final ValueChanged<String> onChanged;

  const ChoiceQuestion({
    super.key,
    required this.title,
    required this.keyPrefix,
    required this.value,
    required this.onChanged,
    this.options = const ['มี', 'ไม่มี', 'ไม่ทราบ'],
    this.showMissing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: PTypography.cardTitle.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: Row(
            children: [for (final o in options) Expanded(child: _option(o))],
          ),
        ),
        if (showMissing)
          const Padding(
            padding: EdgeInsets.only(top: 6, left: 4),
            child: Text('กรุณาเลือกคำตอบ', style: PTypography.fieldError),
          ),
      ],
    );
  }

  Widget _option(String opt) {
    final isSelected = value == opt;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Semantics(
        button: true,
        selected: isSelected,
        label: opt,
        child: InkWell(
          key: Key('${keyPrefix}_$opt'),
          borderRadius: BorderRadius.circular(10),
          onTap: () => onChanged(opt),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            decoration: BoxDecoration(
              color: isSelected ? PColor.primaryLight : PColor.surfaceSubtle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? PColor.primaryColor : PColor.borderSubtle,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Center(
              child: Text(
                opt,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? PColor.primaryDark : PColor.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
