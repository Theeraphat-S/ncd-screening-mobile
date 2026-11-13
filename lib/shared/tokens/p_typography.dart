import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

/// Centralized Typography & Text Style Tokens for the application.
///
/// Scale (sp): 12 · 13 · 14 · 15 · 16 · 18 · 20 · 22 · 26. Nothing below 12.
/// Running text carries [_readingHeight] so stacked Thai vowels and tone
/// marks do not collide between lines.
class PTypography {
  PTypography._();

  static const double _readingHeight = 1.45;
  static const double _headingHeight = 1.3;

  static const TextStyle appBarTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle sectionHeader = TextStyle(
    height: _headingHeight,
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
    height: _readingHeight,
    fontSize: 14,
    color: PColor.contentColor,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: PColor.contentColor,
  );

  static const TextStyle bodyMuted = TextStyle(
    height: _readingHeight,
    fontSize: 14,
    color: PColor.textNeutralColor,
  );

  static const TextStyle caption = TextStyle(
    height: _readingHeight,
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
    height: _readingHeight,
    fontSize: 15,
    color: PColor.textNeutralColor,
  );

  static const TextStyle fieldError = TextStyle(
    height: _readingHeight,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: PColor.errorColor,
  );

  static const TextStyle fieldWarning = TextStyle(
    height: _readingHeight,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: PColor.riskModerate,
  );

  // --- Headings / extras used by auth, search and result pages
  static const TextStyle pageTitle = TextStyle(
    height: _headingHeight,
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
    height: _readingHeight,
    fontSize: 14,
    color: PColor.textSecondary,
  );

  static const TextStyle captionSecondary = TextStyle(
    height: _readingHeight,
    fontSize: 13,
    color: PColor.textSecondary,
  );

  static const TextStyle captionContent = TextStyle(
    height: _readingHeight,
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
    height: _readingHeight,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: PColor.errorColor,
  );

  /// Text typed into a form field. 16sp also stops iOS zooming on focus.
  static const TextStyle fieldInput = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: PColor.contentColor,
  );

  static const TextStyle fieldHelper = TextStyle(
    height: _readingHeight,
    fontSize: 13,
    color: PColor.textSecondary,
  );

  static const TextStyle dialogTitle = TextStyle(
    height: _headingHeight,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: PColor.contentColor,
  );

  static const TextStyle pinDigit = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
  );
}
