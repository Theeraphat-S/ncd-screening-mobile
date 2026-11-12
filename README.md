# NCD Screening Mobile (รพ.สต.แม่อาย)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![BLoC](https://img.shields.io/badge/State-BLoC_v9-8A2BE2)](https://bloclibrary.dev)
[![Drift](https://img.shields.io/badge/DB-Drift_SQLite-008080)](https://drift.simonbinder.eu/)
[![Tests](https://img.shields.io/badge/Tests-160_Passing-success)](#-เริ่มต้นใช้งาน)

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
| ผู้ป่วย | `1234567890123` | — |
| อสม. | `1111111111111` | `password123` |
| พยาบาล | `NUR001` | `password123` |

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
