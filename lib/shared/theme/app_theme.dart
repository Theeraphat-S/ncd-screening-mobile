import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_elevation.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_size.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';

/// The two app themes. Every component default (app bar, buttons, inputs,
/// dialogs, snack bars) is set here from the tokens, so pages only state
/// what differs from the default.
class AppTheme {
  AppTheme._();

  static const String fontFamily = 'Sarabun';

  static final ThemeData standardTheme = _build(_standard);
  static final ThemeData highContrastTheme = _build(_highContrast);

  static final _Palette _standard = _Palette(
    scheme: ColorScheme.fromSeed(
      seedColor: PColor.primaryColor,
      primary: PColor.primaryColor,
      secondary: PColor.secondaryColor,
      onPrimary: Colors.white,
      primaryContainer: PColor.primaryLight,
      onPrimaryContainer: PColor.primaryDark,
      secondaryContainer: PColor.secondaryLight,
      onSecondaryContainer: PColor.secondaryDark,
      surface: PColor.neutralColor,
      onSurface: PColor.contentColor,
      onSurfaceVariant: PColor.textSecondary,
      surfaceContainerHighest: PColor.surfaceSubtle,
      outline: PColor.borderInput,
      outlineVariant: PColor.borderSubtle,
      error: PColor.errorColor,
    ),
    scaffold: PColor.backgroundColor,
    appBarBackground: PColor.primaryColor,
    appBarForeground: Colors.white,
    appBarTitleSize: PText.textLg,
    cardBorder: const BorderSide(color: PColor.borderSubtle),
    inputFill: PColor.neutralColor,
    inputBorder: PColor.borderInput,
    inputBorderWidth: 1,
    hint: PColor.textNeutralColor,
    buttonTextSize: PText.textBase,
    buttonSide: BorderSide.none,
    snackBackground: PColor.contentColor,
    snackForeground: Colors.white,
  );

  static const _Palette _highContrast = _Palette(
    scheme: ColorScheme.dark(
      primary: PColor.hcAccent, // Vivid yellow for max contrast
      onPrimary: Colors.black,
      secondary: PColor.hcCyan,
      onSecondary: Colors.black,
      surface: PColor.hcSurface,
      onSurface: PColor.hcText,
      onSurfaceVariant: PColor.hcTextMuted,
      outline: Colors.white70,
      error: PColor.hcError,
      onError: Colors.black,
    ),
    scaffold: PColor.hcBackground,
    appBarBackground: PColor.hcBackground,
    appBarForeground: PColor.hcAccent,
    appBarTitleSize: PText.textXl,
    cardBorder: BorderSide(color: PColor.hcAccent, width: 2),
    inputFill: PColor.hcSurfaceElevated,
    inputBorder: Colors.white70,
    inputBorderWidth: 2,
    hint: PColor.hcTextMuted,
    buttonTextSize: PText.textLg,
    buttonSide: BorderSide(color: Colors.white, width: 1.5),
    snackBackground: PColor.hcSurfaceElevated,
    snackForeground: PColor.hcText,
  );

  static TextStyle _font(TextStyle style) =>
      style.copyWith(fontFamily: fontFamily);

