import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';

enum AppFeedbackKind { success, error, info }

/// One snack bar for the whole app. Each kind has its own icon as well as
/// its colour, so the meaning never depends on colour alone, and errors stay
/// on screen longer because they need to be read and acted on.
class AppSnackBar {
  AppSnackBar._();

  static void success(BuildContext context, String message) =>
      _show(context, message, AppFeedbackKind.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, AppFeedbackKind.error);

  static void info(BuildContext context, String message) =>
      _show(context, message, AppFeedbackKind.info);

  static void _show(BuildContext context, String message, AppFeedbackKind kind) {
    final (IconData icon, Color? background, Duration duration) = switch (kind) {
      AppFeedbackKind.success => (
          Icons.check_circle_rounded,
          PColor.primaryDark,
          const Duration(seconds: 3),
        ),
      AppFeedbackKind.error => (
          Icons.error_rounded,
          PColor.riskHigh,
          const Duration(seconds: 6),
        ),
      AppFeedbackKind.info => (
          Icons.info_rounded,
          null,
          const Duration(seconds: 3),
        ),
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: background,
          duration: duration,
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              PSpacing.gapHorizontalMd,
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

/// Error message that stays in the page next to what it refers to (a form's
/// submit button, a failed section). Announced by screen readers on arrival.
class InlineAlert extends StatelessWidget {
  final String message;

  const InlineAlert(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = isDark ? PColor.hcError : PColor.riskHigh;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        padding: PSpacing.edgeInsetsAllMd,
        decoration: BoxDecoration(
          color: isDark ? PColor.hcSurfaceElevated : PColor.riskHighBg,
          borderRadius: BorderRadius.circular(PRadius.md),
          border: Border.all(color: foreground),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline_rounded, color: foreground, size: 20),
            PSpacing.gapHorizontalSm,
            Expanded(
              child: Text(
                message,
                style: PTypography.errorText.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-area state for a list or section that failed to load: says what
/// happened and offers the way out.
class ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(PSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: PColor.textNeutralColor,
            ),
            PSpacing.gapVerticalLg,
            const Text(
              'โหลดข้อมูลไม่สำเร็จ',
              textAlign: TextAlign.center,
              style: PTypography.sectionHeader,
            ),
            PSpacing.gapVerticalXs,
            Text(
              message,
              textAlign: TextAlign.center,
              style: PTypography.bodyMuted,
            ),
            PSpacing.gapVerticalXl,
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('ลองอีกครั้ง'),
            ),
          ],
        ),
      ),
    );
  }
}
