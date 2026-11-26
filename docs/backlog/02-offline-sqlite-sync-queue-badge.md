# 02: Offline SQLite Sync Queue & Dynamic Header Sync Badge

> **Status (2026-11-26)**: The durable queue and sync badge are done (be39a7e, 4b0f79c). The REST dispatch is replaced by file-based hub-and-spoke sync, see [ADR 0010](../adr/0010-offline-hub-spoke-file-sync.md) and ROADMAP M4.

**What to build:** 
Screenings and patient data recorded offline are saved to a dedicated `SyncQueueTable` in the Drift SQLite database. An automated sync manager monitors network connectivity, dequeuing pending transactions to dispatch to the backend REST API with exponential backoff on errors. A dynamic, reactive sync badge is rendered in the global AppBar (Green: Synced, Amber: Pending count, Blue: Syncing, Grey: Offline), supporting one-tap manual sync triggers.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] Drift `SyncQueueTable` schema recording entity type, action, JSON payload, retry count, and sync status.
- [ ] Offline sync manager service monitoring network connectivity and handling batch dispatch with retries.
- [ ] Reactive `SyncBadgeBloc` managing sync state and badge counters.
- [ ] AppBar `SyncBadge` widget reflecting live sync status with one-tap manual sync modal.
- [ ] Unit & repository tests verifying queue persistence, retry limits, and sync lifecycle events.
