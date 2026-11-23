# 02: Offline SQLite Sync Queue & Dynamic Header Sync Badge

**What to build:** 
Screenings and patient data recorded offline are saved to a dedicated `SyncQueueTable` in the Drift SQLite database. An automated sync manager monitors network connectivity, dequeuing pending transactions to dispatch to the backend REST API with exponential backoff on errors. A dynamic, reactive sync badge is rendered in the global AppBar (Green: Synced, Amber: Pending count, Blue: Syncing, Grey: Offline), supporting one-tap manual sync triggers.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] Drift `SyncQueueTable` schema recording entity type, action, JSON payload, retry count, and sync status.
- [ ] Offline sync manager service monitoring network connectivity and handling batch dispatch with retries.
- [ ] Reactive `SyncBadgeBloc` managing sync state and badge counters.
- [ ] AppBar `SyncBadge` widget reflecting live sync status with one-tap manual sync modal.
- [ ] Unit & repository tests verifying queue persistence, retry limits, and sync lifecycle events.
