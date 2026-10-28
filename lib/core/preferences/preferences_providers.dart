import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nemro/core/constants/app_constants.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main() and tests.',
  );
});

final localeProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);

class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final code = prefs.getString(AppConstants.prefLocale);
    if (code == null || !AppConstants.supportedLocaleCodes.contains(code)) {
      return null;
    }
    return Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(AppConstants.prefLocale, locale.languageCode);
    state = Locale(locale.languageCode);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return switch (prefs.getString(AppConstants.prefThemeMode)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(AppConstants.prefThemeMode, value);
    state = mode;
  }
}

final onboardingCompleteProvider = NotifierProvider<OnboardingController, bool>(
  OnboardingController.new,
);

final saveLiveSummariesProvider =
    NotifierProvider<SaveLiveSummariesController, bool>(
      SaveLiveSummariesController.new,
    );

/// Whether completed Live session summaries are saved on this device.
///
/// Defaults to OFF: with the toggle off, summaries stay memory-only and
/// nothing about a session is persisted.
class SaveLiveSummariesController extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(AppConstants.prefSaveLiveSummaries) ?? false;
  }

  Future<void> setValue(bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.prefSaveLiveSummaries, value);
    state = value;
  }
}

final liveCameraLensProvider =
    NotifierProvider<LiveCameraLensController, CameraLensDirection>(
      LiveCameraLensController.new,
    );

/// Which camera Live prefers. Defaults to front; the choice persists
/// across sessions. The gateway still falls back to the first available
/// camera when the preferred direction does not exist on the device.
class LiveCameraLensController extends Notifier<CameraLensDirection> {
  @override
  CameraLensDirection build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return switch (prefs.getString(AppConstants.prefLiveCameraLens)) {
      'back' => CameraLensDirection.back,
      _ => CameraLensDirection.front,
    };
  }

  Future<void> setLens(CameraLensDirection direction) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final code = direction == CameraLensDirection.back ? 'back' : 'front';
    await prefs.setString(AppConstants.prefLiveCameraLens, code);
    state = direction == CameraLensDirection.back
        ? CameraLensDirection.back
        : CameraLensDirection.front;
  }
}

class OnboardingController extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(AppConstants.prefOnboardingComplete) ?? false;
  }

  Future<void> complete() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.prefOnboardingComplete, true);
    state = true;
  }

  Future<void> reset() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.prefOnboardingComplete, false);
    state = false;
  }
}
