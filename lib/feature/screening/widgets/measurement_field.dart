import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

/// Numeric measurement input with its unit, an error line and a non-blocking
/// warning line. Large type and a 56dp-high field keep it usable outdoors.
class MeasurementField extends StatelessWidget {
  final Key? fieldKey;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String unit;
  final String hint;
  final bool optional;
  final String? errorText;
  final String? warningText;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  const MeasurementField({
    super.key,
    this.fieldKey,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.unit,
    required this.hint,
    this.optional = false,
    this.errorText,
    this.warningText,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    final hasWarning = !hasError && warningText != null;
    final borderColor = hasError
        ? PColor.errorColor
        : hasWarning
            ? PColor.riskModerate
            : PColor.borderSubtle;

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(PRadius.md),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: PTypography.fieldLabel,
            children: [
              if (optional)
                const TextSpan(
                  text: '  (ไม่บังคับ)',
                  style: PTypography.bodyMuted,
                ),
            ],
          ),
        ),
        PSpacing.gapVerticalSm,
        TextFormField(
          key: fieldKey,
          controller: controller,
          focusNode: focusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: textInputAction,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            LengthLimitingTextInputFormatter(6),
          ],
          style: PTypography.fieldValue,
          onChanged: onChanged,
          onFieldSubmitted: (_) => onSubmitted?.call(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: PTypography.fieldHint,
            suffixText: unit,
            suffixStyle: PTypography.bodyMuted,
            filled: true,
            fillColor: PColor.backgroundColor,
            constraints: const BoxConstraints(minHeight: 56),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: PSpacing.lg, vertical: PSpacing.lg),
            border: border(borderColor),
            enabledBorder: border(borderColor, hasError || hasWarning ? 1.5 : 1),
            focusedBorder: border(
              hasError ? PColor.errorColor : PColor.primaryColor,
              2,
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: PSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 16, color: PColor.errorColor),
                PSpacing.gapHorizontalXs,
                Expanded(child: Text(errorText!, style: PTypography.fieldError)),
              ],
            ),
          )
        else if (hasWarning)
          Padding(
            padding: const EdgeInsets.only(top: PSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 16, color: PColor.riskModerate),
                PSpacing.gapHorizontalXs,
                Expanded(
                    child: Text(warningText!, style: PTypography.fieldWarning)),
              ],
            ),
          ),
      ],
    );
  }
}
