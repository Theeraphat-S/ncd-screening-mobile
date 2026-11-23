# 03: Elderly Accessibility Mode & Simplified Bento Health Result UI

**What to build:** 
Patients and elderly villagers view their 4 NCD risk assessment results in a simplified, highly accessible interface. High-contrast Bento cards provide intuitive green/yellow/red status indicators with plain Thai language lifestyle, dietary, and physical activity advice. A dynamic accessibility toggle switch allows users to switch between standard (1.0x) and elderly (1.35x) font scales dynamically.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] `AccessibilityCubit` providing dynamic typography scaling and contrast preferences across the app.
- [ ] Redesigned `PatientResultCard` with high-contrast Bento layout and plain Thai actionable guidance for all 4 NCD conditions.
- [ ] Dynamic font-size toggle in patient view with instant smooth redraw.
- [ ] Unit & widget tests verifying accessibility scale transitions and Thai advice generation.
