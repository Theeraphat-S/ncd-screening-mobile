# NCD Screening Mobile Application (รพ.สต.แม่อาย)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![BLoC](https://img.shields.io/badge/State_Management-BLoC_v9-8A2BE2)](https://bloclibrary.dev)
[![Drift](https://img.shields.io/badge/Database-Drift_SQLite_Offline--First-008080)](https://drift.simonbinder.eu/)
[![Tests](https://img.shields.io/badge/Tests-224_Passing-success)](#-เริ่มต้นใช้งาน-getting-started)

> **EN**: Offline-first Flutter mobile application for 4 Non-Communicable Diseases (NCDs) risk screening, nurse triage, village health analytics, and Thai clinical PDF reporting for Mae Ai Sub-district Health Promotion Hospital.  
> **TH**: โมบายแอปพลิเคชันสำหรับการคัดกรองความเสี่ยงของผู้ป่วย 4 โรคไม่ติดต่อเรื้อรัง (NCDs) แบบ Offline-First พร้อมแดชบอร์ดวิเคราะห์สถิติสุขภาพชุมชน และระบบออกรายงานสรุปผล PDF ภาษาไทย  
> **ผู้พัฒนา**: นาย ธีรภัทร ศรีมณฑา (6504106360) | **อาจารย์ที่ปรึกษา**: อ.ดร.จักรกฤช เตโช  
> มินิโปรเจกต์ สาขาวิชาเทคโนโลยีสารสนเทศ คณะวิทยาศาสตร์ มหาวิทยาลัยแม่โจ้

---

## 📌 บทนำและภาพรวมโครงงาน (Overview)

แอปพลิเคชันคัดกรองความเสี่ยง 4 โรคไม่ติดต่อเรื้อรัง (NCDs) พัฒนาขึ้นเพื่อเป็นเครื่องมือสนับสนุนการทำงานเชิงรุกของ **รพ.สต.แม่อาย จ.เชียงใหม่** ช่วยให้อาสาสมัครสาธารณสุขประจำหมู่บ้าน (อสม.) และพยาบาลวิชาชีพสามารถเก็บข้อมูลสุขภาพ ตรวจคัดกรองสัญญาณชีพ ประเมินความเสี่ยง 4 โรคสำคัญได้แบบ Real-time แม้อยู่ในพื้นที่ไม่มีสัญญาณอินเทอร์เน็ต (Offline-First ด้วย Drift SQLite) พร้อมทั้งให้ประชาชนสามารถเข้าดูประวัติ ส่งออกรายงานผลการประเมินสุขภาพเป็น PDF (ภาษาไทยมาตรฐาน) และช่วยให้พยาบาลมีแดชบอร์ดวิเคราะห์สถิติสุขภาพชุมชนรายหมู่บ้าน (Village Analytics Dashboard)

### 4 กลุ่มโรคไม่ติดต่อเรื้อรังที่คัดกรอง:
1. 🩺 **โรคเบาหวาน (Diabetes Mellitus)** — ประเมินจากระดับน้ำตาลในเลือด (FBS) และประวัติสุขภาพ
2. 🫀 **โรคความดันโลหิตสูง (Hypertension)** — ประเมินจากความดันตัวบน (SBP) และตัวล่าง (DBP)
3. 🏃‍♂️ **โรคอ้วนลงพุง (Metabolic Syndrome / Obesity)** — ประเมินจากดัชนีมวลกาย (BMI) และรอบเอวแยกตามเพศ
4. ❤️ **โรคหลอดเลือดหัวใจ (Cardiovascular Disease - CVD)** — ประเมินจากคะแนนความเสี่ยงสะสมร่วมและประวัติครอบครัว

---

## 👥 ผู้ใช้งานระบบ (Actors) & ฟังก์ชันการทำงาน

ระบบออกแบบครอบคลุม **3 กลุ่มผู้ใช้งาน (Roles)**:

### 1. 👤 ผู้ป่วย / ประชาชนทั่วไป (Patient)
- **Login Patient**: เข้าสู่ระบบด้วยเลขบัตรประจำตัวประชาชน 13 หลัก
- **List Physical & Screening History**: ดูรายการประวัติการตรวจคัดกรองสุขภาพย้อนหลัง
- **View Physical & Screening Details**: ดูรายละเอียดผลการตรวจ สัญญาณชีพ และผลประเมินความเสี่ยง 4 โรค พร้อมสถานะการรับรองจากพยาบาล
- **Export PDF Health Report**: ส่งออก/พิมพ์เอกสารสรุปผลการคัดกรองสุขภาพ (Thai Clinical Summary PDF) พร้อมแชร์ผ่านระบบปฏิบัติการ

### 2. 🤝 อาสาสมัครสาธารณสุขประจำหมู่บ้าน (VHV / อสม.)
- **Login VHV**: เข้าสู่ระบบด้วยเลขบัตรประชาชน / เบอร์โทรศัพท์ และรหัสผ่าน
- **List Patient**: ดูรายชื่อผู้ป่วยทั้งหมดในหมู่บ้านที่รับผิดชอบ
- **Search Patient**: ค้นหาผู้ป่วยด้วยเลขบัตรประชาชน 13 หลัก หรือชื่อ-นามสกุล
- **Add Patient**: เพิ่มข้อมูลผู้ป่วยใหม่ พร้อมแนบรูปถ่ายและคำนวณอายุอัตโนมัติ
- **Edit Patient**: แก้ไขข้อมูลประจำตัวผู้ป่วย
- **Delete Patient**: ลบข้อมูลผู้ป่วย พร้อมระบบยืนยันความปลอดภัยก่อนลบ
- **View Patient Detail**: ดูประวัติและข้อมูลส่วนบุคคลของผู้ป่วย
- **Add Disease Screening Form**: กรอกแบบฟอร์มคัดกรอง 2 ตอน (สัญญาณชีพ + ประวัติการแพ้/ครอบครัว)
- **View Risk Assessment**: ดูผลวิเคราะห์ความเสี่ยง 4 โรคทันทีหลังบันทึกข้อมูลแบบ Offline

### 3. 👩‍⚕️ พยาบาลวิชาชีพ (Nurse)
- **Login Nurse**: เข้าสู่ระบบด้วยรหัสพยาบาล (Nurse ID) และรหัสผ่าน
- **Village Health Analytics Dashboard**: แดชบอร์ดวิเคราะห์สถิติความเสี่ยงสุขภาพชุมชน แสดงอัตราความครอบคลุม (Coverage %), สัดส่วนกลุ่มเสี่ยง 4 โรคแยกรายหมู่บ้าน, และคิวผู้ป่วยกลุ่มเสี่ยงสูงที่ต้องติดตามเชิงรุก (Triage Queue)
- **List Village**: ดูรายการหมู่บ้านทั้งหมดในความรับผิดชอบ (หมู่ 1 - หมู่ 5 รพ.สต.แม่อาย)
- **List VHV by Village**: ดูรายชื่อ อสม. แยกรายหมู่บ้าน
- **Add VHV / Edit VHV / View VHV Detail**: เพิ่ม แก้ไข และดูข้อมูล อสม. พร้อมมอบหมายพื้นที่
- **List Patient by Village**: ดูรายชื่อผู้ป่วยและประวัติคัดกรองแยกตามหมู่บ้าน
- **View Risk Assessment**: ตรวจสอบรายละเอียดผลการคัดกรองสุขภาพ
- **Approve Risk Assessment**: รับรองผลการประเมิน หรือปรับแก้ไขระดับความเสี่ยง 4 โรคพร้อมยืนยันความถูกต้อง

---

## 🏗️ สถาปัตยกรรมระบบ (System Architecture)

- **Framework**: [Flutter](https://flutter.dev) (Dart SDK ^3.10)
- **Architecture Pattern**: Clean Architecture / Feature-Driven Design
- **State Management**: BLoC Pattern (`flutter_bloc`)
- **Dependency Injection**: Service Locator (`get_it`)
- **Local Database (Persistence)**: [Drift](https://drift.simonbinder.eu/) SQLite Database (`AppDatabase`) รองรับการทำงานแบบ Offline-First 100% พร้อม Auto-Seed ข้อมูลตัวอย่างเริ่มต้น
- **Design System**: [DESIGN.md](DESIGN.md) — ระบบดีไซน์ **Nordic Clinical Precision** (Medical Teal `#0D9488`, Slate Neutrals, Ambient Diffusion Shadows และ WCAG AA Calibrated Risk Badges)
- **PDF Engine**: `PdfReportService` สร้างรายงานสรุปผลสุขภาพภาษาไทย 7 ส่วน ด้วยฟอนต์มาตรฐาน Sarabun และปี พ.ศ.
- **Analytics Engine**: Pure Dart Domain Service (`VillageAnalyticsCalculator`) คำนวณสถิติและจัดคิวกลุ่มเสี่ยงชุมชน
- **Calculation Engine**: Pure Dart Domain Service (`NcdRiskCalculator`) คำนวณความเสี่ยง Real-time ตามเกณฑ์มาตรฐานกระทรวงสาธารณสุข

---

## 🚀 เริ่มต้นใช้งาน (Getting Started)

### ความต้องการของระบบ:
- Flutter SDK 3.10.8 หรือสูงกว่า
- Android Studio / VS Code / Xcode (สำหรับ iOS)

### 1. ติดตั้ง Dependencies
```bash
flutter pub get
```

### 2. รันแอปพลิเคชัน
```bash
flutter run
```

### 3. รันการทดสอบ (Automated Test Suite)
```bash
flutter test
```
*(ผ่านการทดสอบ 224 Test Cases ครอบคลุม Unit Tests, BLoC Tests, Drift Repository Persistence, Thai PDF Services และ Widget Tests)*

---

## 🎨 ระบบดีไซน์ (Design System)

แอปพลิเคชันได้รับการออกแบบตามข้อกำหนดใน [DESIGN.md](DESIGN.md):
- **ธีมสีหลัก**: Medical Teal 600 (`#0D9488`), Teal Dark 800 (`#115E59`), Teal Light (`#CCFBF1`)
- **พื้นผิวและตัวอักษร**: Slate 50 Background (`#F8FAFC`), Slate 900 Typography (`#0F172A`), Slate 200 Borders (`#E2E8F0`)
- **ระดับความเสี่ยงตามมาตรฐานสาธารณสุข**:
  - เสี่ยงต่ำ (Low): Emerald-600 (`#059669`) / Emerald-50 Bg (`#ECFDF5`)
  - เสี่ยงปานกลาง (Moderate): Amber-600 (`#D97706`) / Amber-50 Bg (`#FFFBEB`)
  - เสี่ยงสูง (High): Red-600 (`#DC2626`) / Red-50 Bg (`#FEF2F2`)

---

### 4. ลงนามแอปรุ่น Release (ไม่บังคับสำหรับการทดสอบ)
สร้างไฟล์ `android/key.properties` (ไม่ถูก commit) ที่มีคีย์ `storeFile`, `storePassword`, `keyAlias`, `keyPassword`
หากไม่มีไฟล์นี้ build release จะใช้คีย์ debug ซึ่ง **ห้ามนำไปแจกจ่าย**

> **หมายเหตุความปลอดภัย:** เลขบัตรประชาชนถูกเข้ารหัสด้วยคีย์ที่เก็บใน keystore ของเครื่อง หากคีย์หาย ข้อมูลจะกู้คืนไม่ได้ ก่อนใช้งานจริงต้องมีขั้นตอนการกู้คืนที่บันทึกไว้ (ดู ADR 0011)

---

## 🔑 ข้อมูลสำหรับทดสอบเข้าใช้งาน (Demo Credentials)

| Role | Identifier / User ID | Password |
|---|---|---|
| **ผู้ป่วย (Patient)** | `1234567890123` | *(ไม่ต้องใช้)* |
| **อสม. (VHV)** | `1111111111111` | `password123` |
| **พยาบาล (Nurse)** | `NUR001` | `password123` |

---

## 📁 โครงสร้างโปรเจกต์ (Project Directory Structure)

```
lib/
├── data/                # Data Layer
│   ├── datasources/drift/  # Drift SQLite Database (AppDatabase, tables)
│   └── repositories/    # Drift implementation (DriftNcdRepository)
├── domain/              # Domain Layer (no Flutter/IO infrastructure)
│   ├── models/          # NCD Models & Analytics Entities
│   ├── repositories/    # Repository Interfaces
│   └── services/        # Calculation, Analytics, Sync Queue & PDF Engines
├── feature/             # Feature Modules
│   ├── auth/            # Role Selection & Login Pages + AuthBloc
│   ├── patient/         # Patient Management, History & PatientBloc
│   ├── screening/       # Screening Form (Part 1 & 2), Risk Views, PDF Preview & ScreeningBloc
│   ├── vhv/             # VHV Management & VhvBloc
│   └── nurse/           # Village Overview, Analytics Dashboard, VHV Admin & Nurse Approval Flow
├── i18n/                # TH/EN localizations
├── shared/              # Reusable UI tokens, styles, components (PColor, PShadow, PRadius)
├── locator.dart         # get_it service locator
└── main.dart            # MultiBlocProvider, Global Theme & Application Root
```

---

## 📄 เอกสารอ้างอิงและบันทึกการตัดสินใจ (ADRs & Context)
- [CONTEXT.md](CONTEXT.md): พจนานุกรมคำศัพท์และนิยามเชิงโดเมน (Domain Glossary)
- [DESIGN.md](DESIGN.md): ข้อกำหนดระบบดีไซน์และโทเค็น (Design System Specifications)
- [ADR 0001: Offline-First Repository Architecture](docs/adr/0001-offline-mock-repository-architecture.md)
- [ADR 0002: Client-Side NCD Risk Engine](docs/adr/0002-client-side-ncd-risk-calculator.md)
- [ADR 0003: Drift SQLite Offline-First Persistence](docs/adr/0003-drift-sqlite-offline-persistence.md)
- [ADR 0004: Thai PDF Clinical Report Generation](docs/adr/0004-thai-pdf-clinical-report-generation.md)
- [ADR 0005: Nurse Village Health Analytics Engine](docs/adr/0005-village-health-analytics-engine.md)
- [ADR 0006: Nordic Clinical Precision UI System Redesign](docs/adr/0006-nordic-clinical-ui-redesign.md)
- [ADR 0010: Credential Hashing, Durable Sync Outbox & Bundled Thai Fonts](docs/adr/0010-credential-hashing-durable-sync-and-bundled-fonts.md)
- [ADR 0011: Citizen ID Column Encryption & Backup Exclusion](docs/adr/0011-citizen-id-column-encryption.md)

