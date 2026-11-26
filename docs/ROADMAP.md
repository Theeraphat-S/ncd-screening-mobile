# Roadmap: นำร่องใช้จริงที่ รพ.สต.แม่อาย

> ตกลงเมื่อ 2026-11-26 หลังส่งมินิโปรเจกต์ · ผู้พัฒนา 1 คน · งบ 0 · สถานะอิงจาก `main` ที่ `6aa8916`
> การตัดสินใจหลัก:
> - [ADR 0010](adr/0010-offline-hub-spoke-file-sync.md) sync แบบไม่มี server
> - [0011](adr/0011-device-security-model.md) ความปลอดภัยบนเครื่อง
> - [0012](adr/0012-thai-cv-risk-score.md) เกณฑ์ทางการแพทย์
> - [0013](adr/0013-patient-view-mode-replaces-patient-login.md) โหมดแสดงให้ผู้ป่วยดู
> - [0014](adr/0014-feature-flags-export-and-emergency-call.md) feature flag และปุ่มโทรฉุกเฉิน
>
> milestone เดิมใน [PROJECT.md](../PROJECT.md) (M1–M4) เป็นงานช่วงมินิโปรเจกต์ที่เสร็จแล้ว

แต่ละ milestone ทำบน branch ของตัวเองที่แตกจาก `origin/main` และ merge ผ่าน PR

## ขอบเขตการนำร่อง

- ผู้ใช้หลักคือ อสม. และพยาบาล ผู้ป่วยดูผลผ่าน **PatientViewMode** บนเครื่องเจ้าหน้าที่ และรับ PDF กลับบ้าน ไม่มีหน้า login ของผู้ป่วย
- ไม่มี server: คอม Windows ของ รพ.สต. เป็น **Hub** มือถือ อสม. เป็น **Spoke** แลกข้อมูลกันด้วยไฟล์ `.ncd` ที่เข้ารหัส และใช้ QR สำหรับงานเล็ก
- ภาษาไทยอย่างเดียว ฟีเจอร์ที่ยังไม่เสร็จซ่อนไว้หลัง feature flag
- เริ่มด้วยข้อมูลสมมติ 2–4 สัปดาห์ แล้วขออนุญาตใช้ข้อมูลจริงผ่านอาจารย์ที่ปรึกษา

## สิ่งที่มีบน main แล้ว (ไม่ต้องทำซ้ำ)

- hash รหัสผ่านด้วย PBKDF2 · PIN 6 หลักและลายนิ้วมือ · ล็อกเมื่อไม่ได้ใช้งาน · ปิด `allowBackup`
- validator ตรวจช่วงค่าสัญญาณชีพ · ช่องน้ำตาลไม่บังคับกรอก · check digit ของเลขบัตร · บันทึกฉบับร่างอัตโนมัติ
- outbox `sync_queue` ใน Drift และจุดเสียบ `SyncTransport` · ใช้ภาษาไทยอย่างเดียว · ลบหน้า OCR ปลอมแล้ว
- CI (analyze + test) · test 373 ผ่าน 0 ไม่ผ่าน · Gradle/AGP ใหม่ · benchmark harness (`tool/device_bench.dart`)

## Milestones

