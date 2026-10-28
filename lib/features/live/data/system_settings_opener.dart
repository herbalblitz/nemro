import 'package:app_settings/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the operating system's app settings page for Nemro.
///
/// This is used when camera permission is permanently denied, so the user
/// can re-enable it. It is wrapped behind a provider so widget tests can
/// substitute a fake instead of leaving the app during a test.
abstract interface class SystemSettingsOpener {
  Future<void> openAppSettings();
}

final systemSettingsOpenerProvider = Provider<SystemSettingsOpener>(
  (ref) => const AppSettingsSystemSettingsOpener(),
);

class AppSettingsSystemSettingsOpener implements SystemSettingsOpener {
  const AppSettingsSystemSettingsOpener();

  @override
  Future<void> openAppSettings() => AppSettings.openAppSettings();
}
