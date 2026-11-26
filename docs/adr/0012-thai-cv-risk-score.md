# 12. Validated Screening Criteria: Thai CV Risk Score, Abdominal Obesity, Known Disease

**Status**: Accepted (2026-11-26). Amends ADR 0002. Exact coefficients and cut-offs must be taken from the published sources and reviewed by the รพ.สต. nurse in M2 ([pilot meeting](../pilot-meeting-questions.md) §4).

**Context**:
A re-audit of `NcdRiskCalculator`, the lifestyle advisor and triage on origin/main (2026-11-26) found the following:
- **CVD** is a home-made count of 6 factors: BP, sugar, obesity, pulse outside 60–100, family history and personal history. It is not a validated score, pulse is not a standard CVD risk factor, and obesity and NCD history are counted twice.
- **Obesity**: BMI ≥ 25 alone is labelled "อ้วนลงพุง" (abdominal obesity). The tailored obesity advice never shows because the advisor switches on `OBESITY` / `METABOLIC` while the code is `METABOLIC_OBESITY`.
- **Glucose** is optional, but the form never asks whether the patient fasted, so every reading is judged against FPG cut-offs. An untested patient is shown as **low** diabetes risk on the patient PDF, in the nurse approval and in the analytics.
- **Known disease**: known hypertension under treatment can show as normal BP or low risk, and patients with established CVD still get a CVD "risk" score.
- **Triage** ignores hypoglycaemia, hypotension and abnormal pulse, and the double counting above inflates cases to "urgent".
- **Nurse override**: it changes the risk level but leaves the criteria and advice text unchanged, and it keeps no record of the original result.
- `ScreeningValidator` already enforces plausible ranges, but only in the UI.

Results shown to real patients and nurses must trace back to a recognised guideline.

**Decision**:
- **CVD**: use the **Thai CV Risk Score, non-laboratory version**, which estimates 10-year CVD risk from age, sex, smoking, diabetes, systolic BP and waist-to-height ratio. When total cholesterol is available, the lab version may be used. The form gains **smoking status**, and age comes from the date of birth.
- **Obesity**: the result is **อ้วนลงพุง** (abdominal obesity), with waist > height / 2 as the primary rule. BMI (Asian cut-offs 23 / 25) is shown as supporting context only. Fix the advisor code mismatch.
- **Diabetes**:
  - The form asks whether the reading is **fasting (≥ 8 h)**. Fasting readings use FPG cut-offs (≥ 126 high, 100–125 at risk); non-fasting readings use the guideline's random-glucose rule.
  - A missing reading is shown as **"ไม่ได้ตรวจ"** (not tested), never as low, everywhere it appears: the PDF, the detail page, the nurse approval and the analytics.
- **Known disease**: a person with a diagnosed condition is shown as **"ป่วยแล้ว – ติดตามการรักษา"** (already diagnosed, under follow-up) for that disease, not given a risk level. Established CVD skips the CVD risk score.
- **Triage**: add hypoglycaemia (< 70 mg/dL), hypotension (< 90/60) and pulse outside the validator band to the urgent rules. Remove the double counting.
- **Validation**: `ScreeningValidator` and the citizen-ID check digit also run in the BLoC/repository and on every SyncPackage import (ADR 0010).
- **Traceability**: every result stores the criteria text and the guideline version. A nurse override keeps the original result and records who changed it, when and why.

**Consequences**:
- Results become defensible to clinicians, and nurses already know the Thai CV Risk Score.
- The form gains two fields (smoking, fasting), which costs a little volunteer time per patient.
- The calculator gets golden-case tests taken from the source tables.
- Old screenings keep their old guideline version and are labelled as such rather than silently recalculated.
