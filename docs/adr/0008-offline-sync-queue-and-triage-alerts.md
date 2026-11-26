# 8. Offline Sync Queue & Clinical Triage Alerts

**Status**: Superseded (2026-11-26) by ADR 0010 for sync and ADR 0014 for alerts. The durable `sync_queue` outbox stays, but there is no REST backend. LINE Notify was discontinued in 2025, and the emergency call becomes a real `tel:` call. The nurse urgent queue stays.

**Context & Decision**: 
The app operates in remote subdistrict areas where internet connectivity is intermittent. We established an SQLite-backed `OfflineSyncQueue` that records screening transactions locally and synchronizes them via REST APIs upon network recovery, coupled with a CSV/Excel export engine for legacy HIS integration. Critical screening results (High Risk / Hypertensive Crisis) trigger immediate multi-channel triage: an in-app Urgent Home Visit queue for nurses, automated LINE webhook alerts, and an emergency contact action card for patients.

**Consequences**: 
Ensures zero data loss in remote screening camps. Guarantees immediate visibility of life-threatening clinical anomalies to primary care nurses. Requires handling idempotency on the sync endpoint and robust webhook retry policies.
