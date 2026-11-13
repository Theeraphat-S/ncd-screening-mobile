import 'package:flutter/material.dart';
export 'p_shadow.dart';

class PColor {
  // Brand & Dominant Clinical Primary (Teal & Sky Medical Palette)
  static const Color primaryColor = Color(0xFF0D9488); // Teal 600
  static const Color primaryDark = Color(0xFF115E59); // Teal 800
  static const Color primaryLight = Color(0xFFCCFBF1); // Teal 100
  static const Color secondaryColor = Color(0xFF0284C7); // Sky 600

  // Surfaces & Backgrounds
  static const Color backgroundColor = Color(0xFFF8FAFC); // Slate 50
  static const Color neutralColor = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceSubtle = Color(0xFFF1F5F9); // Slate 100

  // Typography & Borders
  static const Color textNeutralColor = Color(0xFF64748B); // Slate 500
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color contentColor = Color(0xFF0F172A); // Slate 900
  static const Color borderSubtle = Color(0xFFE2E8F0); // Slate 200
  static const Color borderStrong = Color(0xFFCBD5E1); // Slate 300
  static const Color errorColor = Color(0xFFDC2626); // Red 600

  // High Contrast (WCAG AAA) Accessibility Tokens
  static const Color hcBackground = Color(0xFF121212); // Dark Charcoal
  static const Color hcSurface = Color(0xFF1E1E1E); // Elevated Dark Card
  static const Color hcSurfaceElevated = Color(
    0xFF2C2C2C,
  ); // Active/Hover Surface
  static const Color hcAccent = Color(0xFFFFD600); // Vivid Yellow Accent
  static const Color hcCyan = Color(0xFF00E5FF); // Vivid Cyan Accent
  static const Color hcText = Color(0xFFFFFFFF); // Pure White Text
  static const Color hcTextMuted = Color(
    0xFFB0B0B0,
  ); // High Contrast Muted Text

  // Calibrated Clinical Risk Tokens (WCAG AA Compliant)
  static const Color riskLow = Color(0xFF059669); // Emerald 600
  static const Color riskLowBg = Color(0xFFECFDF5); // Emerald 50
  static const Color riskModerate = Color(0xFFD97706); // Amber 600
  static const Color riskModerateBg = Color(0xFFFFFBEB); // Amber 50
  static const Color riskHigh = Color(0xFFDC2626); // Red 600
  static const Color riskHighBg = Color(0xFFFEF2F2); // Red 50

  // Review & Workflow Status Indicators
  static const Color statusPending = Color(0xFFEA580C); // Orange 600
  static const Color statusPendingBg = Color(0xFFFFEDD5); // Orange 100
  static const Color statusApproved = Color(0xFF059669); // Emerald 600
  static const Color statusApprovedBg = Color(0xFFECFDF5); // Emerald 50

  static const Color primaryTint = Color(0xFF5EEAD4); // Teal 300 (decorative only)
  static const Color secondaryLight = Color(0xFFE0F2FE); // Sky 100
  static const Color statusApprovedDark = Color(0xFF047857); // Emerald 700 (button fill, 5.5:1 with white)
  static const Color riskHighDark = Color(0xFFB91C1C); // Red 700 (text on tint)

  // Role accents (user type selection)
  static const Color roleSelfBg = Color(0xFFE0F2FE); // Sky 100
  static const Color roleNurse = Color(0xFF4F46E5); // Indigo 600
  static const Color roleNurseBg = Color(0xFFEEF2FF); // Indigo 50

  // Data categories (charts) — kept off the risk hues so a chart never reads as a risk level
  static const Color chartMale = Color(0xFF3B82F6); // Blue 500
  static const Color chartFemale = Color(0xFFDB2777); // Pink 600
  static const Color chartAgeYoung = Color(0xFF0369A1); // Sky 700 (also used as text, 5.9:1)
  static const Color chartAgeMid = Color(0xFF0F766E); // Teal 700 (5.5:1)
  static const Color chartAgeOld = Color(0xFF4F46E5); // Indigo 600 (6.3:1)

  static Color getRiskColor(String? risk) {
    if (risk == null) {
      return riskLow;
    }
    final lower = risk.toLowerCase();
    if (lower.contains('สูง') || lower.contains('high')) {
      return riskHigh;
    }
    if (lower.contains('ปานกลาง') || lower.contains('moderate')) {
      return riskModerate;
    }
    return riskLow;
  }

  static Color getRiskBgColor(String? risk) {
    if (risk == null) {
      return riskLowBg;
    }
    final lower = risk.toLowerCase();
    if (lower.contains('สูง') || lower.contains('high')) {
      return riskHighBg;
    }
    if (lower.contains('ปานกลาง') || lower.contains('moderate')) {
      return riskModerateBg;
    }
    return riskLowBg;
  }
}
