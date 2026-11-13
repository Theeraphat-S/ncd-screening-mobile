import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';
import 'package:ncd_screening_mobile/domain/repositories/ncd_repository.dart';
import 'package:ncd_screening_mobile/data/services/device_security_services.dart';
import 'package:ncd_screening_mobile/data/repositories/screening_draft_store.dart';
import 'package:ncd_screening_mobile/feature/auth/bloc/auth_bloc.dart';
import 'package:ncd_screening_mobile/feature/auth/pages/user_type_selection_page.dart';
import 'package:ncd_screening_mobile/feature/nurse/bloc/village_analytics_bloc.dart';
import 'package:ncd_screening_mobile/feature/nurse/bloc/village_bloc.dart';
import 'package:ncd_screening_mobile/feature/patient/bloc/patient_bloc.dart';
import 'package:ncd_screening_mobile/feature/screening/bloc/screening_bloc.dart';
import 'package:ncd_screening_mobile/feature/vhv/bloc/vhv_bloc.dart';
import 'package:ncd_screening_mobile/locator.dart';
import 'package:ncd_screening_mobile/shared/bloc/accessibility/accessibility_cubit.dart';
import 'package:ncd_screening_mobile/shared/bloc/app_lock/app_lock_cubit.dart';
import 'package:ncd_screening_mobile/shared/bloc/sync_badge_bloc.dart';
import 'package:ncd_screening_mobile/shared/navigation.dart';
import 'package:ncd_screening_mobile/shared/widgets/app_lock_gate.dart';
import 'package:ncd_screening_mobile/shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocator();
  // Health data in abandoned drafts must not linger on the device.
  unawaited(locator<ScreeningDraftStore>().purgeExpired());

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<NcdRepositoryInterface>.value(
          value: locator<NcdRepositoryInterface>(),
        ),
        RepositoryProvider<ScreeningDraftStore>.value(
          value: locator<ScreeningDraftStore>(),
        ),
        RepositoryProvider<PinService>.value(value: locator<PinService>()),
        RepositoryProvider<BiometricService>.value(
          value: locator<BiometricService>(),
        ),
        RepositoryProvider<DeviceSessionStore>.value(
          value: locator<DeviceSessionStore>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (context) => locator<AuthBloc>()),
          BlocProvider<PatientBloc>(
            create: (context) => locator<PatientBloc>(),
          ),
          BlocProvider<ScreeningBloc>(
            create: (context) => locator<ScreeningBloc>(),
          ),
          BlocProvider<VhvBloc>(create: (context) => locator<VhvBloc>()),
          BlocProvider<VillageBloc>(
            create: (context) => locator<VillageBloc>(),
          ),
          BlocProvider<VillageAnalyticsBloc>(
            create: (context) => locator<VillageAnalyticsBloc>(),
          ),
          BlocProvider<SyncBadgeBloc>(
            create: (context) =>
                locator<SyncBadgeBloc>()..add(const SyncBadgeStarted()),
          ),
          BlocProvider<AccessibilityCubit>(
            create: (context) => locator<AccessibilityCubit>(),
          ),
          BlocProvider<AppLockCubit>(
            create: (context) => locator<AppLockCubit>(),
          ),
        ],
        child: const NcdScreeningApp(),
      ),
    ),
  );
}

class NcdScreeningApp extends StatelessWidget {
  const NcdScreeningApp({super.key});

  static const _thaiLocale = Locale('th');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccessibilityCubit, AccessibilityState>(
      builder: (context, accessState) {
        return MaterialApp(
          title: 'NCD Screening Mobile',
          debugShowCheckedModeBanner: false,
          navigatorKey: appNavigatorKey,
          supportedLocales: const [_thaiLocale],
          localizationsDelegates: const [
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          locale: _thaiLocale,
          theme: accessState.isHighContrast
              ? AppTheme.highContrastTheme
              : AppTheme.standardTheme,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            final systemScale = mediaQuery.textScaler.scale(1.0);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(
                  systemScale * accessState.textScaleFactor,
                ),
              ),
              child: AppLockGate(child: child ?? const SizedBox.shrink()),
            );
          },
          home: const UserTypeSelectionPage(),
        );
      },
    );
  }
}
