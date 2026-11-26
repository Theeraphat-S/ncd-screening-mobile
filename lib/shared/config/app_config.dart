/// Build-time configuration read from `--dart-define`.
///
/// Everything here is a compile-time constant, so turning a value on needs a
/// new build. That is intentional (ADR 0014): a prod APK cannot be switched
/// into a demo or debug mode on the device.
library;

enum AppFlavor { local, dev, prod }

class AppEnvironment {
  AppEnvironment._();

  /// `--dart-define=flavor=local|dev|prod`. Anything else, including no
  /// value at all, is treated as prod so a forgotten define never ships
  /// demo accounts.
  static const String flavorName = String.fromEnvironment('flavor');

  static AppFlavor get flavor => parseFlavor(flavorName);

  static AppFlavor parseFlavor(String name) => switch (name.trim()) {
        'local' => AppFlavor.local,
        'dev' => AppFlavor.dev,
        _ => AppFlavor.prod,
      };

  /// Demo villages, accounts (`NUR001` / `password123` …) and patients are
  /// only created in dev and local builds. Prod starts with an empty database.
  static bool get seedsDemoData => flavorSeedsDemoData(flavor);

  static bool flavorSeedsDemoData(AppFlavor flavor) => flavor != AppFlavor.prod;
}

/// Switches for features that are not ready for the pilot. All of them are
/// off unless a build turns them on, e.g. `--dart-define=FEATURE_EXPORT=true`.
class FeatureFlags {
  FeatureFlags._();

  /// Health-data export for nurses. Off until it is rebuilt to write a file
  /// through the share sheet in the format agreed at the pilot meeting
  /// (ADR 0014).
  static const bool export = bool.fromEnvironment('FEATURE_EXPORT');
}
