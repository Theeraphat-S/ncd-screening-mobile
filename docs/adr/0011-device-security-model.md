# 11. On-Device Security Model

**Status**: Accepted (2026-11-26). Builds on the hardening already on main (ac6db99, adf6a44, aae62fb, d942a11) and amends ADR 0003 and ADR 0009.

**Context**:
With no server (ADR 0010), all pilot data lives on phones and one PC that can be lost, so the device itself is the security boundary.

Already done on main:
- PBKDF2-SHA256 password hashing (10,000 iterations, on a worker isolate). Empty passwords are rejected in the repository.
- An optional 6-digit staff PIN with a salted hash, plus opt-in biometric unlock.
- A 15-minute idle lock. Five wrong PINs clear the PIN.
- `allowBackup="false"`. Demo credentials are pre-filled only in debug builds.

A re-audit on 2026-11-26 found these gaps:
- The database is not encrypted.
- Demo accounts (`NUR001` / `password123`) are seeded in every flavor, including prod and the Windows hub.
- Password login and the lock-screen password fallback have no attempt limit, so clearing the PIN only moves an attacker to unlimited password guesses.
- Release builds are signed with the debug key, and the application ID is a template leftover (`com.fldp.mobileApp`).
- On Windows, `local_auth` throws when `biometricOnly: true`, so biometric unlock always fails on the Hub.
- There is no `FLAG_SECURE` and no `dataExtractionRules` (Android 12+ device-to-device transfer).

**Decision**:
- **Database**:
  - Drift on **SQLCipher**, with a plaintext-to-encrypted migration for existing installs.
  - The random 256-bit database key is stored with `flutter_secure_storage` (Android Keystore / Windows DPAPI).
  - On Windows, the Hub's database moves from the user's Documents folder to the app-support directory.
- **Credentials**:
  - PBKDF2 iterations are raised to the highest value that keeps verification at or under 1 s on the pilot's lowest-end phone, measured with `tool/device_bench.dart`, with a target of at least 100k.
  - Legacy plaintext rows are migrated once and are no longer accepted after that.
- **App lock**:
  - The PIN becomes mandatory for staff.
  - Auto-lock after **5 minutes** idle; the screen is also hidden when the app goes to the background.
  - One failure counter covers both PIN and password. **10 consecutive failures wipe local data** (database, secure storage and drafts). This is safe because the Hub holds the master copy; a wiped Spoke is re-provisioned.
  - Biometric unlock uses `biometricOnly: false` on Windows (Windows Hello).
- **Screen and backup**: set `FLAG_SECURE` on screens that show patient data, and add `dataExtractionRules` that exclude the database and preferences.
- **DeviceKey**:
  - The Hub generates a separate AES-256-GCM key for each Spoke and delivers it in the provisioning QR, together with the account and the VhvAssignment.
  - The Hub keeps a device registry and can **revoke** a lost device. It rejects packages from revoked keys and sends the revoked list down to Spokes.
- **Data minimisation (VhvAssignment)**: a Spoke only receives patients in the villages or households assigned to that อสม.
- **Builds**:
  - Demo seed data exists only when `--dart-define=flavor=dev|local`. The prod flavor starts empty, and the first nurse account is created on the Hub.
  - Release builds are signed with a real keystore loaded from an untracked `android/key.properties` (see `docs/RELEASE.md`, added in M0).
  - The application ID becomes **`io.github.theeraphats.ncdscreening`** (`.dev`, `.local`) before the first real-key release.

**Consequences**:
- A lost phone exposes at most one อสม.'s villages, and only if the PIN is also broken.
- Forgotten PINs and wiped devices require re-provisioning from the Hub.
- This adds `sqlcipher_flutter_libs` and `cryptography`, and a key-management surface that needs tests.
- Changing the application ID means installs of the old ID are a different app. That is acceptable only because nothing has been distributed yet.
