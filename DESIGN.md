# Design System & UI Specification: NCD Screening Mobile App (รพ.สต.แม่อาย)

> **Design Baseline Configuration**:
> - **DESIGN_VARIANCE**: 6 (Structured, modern, contextual asymmetric touches, mobile-hardened)
> - **MOTION_INTENSITY**: 6 (Fluid transitions, spring tactile physics, non-blocking micro-interactions)
> - **VISUAL_DENSITY**: 5 (High clinical legibility, breathable data cards, distinct hierarchy for field workers)

---

## 1. Design Philosophy & Creative Direction

### 1.1 Aesthetic Identity: "Nordic Clinical Precision"
The NCD Screening Mobile Application serves three distinct user personas: **Elderly / Rural Patients**, **Community Health Volunteers (VHV/อสม.)** on field tablets/smartphones, and **Primary Care Nurses** reviewing critical health metrics.

The visual direction replaces generic purple gradients and clunky material blocks with a **Nordic Clinical & Public Health Modernism** aesthetic:
- **Calm, High-Trust Atmosphere**: Off-white canvases (`#F8FAFC` Slate-50) paired with deep surgical teal / cobalt (`#0F766E` / `#0284C7`) rather than oversaturated AI purple glows.
- **Immediate Clinical Clarity**: Risk levels (Low, Moderate, High) are calibrated with high contrast, accessible, desaturated status badges with subtle tint backgrounds (`#ECFDF5`, `#FFFBEB`, `#FEF2F2`).
- **Tactile Ergonomics for Field Work**: Generous touch targets (min 48x48dp), clear elevation without heavy drop shadows, and high-readability Thai typography (Sarabun / System Sans).

---

## 2. Token Specifications

### 2.1 Color Palette & Calibration (Max 1 Main Primary + Calibrated Neutrals)

```dart
// lib/shared/tokens/p_colors.dart
class PColors {
  // Brand & Dominant Clinical Primary
  static const Color primary = Color(0xFF0F766E);       // Teal 700 - High trust medical teal (5.5:1 with white)
  static const Color primaryDark = Color(0xFF115E59);   // Teal 800 - Deep forest teal
  static const Color primaryLight = Color(0xFFCCFBF1);  // Teal 100 - Soft tint background
  static const Color accent = Color(0xFF0284C7);        // Sky 600 - Action secondary

  // Surface & Canvas Neutrals (Anti-Pure-Black & Pure-White contrast)
  static const Color background = Color(0xFFF8FAFC);    // Slate 50
  static const Color surface = Color(0xFFFFFFFF);       // Crisp white cards
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF1F5F9);  // Slate 100

  // Text & Content Hierarchy
  static const Color textPrimary = Color(0xFF0F172A);    // Slate 900
  static const Color textSecondary = Color(0xFF475569);  // Slate 600
  static const Color textMuted = Color(0xFF94A3B8);      // Slate 400
  static const Color borderSubtle = Color(0xFFE2E8F0);   // Slate 200
  static const Color borderStrong = Color(0xFFCBD5E1);   // Slate 300

  // Clinical Risk Calibrations (WCAG AA Contrast Compliant)
  static const Color riskLow = Color(0xFF047857);        // Emerald 700
  static const Color riskLowBg = Color(0xFFECFDF5);      // Emerald 50
  static const Color riskModerate = Color(0xFFB45309);   // Amber 700
  static const Color riskModerateBg = Color(0xFFFFFBEB); // Amber 50
  static const Color riskHigh = Color(0xFFB91C1C);       // Red 700
  static const Color riskHighBg = Color(0xFFFEF2F2);     // Red 50

  // Status Indicators
  static const Color statusPending = Color(0xFFC2410C);  // Orange 700
  static const Color statusPendingBg = Color(0xFFFFEDD5);// Orange 100
  static const Color statusApproved = Color(0xFF047857); // Emerald 700
  static const Color statusApprovedBg = Color(0xFFECFDF5);
}
```

### 2.2 Typography Scale
- **Display / H1 (Screen Titles)**: 24–28sp, Bold (`w700`), Letter spacing `-0.5px`, Line height `1.2`.
- **H2 (Card Headers & Section Grouping)**: 18–20sp, Semi-bold (`w600`), Line height `1.3`.
- **Body (Primary Inputs, Labels, Vitals)**: 15–16sp, Regular (`w400`) / Medium (`w500`), Slate-900.
- **Secondary (Subtitles, Timestamps, Help Text)**: 13–14sp, Regular (`w400`), Slate-600.
- **Data & Numerical Metrics (BMI, BP, Blood Sugar)**: 16–22sp, Bold (`w700`), `font-family: monospace / tabular figures` where applicable for rapid scanning.

