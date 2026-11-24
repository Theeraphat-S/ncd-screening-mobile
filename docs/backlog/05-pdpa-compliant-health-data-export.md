# 05: PDPA-Compliant Health Data Export (Excel/CSV)

**What to build:** 
Nurses can export village screening records into MOPH/JHCIS-compatible Excel (.xlsx) and CSV spreadsheets. The export feature supports dual privacy modes: `ExportMode.anonymized` (masks Thai Citizen IDs and anonymizes patient names for public health epidemiology) and `ExportMode.clinicalFull` (unmasked full dataset for hospital HIS imports, protected by nurse credential verification).

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] Pure Dart spreadsheet export service generating formatted CSV and Excel (.xlsx) files according to MOPH/JHCIS data structure.
- [ ] PDPA masking filter replacing citizen IDs with `X-XXXX-XXXXX-XX-X` and anonymizing names.
- [ ] Export modal UI with village filter, date range picker, and mode selection.
- [ ] Nurse credential validation gate for unmasked clinical exports.
- [ ] Unit & widget tests verifying data formatting, masking rules, and file generation.
