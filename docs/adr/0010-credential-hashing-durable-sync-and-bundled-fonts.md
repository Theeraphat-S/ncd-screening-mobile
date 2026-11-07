# 10. Credential Hashing, Durable Sync Outbox & Bundled Thai Fonts

**Context & Decision**:
- Staff (VHV, nurse) passwords were stored and compared in plaintext in SQLite, and the nurse export check compared the same plaintext. Passwords are now stored only as salted PBKDF2-HMAC-SHA256 hashes (`PasswordHasher`). Schema v4 migrates existing rows by hashing them and then drops the plaintext columns. Empty passwords never authenticate, and read models never carry password values.
- The offline sync queue was an in-memory list that marked items as synced after a simulated delay. It is now a durable `sync_queue` table. An item is removed only after the transport confirms it. Until a backend endpoint is configured, the default `UnconfiguredSyncTransport` leaves every item pending and the badge reports that the data is still on the device.
- The PDF report downloaded Sarabun at runtime and fell back to Helvetica, which has no Thai glyphs, when offline. Sarabun Regular and Bold (SIL OFL 1.1) are now bundled under `assets/fonts/`.

**Consequences**:
- Login costs roughly one PBKDF2 derivation (210,000 iterations). This is an intentional trade-off for an offline device; tune `PasswordHasher.defaultIterations` if field devices are too slow.
- Demo accounts seeded for development (`password123`) remain in the database. Before a production rollout, replace them with a first-run account setup.
- Real synchronisation still requires a server contract (endpoint, idempotency key per item, and retry policy) that is not in this repository.
- Schema migration `3 -> 4` is covered by `test/unit/password_security_test.dart`.
