# Project: NCD Screening Mobile App Upgrade (รพ.สต.แม่อาย)

## Architecture
- **Framework**: Flutter 3.x (Material 3), Dart.
- **State Management**: BLoC (`flutter_bloc: ^9.1.1`, `equatable: ^2.0.7`).
- **Dependency Injection**: Service Locator (`get_it: ^8.0.3`).
- **Persistence Layer**: Offline-first Drift SQLite Database (`drift: ^2.23.1`, `drift_flutter: ^0.2.5`) with auto-migration and automatic demo seed data on first launch.
- **Reporting Layer**: PDF Generation (`pdf: ^3.11.1`, `printing: ^5.13.2`) with TrueType Thai typography (Sarabun font), preview, print, and OS-native share sheets.
- **Analytics Layer**: Pure Dart `VillageAnalyticsCalculator` computing 4 NCD risk distributions, demographic metrics, village comparisons, and high-risk priority queues, consumed by `VillageAnalyticsBloc` and rendered in responsive custom widgets in the Nurse module.
- **Test Harness**: Unit, Repository, BLoC, and Widget tests executing via `flutter test`.

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| F1 | Drift Relational Tables | Define Drift tables for Villages, Nurses, VHVs, Patients, Screenings, Histories, Results | M1 | ORIGINAL_REQUEST §R1 |
| F2 | Drift Database Setup & Migration | `AppDatabase` schema v3, onCreate, beforeOpen auto-seed demo data on empty DB | M1 | ORIGINAL_REQUEST §R1 |
| F3 | Drift Repository Implementation | `DriftNcdRepository implements NcdRepositoryInterface` with full CRUD, search, query, review update | M1 | ORIGINAL_REQUEST §R1 |
| F4 | DI Locator Wiring for Drift | Wire `AppDatabase` and `DriftNcdRepository` in `lib/locator.dart` replacing in-memory repository | M1 | ORIGINAL_REQUEST §R1 |
| F5 | PDF Dependencies & Thai Font | Add `pdf` and `printing` packages to `pubspec.yaml`, configure TrueType Sarabun font loader | M2 | ORIGINAL_REQUEST §R2 |
| F6 | PDF Screening Report Generator | `PdfReportService` generating Thai summary PDF with vitals, 4 NCD risks, nurse status, disclaimer | M2 | ORIGINAL_REQUEST §R2 |
| F7 | PDF Preview & Export UI Actions | `PdfPreviewPage` + export/print buttons in `PatientScreeningDetailPage` and `RiskAssessmentResultPage` | M2 | ORIGINAL_REQUEST §R2 |
| F8 | Village Analytics Domain Calculator | Pure calculation engine for 4 NCD risk breakdowns, demographics (gender, age), coverage, high-risk queue | M3 | ORIGINAL_REQUEST §R3 |
| F9 | Repository Analytics Query | `getAllScreenings({String? villageId})` on repository interface & implementations | M3 | ORIGINAL_REQUEST §R3 |
| F10 | Village Analytics BLoC | `VillageAnalyticsBloc` managing load, village filter, and sort order states | M3 | ORIGINAL_REQUEST §R3 |
| F11 | Nurse Village Analytics Dashboard UI | Tabbed `NurseVillageListPage` with KPI cards, 4 NCD meters, demographics, village comparison, high-risk queue | M3 | ORIGINAL_REQUEST §R3 |
| F12 | Comprehensive Automated Test Suite | Unit tests for Drift, PDF service, Analytics calculator, BLoCs, and widgets maintaining 100% pass | M4 | ORIGINAL_REQUEST §R4 |

## Milestones

> These milestones were the mini-project phase and are complete. The pilot roadmap is in [docs/ROADMAP.md](docs/ROADMAP.md).

| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M1 | Drift SQLite Persistence Layer | F1, F2, F3, F4, F9 (part) | none | DONE |
| M2 | PDF Health Screening Summary Export | F5, F6, F7 | none | DONE |
| M3 | Nurse Village Health Analytics Dashboard | F8, F9, F10, F11 | M1 | DONE |
| M4 | Final Integration, Test Suite & Hardening | F12 | M1, M2, M3 | DONE |

## Interface Contracts

### 1. `NcdRepositoryInterface` (`lib/domain/repositories/ncd_repository.dart`)
```dart
abstract class NcdRepositoryInterface {
  Future<UserRole?> login({required UserRole role, required String identifier, String? password});
  Future<List<Village>> getVillages();
  Future<Village?> getVillageById(String villageId);
  Future<List<Patient>> getPatients({String? villageId, String? searchQuery});
  Future<Patient?> getPatientById(String patientId);
  Future<Patient?> getPatientByCitizenId(String citizenId);
  Future<bool> addPatient(Patient patient);
  Future<bool> updatePatient(Patient patient);
  Future<bool> deletePatient(String patientId);
  Future<List<VHV>> getVhvs({String? villageId});
  Future<VHV?> getVhvById(String vhvId);
  Future<bool> addVhv(VHV vhv);
  Future<bool> updateVhv(VHV vhv);
  Future<Nurse?> getNurseById(String nurseId);
  Future<List<Screening>> getScreeningsByPatient(String patientId);
  Future<List<Screening>> getAllScreenings({String? villageId});
  Future<Screening?> getScreeningById(String screeningId);
  Future<bool> saveScreening(Screening screening);
  Future<bool> updateScreeningReview({
    required String screeningId,
    required ReviewStatus status,
    required String nurseId,
    List<ScreeningResult>? updatedResults,
  });
}
```

### 2. `PdfReportService` (`lib/domain/services/pdf_report_service.dart`)
```dart
abstract class PdfReportServiceInterface {
  Future<Uint8List> generateScreeningReport({
    required Patient patient,
    required Screening screening,
    VHV? vhv,
    Nurse? nurse,
    Village? village,
  });
}
```

### 3. `VillageAnalyticsCalculator` (`lib/domain/services/village_analytics_calculator.dart`)
```dart
class VillageAnalyticsCalculator {
  static VillageAnalytics compute({
    required List<Village> villages,
    required List<Patient> patients,
    required List<Screening> screenings,
    String? selectedVillageId,
  });
}
```

## Code Layout
- `lib/data/datasources/drift/`: Drift SQLite database definition (`app_database.dart`, `app_database.g.dart`) & schema tables (`ncd_tables.dart`)
- `lib/data/repositories/`: Data repository implementations (`drift_ncd_repository.dart`)
- `lib/domain/models/`: Pure domain entities (`ncd_models.dart`, `village_analytics.dart`, `sync_queue_item.dart`)
- `lib/domain/repositories/`: Repository interfaces (`ncd_repository.dart`)
- `lib/domain/services/`: Calculation, triage & reporting services (`ncd_risk_calculator.dart`, `pdf_report_service.dart`, `village_analytics_calculator.dart`)
- `lib/feature/nurse/`: Nurse feature pages, widgets, and BLoCs (`nurse_village_list_page.dart`, `widgets/`, `bloc/village_analytics_bloc.dart`)
- `lib/feature/screening/`: Screening pages (`risk_assessment_result_page.dart`, `pdf_preview_page.dart`, `screening_form_page.dart`)
- `lib/feature/patient/`: Patient pages (`patient_screening_detail_page.dart`, `patient_detail_page.dart`)
- `lib/locator.dart`: GetIt dependency injection registry
- `test/unit/`: Domain, data, repository, service, and BLoC unit tests
- `test/widget/`: Widget and UI integration tests
