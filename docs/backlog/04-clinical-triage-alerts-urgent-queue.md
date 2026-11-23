# 04: Clinical Triage Alerts & Urgent Home Visit Queue

**What to build:** 
When a screening records High Risk for any NCD or life-threatening vital anomalies (e.g. SBP >= 180 or DBP >= 110), the system automatically flags the patient for urgent triage. An "Urgent Home Visit Queue" is displayed on the Nurse dashboard with one-tap patient contact actions and clinical notes. Simultaneously, a webhook alert (LINE Notify) is dispatched, and an emergency action card with the local subdistrict hospital's phone dialer is rendered on the patient's view.

**Blocked by:** 02: Offline SQLite Sync Queue & Dynamic Header Sync Badge

**Status:** ready-for-agent

- [ ] Clinical triage risk evaluator checking critical vital thresholds (hypertensive crisis, severe hyperglycemia) and flagging `requiresImmediateVisit`.
- [ ] Nurse dashboard "Urgent Home Visit" tab and triage card with patient contact shortcuts.
- [ ] Notification service triggering external webhooks (LINE Notify / Public Health alerts).
- [ ] Emergency hospital contact action card in patient summary with one-touch phone dialer.
- [ ] Unit & widget tests verifying triage condition triggers and urgent queue filtering.
