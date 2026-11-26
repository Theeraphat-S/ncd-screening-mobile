# 13. Patient View Mode Replaces Patient Login

**Status**: Accepted (2026-11-26). Supersedes the patient citizen-ID + date-of-birth login (ac6db99, adf6a44, 2870249) and the patient role described in PRODUCT.md and CONTEXT.md.

**Context**:
On 2026-11-12/13, upstream hardened patient login rather than removing it. It now requires the citizen ID plus date of birth, returns a single generic error and checks the Thai ID check digit. The reasoning in PRODUCT.md is that all three roles are primary and patients view their own history and PDF.

Under ADR 0010 there is no server, so patient data exists only on staff devices. A patient would therefore always log in on an อสม.'s phone. There, anyone who knows a neighbour's citizen ID and birth date, both easy to learn in a village, can open that neighbour's health record. The current flow also has:
- no attempt limit;
- no idle lock for patient sessions;
- a default date of birth of 1980-01-01 for patients imported without one.

Most patients are elderly and would not install an app or import files themselves.

**Decision**:
- Remove the patient role from the user-type selection page and from login.
- An อสม. or nurse opens a patient's record and taps **"แสดงให้ผู้ป่วยดู"**. This starts **PatientViewMode**:
  - It is a full-screen, large-type view built on the existing ElderlyAccessibilityMode widgets.
  - It is scoped to that one patient, with no navigation to other records or staff features.
  - Leaving it requires the staff PIN (ADR 0011).
- Patients take their results home as the Thai PDF report (share sheet or print).
- Self-service access for patients on their own phones is deferred until a server exists. Revisit it then, with a stronger factor than the date of birth.
- Update PRODUCT.md, CONTEXT.md and the README to match.

**Consequences**:
- It closes the citizen-ID + DOB access path, and patient data never leaves staff-controlled devices.
- Patients cannot check their results between visits; the PDF covers that during the pilot.
- The patient-role login, session flow and tests are removed, and the patient history and result widgets are reused inside PatientViewMode.
