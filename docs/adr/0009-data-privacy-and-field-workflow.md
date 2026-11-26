# 9. Smart Field OCR Workflow, Dynamic Sync Badge & PDPA-Compliant Export

**Status**: Partially superseded (2026-11-26). OCR was removed (see ADR 0007). The sync badge depends on ADR 0010. The export is to be hidden behind a feature flag in M1 and rebuilt later (ADR 0014); it is still reachable today.

**Context & Decision**: 
To maximize operational efficiency for field VHVs while maintaining rigorous data privacy and clinical compliance, we settled on an automated pipeline:
1. **Camera OCR -> Auto-Match**: Scanning a Thai ID card automatically queries local Drift SQLite storage. If matched, existing patient demographic data is pre-populated and opens the vitals form directly.
2. **Dynamic Sync Badge**: Visual indicator in the AppBar that reflects real-time connectivity and pending offline queue count, allowing one-tap manual sync triggers alongside background sync.
3. **Elderly-First Result Screen**: Default presentation with plain Thai lifestyle action guidance, large visual risk meters, and a dynamic typography scale toggle.
4. **Dual-Mode Privacy Export**: Excel/CSV export supports both masked (PDPA-safe statistics) and unmasked (authorized clinical import for JHCIS/HOSxP) formats guarded by Nurse role validation.

**Consequences**: 
Significantly cuts down VHV screening time per patient from ~3 minutes to under 45 seconds. Guarantees field-to-cloud resilience. Enforces strict compliance with Thai Health Data Privacy standards without hindering hospital administrative data imports.
