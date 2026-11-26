# 10. Serverless Hub-and-Spoke Sync via Encrypted Files

**Status**: Accepted (2026-11-26). Supersedes the cloud/REST parts of ADR 0001 and ADR 0008. Hub hardware still to be confirmed with รพ.สต. ([pilot meeting](../pilot-meeting-questions.md) §2.1).

**Context**:
The app is moving from a submitted mini-project to a real pilot at รพ.สต.แม่อาย. It is built by one developer with zero budget.

Today (origin/main `6aa8916`):
- Each device has its own Drift database. Screenings are written to a durable `sync_queue` outbox.
- Dispatch goes through a `SyncTransport` seam whose only implementation is `NoServerTransport`, so data never leaves the device. อสม. and nurse must share one phone and switch accounts.
- The outbox payload holds only vitals and ids. It lacks patient, histories and results, and it is enqueued outside the save transaction.
- Entity tables have no `updatedAt`, origin or tombstone columns. `patients.patient_citizen_id` is not unique, and deleting a patient is a hard delete.

A cloud backend (e.g. Supabase free tier) was rejected for the pilot:
- The nearest free region is outside Thailand, which raises the cross-border transfer rules for sensitive health data (PDPA §28).
- Free projects pause after inactivity.
- The data controller has not agreed to any hosting.

**Decision**:
- **Topology**: one **Hub** per รพ.สต., a Windows PC running the Flutter Windows build (fallback: a shared Android tablet). อสม. phones are **Spokes**. There is no server.
- **Flow**:
  - **Up (Spoke → Hub)**: new or edited patients and screenings since the last acknowledged package.
  - **Down (Hub → Spoke)**: the patient roster for the อสม.'s VhvAssignment (ADR 0011), nurse review results, the อสม.'s account and the revoked-device list.
  - The Hub is the source of truth. Patients are merged by citizen ID (which becomes `UNIQUE`). Screenings are immutable records keyed by a UUID generated on the Spoke, so re-importing a package is idempotent.
  - Every import re-runs `ScreeningValidator` and the citizen-ID check digit.
- **Transport**: a `FileTransport` implementing the existing `SyncTransport` seam. It writes and reads a **SyncPackage** file (`.ncd`): versioned JSON, gzip-compressed, AES-256-GCM encrypted with the sending device's DeviceKey (ADR 0011). The file is shared through the Android share sheet (LINE, Quick Share, Bluetooth, USB). QR codes are used only for small payloads: **DeviceProvisioning** and single-record transfers.
- **Schema v6**: `updatedAt`, `originDeviceId` and `deletedAt` (tombstones instead of hard deletes) on synced entities. Also tables for devices, VHV assignments and an import log. The outbox enqueue moves inside the save transaction and carries the full record.
- **Backup**: the Hub writes a daily encrypted full backup (USB or the unit's Google Drive folder) and offers restore. The Hub must never be the only copy of the data.

**Consequences**:
- Zero running cost, and data stays on devices controlled by the unit.
- Sync is manual and periodic, so the nurse dashboard is only as fresh as the last imported package.
- The package schema needs explicit versioning and migration from day one.
- The same `SyncPackage` can later be posted by an HTTP `SyncTransport`, so moving to a backend does not discard this work.
