import 'package:get_it/get_it.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/data/repositories/drift_ncd_repository.dart';
import 'package:ncd_screening_mobile/data/repositories/drift_sync_queue_service.dart';
import 'package:ncd_screening_mobile/data/repositories/screening_draft_store.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/domain/services/device_security_services.dart';
import 'package:ncd_screening_mobile/domain/services/pdf_report_service.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';
import 'package:ncd_screening_mobile/shared/bloc/app_lock/app_lock_cubit.dart';
import 'package:ncd_screening_mobile/domain/services/sync_queue_service.dart';
import 'package:ncd_screening_mobile/domain/services/sync_transport.dart';
import 'package:ncd_screening_mobile/feature/auth/bloc/auth_bloc.dart';
import 'package:ncd_screening_mobile/feature/nurse/bloc/village_analytics_bloc.dart';
import 'package:ncd_screening_mobile/feature/nurse/bloc/village_bloc.dart';
import 'package:ncd_screening_mobile/feature/patient/bloc/patient_bloc.dart';
import 'package:ncd_screening_mobile/feature/screening/bloc/screening_bloc.dart';
import 'package:ncd_screening_mobile/feature/vhv/bloc/vhv_bloc.dart';
import 'package:ncd_screening_mobile/shared/bloc/accessibility/accessibility_cubit.dart';
import 'package:ncd_screening_mobile/shared/bloc/sync_badge_bloc.dart';

final locator = GetIt.instance;

Future<void> initLocator() async {
  // Register AppDatabase
  locator.registerLazySingleton<AppDatabase>(AppDatabase.new);

  // Register NCD Repository (Offline-first Drift SQLite database persistence)
  locator.registerLazySingleton<NcdRepositoryInterface>(
      () => DriftNcdRepository(locator<AppDatabase>()));

  // Auto-saved screening form drafts
  locator.registerLazySingleton<ScreeningDraftStore>(
      () => ScreeningDraftStore(locator<AppDatabase>()));

  // Register PDF Report Service
  locator.registerLazySingleton<PdfReportServiceInterface>(PdfReportService.new);

  // Device security: secrets in Keychain/Keystore, PIN, biometrics, idle lock
  locator.registerLazySingleton<SecureStore>(() => const PlatformSecureStore());
  locator.registerLazySingleton<PinService>(
      () => PinService(locator<SecureStore>()));
  locator.registerLazySingleton<DeviceSessionStore>(
      () => DeviceSessionStore(locator<SecureStore>()));
  locator.registerLazySingleton<BiometricService>(LocalAuthBiometricService.new);
  locator.registerLazySingleton<AppLockCubit>(AppLockCubit.new);

  // Register Sync Queue Service
  locator.registerLazySingleton<SyncTransport>(() => const NoServerTransport());
  locator.registerLazySingleton<SyncQueueServiceInterface>(
      () => DriftSyncQueueService(locator<AppDatabase>(), locator<SyncTransport>()));

  // Register NCD BLoCs
  locator.registerLazySingleton<AuthBloc>(
      () => AuthBloc(locator<NcdRepositoryInterface>()));
  locator.registerLazySingleton<PatientBloc>(
      () => PatientBloc(locator<NcdRepositoryInterface>()));
  locator.registerLazySingleton<ScreeningBloc>(
      () => ScreeningBloc(locator<NcdRepositoryInterface>()));
  locator.registerLazySingleton<VhvBloc>(
      () => VhvBloc(locator<NcdRepositoryInterface>()));
  locator.registerLazySingleton<VillageBloc>(
      () => VillageBloc(locator<NcdRepositoryInterface>()));
  locator.registerLazySingleton<VillageAnalyticsBloc>(
      () => VillageAnalyticsBloc(locator<NcdRepositoryInterface>()));
  locator.registerLazySingleton<SyncBadgeBloc>(
      () => SyncBadgeBloc(syncService: locator<SyncQueueServiceInterface>()));
  locator.registerLazySingleton<AccessibilityCubit>(AccessibilityCubit.new);
}