### 2.3 Spacing, Borders & Shadows
- **Spacing Grid**: Multiples of 4/8dp (`8dp`, `12dp`, `16dp`, `20dp`, `24dp`, `32dp`).
- **Radius Standards**:
  - Small pills & chips: `8dp` – `12dp`
  - Cards & Containers: `16dp` – `20dp`
  - Floating Action & Bottom Sheet: `24dp` top radius
- **Shadows**: Clean ambient diffusion instead of harsh black drops:
  - `BoxShadow(color: Color(0x0A0F172A), blurRadius: 12, offset: Offset(0, 4))`
  - 1px border fallback (`border: Border.all(color: PColors.borderSubtle)`).

---

## 3. Core Screen Architectures & Redesign Blueprint

### 3.1 Role Selection & Auth Flow (`UserTypeSelectionPage` / `LoginPage`)
- Hero header with hospital branding badge (`รพ.สต.แม่อาย`) in refined medical teal and subtitle context.
- Distinct Persona Cards with visual role badges (Patient: Blue/Self-care, VHV: Teal/Field Community, Nurse: Indigo/Clinical Leadership).
- Tactile spring press feedback (`AnimatedScale` on tap down).
- Modern numeric/citizen ID input with automatic digit grouping (`X-XXXX-XXXXX-XX-X`).

### 3.2 Patient Management & Search (`VhvPatientListPage` / `NursePatientListPage`)
- Dynamic Search & Filter bar with active village indicator chips.
- Patient Cards featuring:
  - Initials avatar with tinted background.
  - Quick clinical badge: Last screening date + Risk Status pill (Low/Mod/High).
  - One-tap action shortcuts: "บันทึกคัดกรองใหม่" (New Screening), "ดูประวัติ" (View History).
- Clean empty states with intuitive illustration placeholders and "เพิ่มผู้ป่วยใหม่" direct CTA.

### 3.3 4-NCD Screening Assessment Flow (`ScreeningFormPage` / `RiskAssessmentResultPage`)
- Stepper / Section grouped accordion (1. ข้อมูลกายภาพ & สัญญาณชีพ -> 2. พฤติกรรม & ประวัติครอบครัว -> 3. ผลแล็บ).
- Real-time instant BMI and BP category indicator as numbers are typed.
- Result Screen:
  - **Hero Overall Status Card** with prominent clinical summary badge.
  - **4-Card Bento Grid** for the 4 NCD conditions (เบาหวาน, ความดัน, หลอดเลือดหัวใจ, อ้วนลงพุง) with progress meters and actionable health recommendations.
  - Floating action bar: "ส่งให้พยาบาลตรวจสอบ", "ออกรายงาน PDF", "พิมพ์ผล".

### 3.4 Nurse Village Analytics Dashboard (`NurseVillageListPage`)
- Sticky Village Selector chip carousel with coverage percentage.
- KPI Stat Bento: Total Screened, High Risk Alert count, Pending Approvals with mini spark indicators.
- 4 NCD Risk Distribution meters with color-coded multi-segment bars.
- "High-Risk Priority Queue" table with quick nurse review modal trigger.

---

## 4. Interaction & Motion Guidelines

1. **Tactile Button Clicks**: All action buttons and cards implement micro-scaling (`0.98` on tap).
2. **Smooth Screen Transitions**: Hero animations for patient avatars and shared element cards transitioning into detail views.
3. **Optimistic UI & Loading States**: Skeleton loaders (`Shimmer`) tailored to exact card dimensions instead of generic circular spinners.
4. **Haptic Feedback**: Subtle vibration on risk calculation completion and status approval.

---

## 5. Anti-Slop Enforcement Checklist (Verified)
- [x] **No Generic AI Purple/Neon**: Replaced with Calibrated Clinical Teal & Slate neutrals.
- [x] **No Pure Black (#000000)**: Slate 900 (`#0F172A`) utilized for all primary text.
- [x] **No Emojis in Clinical UI**: Replaced with high-grade SVG icons / Material Symbols.
- [x] **Clear Information Hierarchy**: Bold metrics with units, distinct risk badges, no cluttered unseparated card walls.
- [x] **Mobile Responsive Hardening**: Safe area compliance, dynamic scroll physics, keyboard-aware bottom padding.
