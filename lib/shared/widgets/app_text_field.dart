import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';

/// Visible label that sits above a form control. A placeholder is never the
/// only label: it disappears as soon as the user types.
class AppFieldLabel extends StatelessWidget {
  final String text;
  final bool optional;

  const AppFieldLabel(this.text, {super.key, this.optional = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: PSpacing.sm),
      child: Text.rich(
        TextSpan(
          text: text,
          style: PTypography.fieldLabel.copyWith(color: scheme.onSurface),
          children: [
            if (optional)
              TextSpan(
                text: '  (ไม่บังคับ)',
                style: PTypography.bodyMuted.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Standard labelled text input. Borders, fill, hint and error styles come
/// from the theme's `inputDecorationTheme`; the validator's message is shown
/// directly under the field.
class AppTextField extends StatelessWidget {
  final String label;
  final bool optional;
  final String? hint;
  final String? helper;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final int? maxLength;
  final int maxLines;
  final bool obscureText;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  const AppTextField({
    super.key,
    required this.label,
    this.optional = false,
    this.hint,
    this.helper,
    this.controller,
    this.focusNode,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.autofillHints,
    this.maxLength,
    this.maxLines = 1,
    this.obscureText = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFieldLabel(label, optional: optional),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: [
            ...?inputFormatters,
            if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
          ],
          autofillHints: autofillHints,
          maxLines: maxLines,
          obscureText: obscureText,
          style: PTypography.fieldInput.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helper,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

/// Read-only field that opens a picker (date, list) when tapped. Looks and
/// reports errors exactly like [AppTextField].
class AppPickerField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final String? errorText;
  final String? helper;

  const AppPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.errorText,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFieldLabel(label),
        Semantics(
          button: true,
          label: '$label $value แตะเพื่อเปลี่ยน',
          excludeSemantics: true,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(PRadius.md),
            child: InputDecorator(
              decoration: InputDecoration(
                errorText: errorText,
                helperText: helper,
                suffixIcon: Icon(icon, color: scheme.primary),
              ),
              child: Text(
                value,
                style: PTypography.fieldInput.copyWith(color: scheme.onSurface),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
