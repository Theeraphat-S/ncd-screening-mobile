# NCD Screening Mobile (รพ.สต.แม่อาย)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![BLoC](https://img.shields.io/badge/State-BLoC_v9-8A2BE2)](https://bloclibrary.dev)
[![Drift](https://img.shields.io/badge/DB-Drift_SQLite-008080)](https://drift.simonbinder.eu/)
[![Tests](https://img.shields.io/badge/Tests-355_Passing-success)](#-เริ่มต้นใช้งาน)

แอป Flutter แบบ **Offline-First** สำหรับคัดกรองความเสี่ยง 4 โรคไม่ติดต่อเรื้อรัง (NCDs) ของ รพ.สต.แม่อาย จ.เชียงใหม่ — ใช้งานได้แม้ไม่มีอินเทอร์เน็ต พร้อมแดชบอร์ดสถิติรายหมู่บ้านและรายงาน PDF ภาษาไทย

> **ผู้พัฒนา**: นาย ธีรภัทร ศรีมณฑา (6504106360) · **อาจารย์ที่ปรึกษา**: อ.ดร.จักรกฤช เตโช  
> มินิโปรเจกต์ สาขาวิชาเทคโนโลยีสารสนเทศ คณะวิทยาศาสตร์ มหาวิทยาลัยแม่โจ้

## 🩺 โรคที่คัดกรอง

| โรค | เกณฑ์หลัก |
|---|---|
| เบาหวาน | FBS + ประวัติสุขภาพ |
| ความดันโลหิตสูง | SBP / DBP |
| อ้วนลงพุง | BMI + รอบเอวตามเพศ |
| หลอดเลือดหัวใจ (CVD) | คะแนนความเสี่ยงสะสม + ประวัติครอบครัว |

## 👥 ผู้ใช้งาน

- **ผู้ป่วย** — เข้าสู่ระบบด้วยเลขบัตร 13 หลัก, ดูประวัติ/ผลคัดกรอง, ส่งออก PDF
- **อสม.** — จัดการข้อมูลผู้ป่วย (CRUD + ค้นหา), กรอกแบบคัดกรอง, ดูผลความเสี่ยงทันที
- **พยาบาล** — แดชบอร์ดสถิติรายหมู่บ้าน + คิวกลุ่มเสี่ยงสูง, จัดการ อสม., รับรอง/ปรับผลประเมิน

## 🏗️ Tech Stack

Flutter · Clean Architecture · BLoC · `get_it` · Drift SQLite (auto-seed) · Thai PDF (Sarabun, พ.ศ.)  
Domain services: `NcdRiskCalculator`, `VillageAnalyticsCalculator`, `PdfReportService`  
Design system: **Nordic Clinical Precision** — ดู [DESIGN.md](DESIGN.md)

## 🚀 เริ่มต้นใช้งาน

ต้องการ Flutter SDK 3.10.8+

```bash
flutter pub get
```

```bash
flutter run
```

```bash
flutter test
```

## 🔑 บัญชีทดสอบ

| Role | User ID | Password |
|---|---|---|
| ผู้ป่วย | `1234567890121` | — |
| อสม. | `1111111111111` | `password123` |
| พยาบาล | `NUR001` | `password123` |

## ⚠️ ข้อจำกัดปัจจุบัน (ก่อนใช้กับข้อมูลจริง)

- **ใช้ข้อมูลจำลองเท่านั้น** — ฐานข้อมูล SQLite บนเครื่อง **ยังไม่ได้เข้ารหัส** ห้ามกรอกเลขบัตรหรือข้อมูลสุขภาพของบุคคลจริงจนกว่าจะเข้ารหัสฐานข้อมูล (เช่น SQLCipher) และทบทวน PDPA แล้ว ทั้งนี้แอปปิด Android auto-backup (`allowBackup="false"`) เพื่อไม่ให้ฐานข้อมูลถูกสำรองออกจากเครื่อง
- **ยังไม่มีเซิร์ฟเวอร์และการซิงก์** — ข้อมูลทั้งหมดอยู่ในเครื่องนี้ อสม. และพยาบาลต้องใช้เครื่องเดียวกันแล้วสลับบัญชี (`NoServerTransport` เป็นเพียงตัวแทนจนกว่าจะมี backend)
- **ยังไม่มีการสแกนบัตรประชาชน (OCR)** — นำหน้าสแกนที่ไม่ได้ใช้กล้องจริงออกแล้ว เหลือเพียง `IdCardOcrParser` ไว้ใช้เมื่อทำ OCR จริง
- **บัญชีทดสอบ** ใช้รหัสผ่านร่วมกันและเลขบัตรสมมติ (ผู้ป่วยเดโมมี check digit ถูกต้อง) ใช้ในโหมดพัฒนาเท่านั้น หน้า login ผู้ป่วยและฟอร์มเพิ่มผู้ป่วยตรวจ check digit ของเลขบัตร
- **ยังไม่ได้วัดบนมือถือ Android สเปกต่ำจริง** — ผลวัดในหัวข้อ "ผลวัดประสิทธิภาพ" มาจาก emulator ที่เร็วกว่าเครื่องจริง ต้องวัดซ้ำด้วย `tool/device_bench.dart` ใน profile mode บนเครื่องของ อสม. ก่อนเริ่ม pilot (เกณฑ์: login/PIN ≤ 1 วินาที, analytics ≤ 2 วินาที, PDF ≤ 3 วินาที)

## ⏱️ ผลวัดประสิทธิภาพ

วัดด้วย `tool/device_bench.dart` ใน profile mode บน Android emulator (Android 13, RAM 2 GB, 4 คอร์, ใช้ GPU ของเครื่องพัฒนา) ผู้ป่วย 2,000 คน การคัดกรอง 4,000 รายการ:

| รายการ | เกณฑ์ | ผลวัด |
|---|---|---|
| Login อสม. (เปิดครั้งแรกรวม seed / ครั้งต่อมา) | ≤ 1,000 ms | 309 / 272 ms |
| ปลดล็อกด้วย PIN | ≤ 1,000 ms | 138 ms |
| โหลดข้อมูล + คำนวณ analytics | ≤ 2,000 ms | 181 ms |
| สร้าง PDF | ≤ 3,000 ms | 38 ms |

ผลเทียบ PBKDF2 verify (ค่ากลาง 7 รอบ, baseline UI ค้าง 19 ms): บน UI thread ใช้ 101 ms และ UI ค้าง 137 ms ส่วนบน isolate ใช้ 209 ms และ UI ค้าง 70 ms หมายความว่าย้ายไป isolate ลดอาการค้างลงราวครึ่งหนึ่งแต่แลกกับเวลารวมที่เพิ่มขึ้นราว 2 เท่า (ค่าเริ่ม isolate) งานแฮชบนมือถือสเปกต่ำจริงจะนานกว่านี้หลายเท่า จึงคาดว่าประโยชน์จะชัดกว่านี้ แต่ยังเป็นการคาดการณ์ ผลทั้งหมดมาจาก emulator ที่ใช้ CPU x86 ของเครื่องพัฒนาซึ่งเร็วกว่ามือถือ ARM สเปกต่ำจริง ควรวัดซ้ำบนเครื่องจริงด้วย `flutter run --profile --flavor local -t tool/device_bench.dart -d <device>`

## 📁 โครงสร้าง

```
lib/
├── config/    # Environment config
├── domain/    # Drift DB, models, repositories, services
├── feature/   # auth, patient, screening, vhv, nurse
├── shared/    # UI tokens & components
└── main.dart
```

## 📄 เอกสาร

[CONTEXT.md](CONTEXT.md) (Glossary) · [DESIGN.md](DESIGN.md) (Design System) · ADRs: [0001](docs/adr/0001-offline-mock-repository-architecture.md) · [0002](docs/adr/0002-client-side-ncd-risk-calculator.md) · [0003](docs/adr/0003-drift-sqlite-offline-persistence.md) · [0004](docs/adr/0004-thai-pdf-clinical-report-generation.md) · [0005](docs/adr/0005-village-health-analytics-engine.md) · [0006](docs/adr/0006-nordic-clinical-ui-redesign.md)
