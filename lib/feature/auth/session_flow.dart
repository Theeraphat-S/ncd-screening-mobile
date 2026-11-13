import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/device_security_services.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';
import 'package:ncd_screening_mobile/feature/auth/bloc/auth_bloc.dart';
import 'package:ncd_screening_mobile/feature/auth/pages/pin_setup_page.dart';
import 'package:ncd_screening_mobile/feature/auth/pages/user_type_selection_page.dart';
import 'package:ncd_screening_mobile/feature/nurse/pages/nurse_village_list_page.dart';
import 'package:ncd_screening_mobile/feature/patient/bloc/patient_bloc.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/patient_history_list_page.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/vhv_patient_list_page.dart';
import 'package:ncd_screening_mobile/locator.dart';
import 'package:ncd_screening_mobile/shared/bloc/app_lock/app_lock_cubit.dart';
import 'package:ncd_screening_mobile/shared/navigation.dart';

/// Id used to key a staff member's PIN / biometric settings.
String? staffUserId(dynamic user) {
  if (user is VHV) return user.vhvId;
  if (user is Nurse) return user.nurseId;
  return null;
}

/// Home page for a signed-in user (also primes any BLoC the page relies on).
Widget homeFor(BuildContext context, dynamic user) {
  if (user is VHV) {
    context.read<PatientBloc>().add(PatientLoadRequested(villageId: user.villageId));
    return VhvPatientListPage(vhv: user);
  }
  if (user is Nurse) return NurseVillageListPage(nurse: user);
  return PatientHistoryListPage(patient: user as Patient);
}

/// Called after a successful password login. Patients go straight to their
/// history; staff start an idle-lock session and are offered a quick PIN.
Future<void> completeLogin(BuildContext context, UserRole role, dynamic user) async {
  final navigator = Navigator.of(context);
  final home = homeFor(context, user);

  if (role == UserRole.patient) {
    navigator.pushReplacement(MaterialPageRoute(builder: (_) => home));
    return;
  }

  final userId = staffUserId(user)!;
  final lock = context.read<AppLockCubit>();
  await locator<DeviceSessionStore>().rememberUser(role, userId);
  lock.startSession();

  final hasPin = await locator<PinService>().hasPin(userId);
  if (!navigator.mounted) return;
  navigator.pushReplacement(
    MaterialPageRoute(
      builder: (_) => hasPin
          ? home
          : PinSetupPage(userId: userId, onFinished: (ctx) {
              Navigator.of(ctx).pushReplacement(
                MaterialPageRoute(builder: (_) => home),
              );
            }),
    ),
  );
}

/// Ends the session and returns to role selection. Uses the root navigator
/// and the shared BLoCs so it also works from the lock overlay.
void signOut() {
  locator<AuthBloc>().add(AuthLogoutRequested());
  locator<AppLockCubit>().endSession();
  appNavigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const UserTypeSelectionPage()),
    (route) => false,
  );
}
