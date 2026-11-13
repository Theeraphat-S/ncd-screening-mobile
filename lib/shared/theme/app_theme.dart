import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

class AppTheme {
  static ThemeData get standardTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: PColor.primaryColor,
          primary: PColor.primaryColor,
          secondary: PColor.secondaryColor,
          onPrimary: Colors.white,
          primaryContainer: PColor.primaryLight,
          onPrimaryContainer: PColor.primaryDark,
          secondaryContainer: PColor.secondaryLight,
          onSecondaryContainer: const Color(0xFF075985), // Sky 800
          surface: PColor.neutralColor,
          onSurface: PColor.contentColor,
          onSurfaceVariant: PColor.textSecondary,
          surfaceContainerHighest: PColor.surfaceSubtle,
          outline: PColor.borderStrong,
          outlineVariant: PColor.borderSubtle,
          error: PColor.errorColor,
        ),
        scaffoldBackgroundColor: PColor.backgroundColor,
        dividerTheme: const DividerThemeData(
          color: PColor.borderSubtle,
          thickness: 1,
          space: 1,
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: PColor.surfaceSubtle,
          selectedColor: PColor.primaryLight,
          side: BorderSide(color: PColor.borderSubtle),
          labelStyle: TextStyle(
            fontFamily: 'Sarabun',
            color: PColor.textSecondary,
          ),
          secondaryLabelStyle: TextStyle(
            fontFamily: 'Sarabun',
            color: PColor.primaryDark,
            fontWeight: FontWeight.w600,
          ),
          checkmarkColor: PColor.primaryDark,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: PColor.primaryColor,
          linearTrackColor: PColor.borderSubtle,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Colors.white : PColor.borderStrong,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? PColor.primaryColor
                : PColor.surfaceSubtle,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: PColor.primaryColor,
          foregroundColor: Colors.white,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: PColor.contentColor,
          contentTextStyle: TextStyle(fontFamily: 'Sarabun', color: Colors.white),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: PColor.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Sarabun',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: PColor.borderSubtle, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: PColor.borderSubtle),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: PColor.borderSubtle),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: PColor.primaryColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: PColor.errorColor),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: PColor.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        useMaterial3: true,
        fontFamily: 'Sarabun',
      );

  static ThemeData get highContrastTheme => ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: PColor.hcAccent, // Vivid Yellow for max contrast
          onPrimary: Colors.black,
          secondary: PColor.hcCyan, // Vivid Cyan
          onSecondary: Colors.black,
          surface: PColor.hcSurface,
          onSurface: PColor.hcText,
          error: PColor.errorColor,
          onError: Colors.black,
        ),
        scaffoldBackgroundColor: PColor.hcBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: PColor.hcBackground,
          foregroundColor: PColor.hcAccent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Sarabun',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: PColor.hcAccent,
          ),
        ),
        cardTheme: CardThemeData(
          color: PColor.hcSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: PColor.hcAccent, width: 2),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: PColor.hcSurfaceElevated,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: PColor.hcAccent, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white70, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: PColor.hcAccent, width: 2.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: PColor.errorColor, width: 2),
          ),
          labelStyle: const TextStyle(color: PColor.hcText, fontWeight: FontWeight.bold),
          hintStyle: const TextStyle(color: Colors.white60),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: PColor.hcAccent,
            foregroundColor: Colors.black,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.white, width: 1.5),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Sarabun',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        useMaterial3: true,
        fontFamily: 'Sarabun',
      );
}
