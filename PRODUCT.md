# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

<!-- Inferred, not confirmed: the app is one Flutter Material codebase with APK/IPA/Windows build scripts; Android is assumed as the primary field device. Change to `adaptive` or `ios` if that is wrong. -->

## Users

Three roles share one app (confirmed: all three are primary):

- **อสม. (village health volunteers)**: record patient data and run the 4-NCD screening form in the community, at patients' homes, often with weak or no connectivity.
- **พยาบาล (nurses at รพ.สต.แม่อาย)**: review and approve or adjust risk results, manage อสม., read village-level analytics and the high-risk queue.
- **ผู้ป่วย / บุคคลทั่วไป (patients)**: sign in with a 13-digit citizen ID to view their own history and results and export a PDF. Many are elderly.

## Product Purpose

Offline-first screening of risk for four non-communicable diseases (diabetes, hypertension, coronary heart disease/CVD, central obesity) for รพ.สต.แม่อาย, Chiang Mai. Success: screening completed on-site without internet, results understood immediately, high-risk people reach the nurse's follow-up queue.

## Positioning

A screening and triage tool built for one sub-district health unit's actual workflow: offline capture, Thai-language results and PDF reports (Buddhist Era dates), and a nurse approval step. It is not a diagnostic system.

## Operating Context

- Offline-first: data is stored locally (Drift SQLite) and synced when a connection returns (offline sync queue).
- Field use on phones/tablets; ID-card OCR scan speeds up patient entry.
- Device is protected by app lock / PIN.
- Reports are Thai clinical-summary PDFs (Sarabun font) with the nurse's approval status.
- Patient-facing results offer an accessibility mode for elderly users (larger text, high contrast, plain-language explanations).

## Capabilities and Constraints

- Risk levels: ต่ำ / ปานกลาง / สูง; screening status: รอตรวจ / อนุมัติแล้ว.
- Screening inputs: vitals, BMI, waist, BP, fasting blood sugar (optional), health and family history.
- Domain terminology is defined in CONTEXT.md; use its terms and avoid the "Avoid" aliases.
- Stack: Flutter (Material 3), BLoC, get_it, Drift; the project already exists.
- Open, not decided: whether real patient data is in use, PDPA handling beyond the current lock, and any claims about clinical validation. Do not invent them.

## Brand Commitments

Name: NCD Screening Mobile, รพ.สต.แม่อาย. Thai-first copy. Existing design system is recorded in DESIGN.md.

## Evidence on Hand

SRS PDF in the repo root, CONTEXT.md, PROJECT.md, README.md, and an automated test suite. No testimonials, usage numbers, or clinical-validation evidence exist; do not fabricate any.

## Product Principles

1. Works with no signal: no flow may depend on the network to finish a screening.
2. Results must be legible to a tired volunteer in sunlight and to an elderly patient.
3. Never present a screening result as a diagnosis; the nurse's approval is the authority.
4. Health data is sensitive: show the minimum necessary and keep the lock in place.
5. Thai language and Thai conventions (พ.ศ., ชื่อ-สกุล, 13-digit ID) come first.

## Accessibility & Inclusion

Elderly and low-vision patients are a core audience: large type, strong contrast, plain-language results (ElderlyAccessibilityMode). Touch targets must suit use in the field.