| # | ชื่อ | ขอบเขต | ต้องเสร็จก่อน | สถานะ |
|---|---|---|---|---|
| M0 | จัดระเบียบ repo | release signing ด้วย `key.properties` · เปลี่ยน App ID เป็น `io.github.theeraphats.ncdscreening` · build script ใช้ Flutter ตาม `.fvmrc` และเลิกสลับ `.env` · แก้ชื่อใน script ของ Windows · เลิก track `.claude/settings.local.json` · ignore `.env.*` · README ใส่ `--flavor` | — | ⏳ |
| M1 | ความปลอดภัยก่อนนำร่อง | seed demo เฉพาะ flavor dev/local · `FeatureFlags` (ซ่อน export และเอา LINE ออก) · ปุ่มโทรฉุกเฉินโทรได้จริงผ่าน `tel:` · บังคับตั้ง PIN · ล็อกเมื่อไม่ได้ใช้ 5 นาทีและซ่อนหน้าจอเมื่อสลับแอป · นับครั้งที่ใส่ผิดรวมกัน (Spoke ผิด 10 ครั้งลบข้อมูล · Hub ไม่ลบแต่ล็อกไว้) · SQLCipher + keystore · ปรับจำนวนรอบ PBKDF2 ตามผล benchmark · `FLAG_SECURE` + `dataExtractionRules` · เลขบัตรเป็น UNIQUE และตรวจซ้ำ · ลายนิ้วมือบน Windows · ตรวจ validator ซ้ำใน BLoC/repository | M0 | ⏳ |
| M2 | เกณฑ์ทางการแพทย์ | Thai CV Risk Score (เพิ่มคำถามสูบบุหรี่) · อ้วนลงพุงใช้รอบเอว > ส่วนสูง/2 · ถามว่าอดอาหารหรือไม่ และถ้าไม่ได้ตรวจให้แสดง "ไม่ได้ตรวจ" · ผู้ที่ป่วยแล้วแสดง "ติดตามการรักษา" · กฎ triage (น้ำตาลต่ำ ความดันต่ำ ชีพจร) · บันทึกเวอร์ชันเกณฑ์ · เก็บประวัติเมื่อพยาบาลปรับผล · golden test | M1 | ⏳ |
| 🗣️ | ประชุม รพ.สต. | ใช้ [รายการคำถาม](pilot-meeting-questions.md) และ APK ข้อมูลสมมติ · ยืนยันเครื่อง hub, JHCIS/HOSxP, ผู้ควบคุมข้อมูล, เกณฑ์ทางการแพทย์, เบอร์ รพ.สต., รูปแบบไฟล์ export | M2 (นัดได้ระหว่างทำ M0–M2 · ผลด้านเกณฑ์นำไปปรับก่อน M6) | ⏳ |
| M3 | PatientViewMode | ตัด login ผู้ป่วย · ปุ่ม "แสดงให้ผู้ป่วยดู" · ต้องใส่ PIN เจ้าหน้าที่ก่อนออก · แก้ PRODUCT/CONTEXT/README | M1, ผลประชุม | ⏳ |
| M4 | Sync แบบไฟล์ | schema v6 (`updatedAt`, origin, tombstone, devices, assignment, import log) · ย้าย outbox เข้า transaction และส่ง record ครบ · `FileTransport` + SyncPackage `.ncd` · ตั้งค่าเครื่องผ่าน QR · DeviceKey ที่เพิกถอนได้ · VhvAssignment · รวมข้อมูลแบบ idempotent | M3 | ⏳ |
| M5 | Hub บน Windows | ย้ายที่เก็บ DB ไป app-support · dashboard สำหรับจอใหญ่ · สำรองข้อมูลแบบเข้ารหัสทุกวันและกู้คืน · ทะเบียนเครื่อง · CI build Windows และ Android release · export ตามรูปแบบที่ได้จากการประชุม | M4 | ⏳ |
| M6 | นำร่อง | วัด benchmark บนมือถือ อสม. จริงให้ผ่านเกณฑ์ใน README · ใช้ข้อมูลสมมติ 2–4 สัปดาห์ · เก็บ feedback และเวลาต่อราย · เดินเรื่องขอใช้ข้อมูลจริง พร้อม privacy notice และ consent | M5 | ⏳ |

## ความเสี่ยงที่รู้อยู่

- SQLCipher กับ Drift บน Windows ต้องลองให้ได้ตั้งแต่ต้น M1 ถ้าไม่ได้ hub ต้องเข้ารหัสในระดับ application แทน
- ถ้า รพ.สต. ไม่มีคอมให้ใช้เป็น hub ให้ใช้แท็บเล็ต Android แทน และย้ายงานบางส่วนของ M5 ไปทำบน Android
- เพิ่มรอบ PBKDF2 แล้วอาจช้าบนมือถือสเปกต่ำ ต้องเลือกจำนวนรอบจากผล benchmark บนเครื่องจริง
- ค่าสัมประสิทธิ์ของ Thai CV Risk Score ต้องใช้ตามเอกสารต้นทาง และให้พยาบาลตรวจก่อนใช้จริง
- Gradle/AGP ของโปรเจกต์อยู่ตรงขั้นต่ำที่ Flutter 3.47.9 ยอมรับพอดี ถ้าอัปเกรด Flutter ต้องอัปเกรด Gradle ด้วย
