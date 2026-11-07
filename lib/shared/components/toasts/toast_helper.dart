import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';
import 'package:toastification/toastification.dart';

void showErrorToast({
  required BuildContext context,
  String? title,
  String description = '',
  Duration autoCloseDuration = const Duration(seconds: 3),
}) {
  toastification.show(
    context: context,
    alignment: Alignment.topCenter,
    title: Text(title ?? '', style: const TextStyle(fontSize: 18)),
    description: Text(description),
    type: ToastificationType.error,
    style: ToastificationStyle.flat,
    autoCloseDuration: autoCloseDuration,
    icon: const Icon(Icons.error_outline, color: PColor.errorColor),
    closeButton: const ToastCloseButton(showType: CloseButtonShowType.always),
    closeOnClick: true,
    backgroundColor: PColor.neutralColor,
    foregroundColor: Colors.black,
    padding: const EdgeInsets.all(PSpacing.lg),
    margin: const EdgeInsets.all(PSpacing.xl),
    borderRadius: BorderRadius.circular(PRadius.md),
    progressBarTheme: ProgressIndicatorThemeData(
      color: PColor.errorColor,
      linearTrackColor: Colors.redAccent.withValues(alpha: 0.3),
    ),
  );
}

void showSuccessToast({
  required BuildContext context,
  String? title,
  String description = '',
  Duration autoCloseDuration = const Duration(seconds: 3),
}) {
  toastification.show(
    context: context,
    alignment: Alignment.topCenter,
    title: Text(title ?? '', style: const TextStyle(fontSize: 18)),
    description: Text(description),
    type: ToastificationType.success,
    style: ToastificationStyle.flat,
    autoCloseDuration: autoCloseDuration,
    icon: const Icon(Icons.check_circle_outline, color: PColor.primaryColor),
    closeButton: const ToastCloseButton(showType: CloseButtonShowType.always),
    closeOnClick: true,
    backgroundColor: PColor.neutralColor,
    foregroundColor: Colors.black,
    padding: const EdgeInsets.all(PSpacing.lg),
    margin: const EdgeInsets.all(PSpacing.xl),
    borderRadius: BorderRadius.circular(PRadius.md),
    progressBarTheme: const ProgressIndicatorThemeData(
      color: PColor.primaryColor,
    ),
  );
}
