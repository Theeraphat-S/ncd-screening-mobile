# 01: Smart Camera OCR & Thai ID Auto-Matching Flow

**What to build:** 
A VillageHealthVolunteer (VHV) can tap a camera scan button in the app to capture a Thai National Citizen ID card. An on-device OCR engine extracts the 13-digit ID number and patient name without requiring internet connectivity. The app immediately queries local SQLite storage: if an existing patient matches, it opens the screening form directly with patient details pre-populated; if no match is found, it opens the patient registration form with the extracted citizen ID and name pre-filled. A manual fallback and lighting toggle are provided for low-light/damaged card conditions.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] On-device Thai ID OCR scanner service parsing 13-digit IDs and Thai name prefixes accurately.
- [ ] Camera scanner UI overlay with card bounding guide and flashlight toggle.
- [ ] Auto-match lookup in Drift database matching existing patients and routing directly to screening form.
- [ ] Pre-filled registration fallback when patient is not in database.
- [ ] Unit & widget tests verifying OCR parser edge cases and navigation routing.
