# 14. Feature Flags for Unfinished Features; Real Emergency Call

**Status**: Accepted (2026-11-26). Amends ADR 0008 (triage alerts) and ADR 0009 (export).

**Context**:
Some features are presented as working but are simulated or broken:
- **Health data export**: the full-data mode compares the typed password with the stored PBKDF2 hash, so the correct password is always rejected and pasting the hash would pass. Both modes copy the CSV to the **system clipboard**, where other apps can read it. The diabetes and hypertension risk columns are always `NORMAL`. The "anonymised" mode keeps the area code, age, sex, village and date, so it is only pseudonymised.
- **Emergency call buttons** on the triage card show a "calling" snackbar but place no call.
- **LINE alerts**: the payload builder exists but nothing calls it, and LINE Notify was shut down in 2025.
- The ID-card OCR page has already been removed (3e0a221). Only `IdCardOcrParser` remains.

**Decision**:
- Add a small compile-time `FeatureFlags` class read from `--dart-define`. Every flag is off by default in prod.
- **Export**: hidden behind `FEATURE_EXPORT` until it is rebuilt after the pilot meeting establishes the target format (JHCIS / HOSxP PCU / 43-file). The rebuilt version will:
  - write a file through the share sheet, never the clipboard;
  - verify the password with `PasswordHasher`;
  - fix the risk columns;
  - use a real de-identification rule.
- **Emergency call**: becomes a real `tel:` call (`url_launcher`) to **1669**, plus the รพ.สต. number once confirmed. Two numbers currently conflict: `053-459034` in triage and `053-459-000` in the PDF footer.
- **LINE alerts**: removed rather than flagged. Notifying the nurse becomes a share or `tel:` action from the triage card.
- **Sync badge**: kept, since it already says data is saved on this device (4b0f79c). It becomes meaningful with the FileTransport (ADR 0010).

**Consequences**:
- Once M1 ships, staff no longer see controls that pretend to work, and the clipboard leak is closed. Until then, the export and the fake call buttons are still live.
- Nurses have no bulk export during the pilot. The Hub dashboard and PDFs cover the pilot's needs.
- The flags are compile-time, so turning one on needs a new build. That is intentional.
