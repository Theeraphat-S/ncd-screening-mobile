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
    fontSize: 13.5,
    color: PColor.textNeutralColor,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: PColor.textNeutralColor,
  );

  static const TextStyle badge = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 12.5,
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
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    color: PColor.errorColor,
  );

  static const TextStyle fieldWarning = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    color: PColor.riskModerate,
  );
}
