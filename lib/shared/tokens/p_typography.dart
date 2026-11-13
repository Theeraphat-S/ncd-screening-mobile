import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

/// Centralized Typography & Text Style Tokens for the application.
class PTypography {
  PTypography._();

  static const TextStyle appBarTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle sectionHeader = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: PColor.contentColor,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: PColor.contentColor,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: PColor.contentColor,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: PColor.contentColor,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontSize: 14,
    color: PColor.textNeutralColor,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    color: PColor.textNeutralColor,
  );

  static const TextStyle badge = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 13,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  // --- Form fields (field use: readable in sunlight, large enough for tired eyes)
  static const TextStyle fieldLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: PColor.contentColor,
  );

  static const TextStyle fieldValue = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: PColor.contentColor,
  );

  static const TextStyle fieldHint = TextStyle(
    fontSize: 15,
    color: PColor.textNeutralColor,
  );

  static const TextStyle fieldError = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: PColor.errorColor,
  );

  static const TextStyle fieldWarning = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: PColor.riskModerate,
  );

  // --- Headings / extras used by auth, search and result pages
  static const TextStyle pageTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: PColor.contentColor,
  );

  static const TextStyle heroTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: PColor.contentColor,
    height: 1.3,
  );

  static const TextStyle emphasisPrimary = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: PColor.primaryDark,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: PColor.contentColor,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14,
    color: PColor.textSecondary,
  );

  static const TextStyle captionSecondary = TextStyle(
    fontSize: 13,
    color: PColor.textSecondary,
  );

  static const TextStyle captionContent = TextStyle(
    fontSize: 13,
    color: PColor.contentColor,
  );

  static const TextStyle captionStrong = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: PColor.textNeutralColor,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: PColor.contentColor,
  );

  static const TextStyle captionOnPrimary = TextStyle(
    fontSize: 13,
    color: Colors.white70,
  );

  static const TextStyle buttonOnPrimary = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle actionPrimary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: PColor.primaryColor,
  );

  static const TextStyle errorText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: PColor.errorColor,
  );

  static const TextStyle pinDigit = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
  );
}