  /// Material type roles mapped onto the [PTypography] scale. Colours come
  /// from the colour scheme so both themes share one definition.
  static const TextTheme _textTheme = TextTheme(
    headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.25),
    headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.3),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.3),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
    titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4),
    bodyLarge: TextStyle(fontSize: 16, height: 1.45),
    bodyMedium: TextStyle(fontSize: 14, height: 1.45),
    bodySmall: TextStyle(fontSize: 13, height: 1.45),
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
  );

  static ThemeData _build(_Palette p) {
    final scheme = p.scheme;
    final isDark = scheme.brightness == Brightness.dark;

    OutlineInputBorder inputBorder(Color color, double width) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(PRadius.md),
          borderSide: BorderSide(color: color, width: width),
        );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(PRadius.md),
      side: p.buttonSide,
    );
    final buttonText = _font(
      PTypography.buttonLabel.copyWith(fontSize: p.buttonTextSize),
    );
    const buttonPadding = EdgeInsets.symmetric(
      horizontal: PSpacing.xxl,
      vertical: PSpacing.md,
    );
    const buttonMinSize = Size(64, 48);

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      fontFamily: fontFamily,
      colorScheme: scheme,
      textTheme: _textTheme,
      scaffoldBackgroundColor: p.scaffold,
      // One back affordance everywhere; the default BackButton also supplies
      // the localized tooltip and pops through PopScope guards.
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (_) =>
            const Icon(Icons.arrow_back_ios_new_rounded),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.appBarBackground,
        foregroundColor: p.appBarForeground,
        surfaceTintColor: Colors.transparent,
        elevation: PElevation.none,
        scrolledUnderElevation: PElevation.none,
        centerTitle: true,
        iconTheme: IconThemeData(color: p.appBarForeground),
        actionsIconTheme: IconThemeData(color: p.appBarForeground),
        titleTextStyle: _font(
          PTypography.appBarTitle.copyWith(
            fontSize: p.appBarTitleSize,
            color: p.appBarForeground,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: PElevation.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PRadius.card),
          side: p.cardBorder,
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white24 : PColor.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PSpacing.lg,
          vertical: PSpacing.md,
        ),
        constraints: const BoxConstraints(minHeight: 48),
        hintStyle: _font(PTypography.fieldHint.copyWith(color: p.hint)),
        labelStyle: _font(
          PTypography.fieldLabel.copyWith(color: scheme.onSurface),
        ),
        helperStyle: _font(
          PTypography.fieldHelper.copyWith(color: scheme.onSurfaceVariant),
        ),
        helperMaxLines: 3,
        errorStyle: _font(PTypography.fieldError.copyWith(color: scheme.error)),
        errorMaxLines: 3,
        border: inputBorder(p.inputBorder, p.inputBorderWidth),
        enabledBorder: inputBorder(p.inputBorder, p.inputBorderWidth),
        disabledBorder: inputBorder(
          isDark ? Colors.white24 : PColor.borderSubtle,
          p.inputBorderWidth,
        ),
        focusedBorder: inputBorder(scheme.primary, p.inputBorderWidth + 1),
        errorBorder: inputBorder(scheme.error, p.inputBorderWidth + 0.5),
        focusedErrorBorder: inputBorder(scheme.error, p.inputBorderWidth + 1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: PElevation.none,
          minimumSize: buttonMinSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonMinSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: buttonMinSize,
          padding: buttonPadding,
          side: BorderSide(color: scheme.primary, width: isDark ? 2 : 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PRadius.md),
          ),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: PSpacing.lg,
            vertical: PSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PRadius.md),
          ),
          textStyle: _font(PTypography.buttonLabel),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        extendedTextStyle: _font(PTypography.buttonLabel),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PRadius.xl),
          side: isDark ? p.cardBorder : BorderSide.none,
        ),
        titleTextStyle: _font(
          PTypography.dialogTitle.copyWith(color: scheme.onSurface),
        ),
        contentTextStyle: _font(
          PTypography.body.copyWith(
            fontSize: PText.textBase,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(PSpacing.xxl),
          ),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PRadius.xl),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PRadius.md),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.snackBackground,
        contentTextStyle: _font(
          PTypography.body.copyWith(
            fontSize: PText.textBase - 1,
            color: p.snackForeground,
          ),
        ),
        actionTextColor: isDark ? scheme.primary : PColor.primaryTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PRadius.md),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: isDark ? Colors.white24 : PColor.borderSubtle,
      ),
      chipTheme: isDark
          ? null
          : ChipThemeData(
              backgroundColor: PColor.surfaceSubtle,
              selectedColor: PColor.primaryLight,
              side: const BorderSide(color: PColor.borderSubtle),
              labelStyle: _font(PTypography.bodySecondary),
              secondaryLabelStyle: _font(
                PTypography.labelSmall.copyWith(color: PColor.primaryDark),
              ),
              checkmarkColor: PColor.primaryDark,
            ),
      switchTheme: isDark
          ? null
          : SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected)
                    ? Colors.white
                    : PColor.borderInput,
              ),
              trackColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected)
                    ? PColor.primaryColor
                    : PColor.surfaceSubtle,
              ),
            ),
    );
  }
}

/// The handful of values that differ between the standard and the
/// high-contrast theme.
class _Palette {
  final ColorScheme scheme;
  final Color scaffold;
  final Color appBarBackground;
  final Color appBarForeground;
  final double appBarTitleSize;
  final BorderSide cardBorder;
  final Color inputFill;
  final Color inputBorder;
  final double inputBorderWidth;
  final Color hint;
  final double buttonTextSize;
  final BorderSide buttonSide;
  final Color snackBackground;
  final Color snackForeground;

  const _Palette({
    required this.scheme,
    required this.scaffold,
    required this.appBarBackground,
    required this.appBarForeground,
    required this.appBarTitleSize,
    required this.cardBorder,
    required this.inputFill,
    required this.inputBorder,
    required this.inputBorderWidth,
    required this.hint,
    required this.buttonTextSize,
    required this.buttonSide,
    required this.snackBackground,
    required this.snackForeground,
  });
}
