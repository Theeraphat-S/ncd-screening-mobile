# 11. Citizen ID Column Encryption & Backup Exclusion

**Context & Decision**:
- 13-digit national IDs were stored in plaintext in SQLite (`patients.patient_citizen_id`, `vhvs.vhv_citizen_id`), appeared in PDF file names, and were the only credential for patient login.
- Each ID is now stored as AES-256-GCM ciphertext (`CitizenIdCipher`). Exact lookups (patient login, VHV login, duplicate check during ID scan) use an HMAC-SHA256 index under a separate key. Both keys are generated once and kept in the platform keystore (`flutter_secure_storage`), never in the database.
- Schema v5 encrypts existing rows in place and compacts the file with `VACUUM` afterwards. Name and partial-ID search still work because filtering happens in memory after decryption.
- Full-database SQLCipher was rejected: `sqlcipher_flutter_libs` is discontinued (`0.7.0+eol`).
- PDF file names use the screening ID only.
- Android `allowBackup` is `false`, and the data-extraction rules exclude cloud and device transfer.
- Clinical (identifiable) CSV exports are shared as a file through the system share sheet instead of the clipboard. Anonymized exports still use the clipboard.
- Patient login remains citizen-ID-only, as specified in the README. This is a known risk: the national ID acts as both identifier and credential. Moving to a PIN set at registration is a separate piece of work.

**Consequences**:
- If the keys are lost (app data cleared, device reset, keystore wiped), stored citizen IDs cannot be recovered. This is deliberate, but field staff need a documented recovery procedure before rollout.
- Each protected read or write costs one AES or HMAC operation. Patient lists decrypt in bulk, which is acceptable at village scale.
- `VACUUM` removes free pages left by the migration. It is not a secure erase on flash storage.
- Share-sheet files stay in the app cache until the OS purges them.
