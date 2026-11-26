import 'package:drift/drift.dart' show QueryExecutor;
import 'package:get_it/get_it.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/database_location.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/encrypted_database.dart';
import 'package:ncd_screening_mobile/data/repositories/drift_ncd_repository.dart';
import 'package:ncd_screening_mobile/data/repositories/drift_sync_queue_service.dart';
import 'package:ncd_screening_mobile/data/repositories/screening_draft_store.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/data/services/device_security_services.dart';
import 'package:ncd_screening_mobile/data/services/local_data_wiper.dart';
import 'package:ncd_screening_mobile/domain/services/auth_attempt_guard.dart';
import 'package:ncd_screening_mobile/shared/config/app_config.dart';
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

/// [database] and [secureStore] replace the encrypted on-device database
/// and the platform secure storage (tests).
Future<void> initLocator({QueryExecutor? database, SecureStore? secureStore}) async {
  // Device security: secrets in Keychain/Keystore/DPAPI
  locator.registerLazySingleton<SecureStore>(
      () => secureStore ?? const PlatformSecureStore());

  // The database is encrypted with SQLCipher; its key lives in secure
  // storage. An existing plaintext database is encrypted here, once.
  if (database != null) {
    locator.registerLazySingleton<AppDatabase>(() => AppDatabase(database));
  } else {
    final dbFile = await appDatabaseFile();
    final dbKey = await prepareEncryptedDatabase(dbFile, locator<SecureStore>());
    locator.registerLazySingleton<AppDatabase>(
        () => AppDatabase(openEncryptedDatabase(dbFile, dbKey)));
  }

  // Register NCD Repository (Offline-first Drift SQLite database persistence)
  locator.registerLazySingleton<NcdRepositoryInterface>(
      () => DriftNcdRepository(locator<AppDatabase>()));

  // Auto-saved screening form drafts
  locator.registerLazySingleton<ScreeningDraftStore>(
      () => ScreeningDraftStore(locator<AppDatabase>()));

  // Register PDF Report Service
  locator.registerLazySingleton<PdfReportServiceInterface>(PdfReportService.new);

  // PIN, biometrics, idle lock
  locator.registerLazySingleton<PinService>(
      () => PinService(locator<SecureStore>()));
  locator.registerLazySingleton<DeviceSessionStore>(
      () => DeviceSessionStore(locator<SecureStore>()));
  locator.registerLazySingleton<BiometricService>(LocalAuthBiometricService.new);
  locator.registerLazySingleton<AppLockCubit>(AppLockCubit.new);
  // One failure counter for PIN and password; 10 failures wipe a Spoke and
  // lock the Hub (ADR 0011).
  locator.registerLazySingleton<AuthAttemptGuard>(() => AuthAttemptGuard(
        store: locator<SecureStore>(),
        role: DeviceRoleConfig.current,
        wiper: LocalDataWiper(
          store: locator<SecureStore>(),
          closeDatabase: () => locator<AppDatabase>().close(),
          databaseFile: appDatabaseFile,
        ),
      ));

  // Register Sync Queue Service
  locator.registerLazySingleton<SyncTransport>(() => const NoServerTransport());
  locator.registerLazySingleton<SyncQueueServiceInterface>(
      () => DriftSyncQueueService(locator<AppDatabase>(), locator<SyncTransport>()));

  // Register NCD BLoCs
  locator.registerLazySingleton<AuthBloc>(() => AuthBloc(
        locator<NcdRepositoryInterface>(),
        attemptGuard: locator<AuthAttemptGuard>(),
      ));
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
