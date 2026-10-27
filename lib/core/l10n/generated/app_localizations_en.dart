// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Nemro';

  @override
  String get appTagline => 'Your brain, in the loop';

  @override
  String get languageVietnamese => 'Vietnamese';

  @override
  String get languageEnglish => 'English';

  @override
  String get onboardingLanguageTitle => 'Choose your language';

  @override
  String get onboardingLanguageSubtitle =>
      'You can change this anytime in Settings.';

  @override
  String get onboardingConsentTitle => 'Before we start';

  @override
  String get onboardingConsentPoint1 => 'Nemro does not read minds.';

  @override
  String get onboardingConsentPoint2 => 'It is not a medical device.';

  @override
  String get onboardingConsentPoint3 => 'Your data stays on this device.';

  @override
  String get onboardingConsentPoint4 =>
      'Camera frames are processed on-device and never recorded.';

  @override
  String get onboardingConsentCheckbox => 'I understand and agree';

  @override
  String get onboardingContinue => 'Agree and continue';

  @override
  String get homeHeadline => 'The AI–brain loop, in your hands.';

  @override
  String get homeSubheadline =>
      'Replay real EEG, watch an on-device decoder estimate the imagined hand, and learn what BCI can really do.';

  @override
  String get homeLabTitle => 'Lab';

  @override
  String get homeLabSubtitle => 'Replay + on-device decoder';

  @override
  String get homeLabAction => 'Open Lab';

  @override
  String get homeLabBadge => 'DEMO';

  @override
  String get homeLiveTitle => 'Live';

  @override
  String get homeLiveSubtitle => 'Track attention';

  @override
  String get homeLiveAction => 'Enable camera';

  @override
  String get homeLiveBadge => 'SOON';

  @override
  String get homeRecentTitle => 'Latest session';

  @override
  String get homeRecentEmpty => 'No saved sessions yet. Try the Lab decoder.';

  @override
  String get homeRecentAction => 'Open Lab';

  @override
  String get homeFooter =>
      'Open source. Not a medical device. Not mind reading.';

  @override
  String get navHome => 'Home';

  @override
  String get navInsights => 'Insights';

  @override
  String get navLearn => 'Learn';

  @override
  String get navSettings => 'Settings';

  @override
  String get labTitle => 'Lab';

  @override
  String get labReplayTitle => 'EEG replay';

  @override
  String get labReplayIntro =>
      'A real 60-second window from the PhysioNet motor-imagery dataset. Press play to inspect the raw signal, its task markers, and the on-device decoder output.';

  @override
  String get labReplayBadge => 'REPLAY';

  @override
  String labChannelSummary(int count, int rate) {
    return '$count channels · $rate Hz';
  }

  @override
  String labWindowLabel(int seconds) {
    return '$seconds-second window';
  }

  @override
  String get labPlay => 'Play';

  @override
  String get labPause => 'Pause';

  @override
  String get labRestart => 'Restart';

  @override
  String get labNow => 'Now';

  @override
  String get labRest => 'Rest';

  @override
  String get labLeftFist => 'Left fist imagery';

  @override
  String get labRightFist => 'Right fist imagery';

  @override
  String get labDecoderTitle => 'AI decoder';

  @override
  String get labDecoderBody =>
      'A small model estimates the imagined hand from mu/beta band power. It runs entirely on this device; no EEG leaves the phone.';

  @override
  String get labOnDeviceBadge => 'ON-DEVICE';

  @override
  String labDecoderModel(int count) {
    return 'Logistic regression · mu/beta power · $count channels';
  }

  @override
  String labDecoderTraining(String train, String test) {
    return 'Trained on runs $train; evaluated on run $test.';
  }

  @override
  String labDecoderAccuracy(int percent) {
    return 'Held-out accuracy: $percent% (chance 50%)';
  }

  @override
  String get labDecoderLoading => 'Loading the on-device model…';

  @override
  String get labDecoderIdle => 'Rest — decoder idle.';

  @override
  String get labDecoderDecoding => 'Decoding this window…';

  @override
  String get labDecoderIncomplete => 'Not enough signal in this window.';

  @override
  String get labDecoderUnavailable => 'Decoder unavailable.';

  @override
  String get labDecoderPrediction => 'Prediction';

  @override
  String get labDecoderMarker => 'Marker';

  @override
  String get labDecoderLimitations =>
      'Single subject (S001). Demo only; not a medical device and not mind reading.';

  @override
  String get labDatasetTitle => 'Dataset & license';

  @override
  String get labSourceLabel => 'Source';

  @override
  String get labRecordingLabel => 'Recording';

  @override
  String get labChannelsLabel => 'Signal';

  @override
  String get labLicenseLabel => 'License';

  @override
  String get labRunDescription => 'S001 · run 4 · imagined left/right fist';

  @override
  String get labOpenDataset => 'Open dataset page';

  @override
  String get labLoading => 'Loading EEG…';

  @override
  String get labLoadError => 'Could not load the EEG sample.';

  @override
  String get labRetry => 'Retry';

  @override
  String get liveTitle => 'Live';

  @override
  String get liveComingSoonTitle => 'Attention tracking is being built';

  @override
  String get liveComingSoonBody =>
      'S2 uses the camera to estimate attention and fatigue, entirely on-device.';

  @override
  String get liveBadge => 'SOON';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get insightsEmptyTitle => 'No data yet';

  @override
  String get insightsEmptyBody => 'Live and Lab sessions will appear here.';

  @override
  String get insightsStart => 'Start Live';

  @override
  String get learnTitle => 'Learn';

  @override
  String get learnSubtitle =>
      'A clear look at BCI, EEG, and the limits of the technology.';

  @override
  String get learnComingSoon => 'Bilingual lessons arrive in S3.';

  @override
  String get lesson1Title => 'Neurons and EEG';

  @override
  String get lesson2Title => 'What is a BCI?';

  @override
  String get lesson3Title => 'Invasive vs non-invasive';

  @override
  String get lesson4Title => 'Ultrasound, magnetism, light';

  @override
  String get lesson5Title => 'Can Wi-Fi read the brain?';

  @override
  String get lesson6Title => 'Ethics and privacy';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacyBody =>
      'Data stays on this device. No account, no ads, no tracking.';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsDataBody =>
      'Nemro stores settings locally. Sessions will be added in later versions.';

  @override
  String get settingsDeleteData => 'Delete all local data';

  @override
  String get settingsDeleteDataBody =>
      'This removes settings, language choice, and onboarding state.';

  @override
  String get settingsDeleteDataConfirm => 'Delete all local data?';

  @override
  String get settingsDeleteDataDone => 'Local data cleared.';

  @override
  String get settingsDelete => 'Delete';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsLicenses => 'Open-source licenses';

  @override
  String get aboutTitle => 'About Nemro';

  @override
  String get aboutBody =>
      'Nemro is an open-source project for understanding the AI–brain loop: AI decoding neural signals, feeding back to the user, and the real limits of the technology.';

  @override
  String get aboutDisclaimerTitle => 'Disclaimer';

  @override
  String get aboutDisclaimerBody =>
      'Nemro is not a medical device, does not read minds, and is not a substitute for medical advice.';

  @override
  String get aboutSources => 'Sources';

  @override
  String get aboutSourceEeg => 'PhysioNet EEG Motor Movement/Imagery Dataset';

  @override
  String get aboutSourceModel => 'On-device decoder';

  @override
  String get aboutSourcePlanned => 'Planned';

  @override
  String get aboutSourceBci => 'BCI Competition IV 2a';

  @override
  String get aboutSourceNote =>
      'The Lab bundles a 60-second EEGMMIDB excerpt (ODC-BY 1.0). Its decoder is a small logistic regression trained on S001 runs 8 and 12 and evaluated on run 4: 67% held-out accuracy, 50% chance. Research demo only.';

  @override
  String get aboutRepo => 'Source on GitHub';

  @override
  String get aboutLicense => 'MIT License';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get privacyIntro =>
      'Nemro is local-first. Version 0.2.0 has no Internet permission. The bundled EEG sample and decoder run entirely on-device.';

  @override
  String get privacyDataTitle => 'What data is stored?';

  @override
  String get privacyDataBody =>
      'Language, theme, and onboarding state. Lab and Live sessions will be stored locally when added in later versions. The Lab decoder processes the bundled sample locally; no EEG is collected from you.';

  @override
  String get privacyDecoderTitle => 'On-device AI';

  @override
  String get privacyDecoderBody =>
      'The Lab decoder is a small model bundled with the app. It runs locally on the EEG sample, and predictions never leave the device.';

  @override
  String get privacyCameraTitle => 'Camera';

  @override
  String get privacyCameraBody =>
      'When Live is enabled, the camera processes frames on-device to estimate attention. No video is stored or sent.';

  @override
  String get privacyStorageTitle => 'Storage';

  @override
  String get privacyStorageBody =>
      'Data lives in the app\'s private storage. You can delete everything in Settings.';

  @override
  String get privacySharingTitle => 'Sharing';

  @override
  String get privacySharingBody =>
      'No analytics, ads, or third-party data-collecting SDKs. The bundled decoder does not call a server.';

  @override
  String get privacyContactTitle => 'Contact';

  @override
  String get privacyContactBody => 'Open an issue on the project\'s GitHub.';

  @override
  String get commonBack => 'Back';

  @override
  String get commonClose => 'Close';

  @override
  String get commonComingSoon => 'Coming soon';

  @override
  String get commonLearnMore => 'Learn more';

  @override
  String get commonError => 'Something went wrong';

  @override
  String get commonRetry => 'Retry';
}
