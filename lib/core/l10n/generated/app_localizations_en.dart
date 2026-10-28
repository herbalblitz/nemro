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
      'Camera frames are processed on-device and never recorded or uploaded.';

  @override
  String get onboardingConsentCheckbox => 'I understand and agree';

  @override
  String get onboardingContinue => 'Agree and continue';

  @override
  String get homeHeadline => 'The AI–brain loop, in your hands.';

  @override
  String get homeSubheadline =>
      'Replay real EEG, watch an on-device decoder estimate the imagined hand, and try a camera-based attention proxy.';

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
  String get homeLiveSubtitle => 'Camera attention proxy';

  @override
  String get homeLiveAction => 'Open Live';

  @override
  String get homeLiveBadge => 'DEMO';

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
  String labDecoderTrainingLoro(String train) {
    return 'Trained on runs $train; leave-one-run-out evaluation.';
  }

  @override
  String labDecoderAccuracy(int percent) {
    return 'Held-out accuracy: $percent% (chance 50%)';
  }

  @override
  String labDecoderAccuracyLoro(int percent) {
    return 'Leave-one-run-out accuracy: $percent% (chance 50%)';
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
  String get labDecoderPreprocessingLabel => 'Preprocessing';

  @override
  String get labDecoderLimitationsLabel => 'Limitations';

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
  String get liveBadge => 'ON-DEVICE';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get insightsEmptyTitle => 'No data yet';

  @override
  String get insightsEmptySavedOff =>
      'Turn on saving Live session summaries in Settings to keep them here.';

  @override
  String get insightsEmptySavedOn =>
      'No saved sessions yet. Complete a Live session and it will appear here.';

  @override
  String get insightsStart => 'Start Live';

  @override
  String get insightsSavedTitle => 'Saved Live sessions';

  @override
  String get insightsDelete => 'Delete session';

  @override
  String get learnTitle => 'Learn';

  @override
  String get learnSubtitle =>
      'A clear look at BCI, EEG, and the limits of the technology.';

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
  String get lesson1Body =>
      'Neurons talk in tiny electrical pulses. EEG listens from the scalp, picking up the summed activity of millions of neurons at once — a blurry, noisy window, never a single thought.';

  @override
  String get lesson2Body =>
      'A brain–computer interface turns brain signals into commands or feedback: signal, decode, respond. Nemro’s loop is exactly that — and it is only as good as the signal it reads.';

  @override
  String get lesson3Body =>
      'Implanted electrodes hear single neurons clearly, but need surgery. Scalp EEG is safe and easy, but coarse and noisy. Nemro stays on the non-invasive side — and Live uses no EEG at all, only a camera proxy.';

  @override
  String get lesson4Body =>
      'Ultrasound, MEG, and near-infrared light each sense the brain differently, trading precision for cost and portability. None of them reads thoughts either — they all measure indirect, noisy signals.';

  @override
  String get lesson5Body =>
      'No. Wi-Fi sensing notices movement and posture from disturbed radio waves — it never touches brain activity. Any product claiming to read your mind over Wi-Fi is hype, or a scam.';

  @override
  String get lesson6Body =>
      'Brain data is intimate, even when it is noisy. Nemro keeps everything on this device: no accounts, no tracking, no uploads. Session history is opt-in, and you can delete it any time.';

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
  String get settingsSaveLiveSummaries => 'Save Live session summaries';

  @override
  String get settingsSaveLiveSummariesBody =>
      'When on, completed Live session summaries are saved on this device only. Turn off to stop saving new ones.';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsDataBody =>
      'Nemro stores settings locally. Live session summaries are saved only when you turn that on.';

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
      'Nemro is local-first. Version 0.3.0 has no Internet permission. The bundled EEG sample, decoder, and Live camera proxy run entirely on-device.';

  @override
  String get privacyDataTitle => 'What data is stored?';

  @override
  String get privacyDataBody =>
      'Language, theme, and onboarding state. Live session summaries are saved on this device only if you turn saving on in Settings, and deleting all data in Settings wipes them. The Lab decoder processes the bundled sample locally; no EEG is collected from you.';

  @override
  String get privacyDecoderTitle => 'On-device AI';

  @override
  String get privacyDecoderBody =>
      'The Lab decoder is a small model bundled with the app. It runs locally on the EEG sample, and predictions never leave the device.';

  @override
  String get privacyCameraTitle => 'Camera';

  @override
  String get privacyCameraBody =>
      'Live opens the camera only after you tap Start. Frames are downsampled and processed on-device to estimate a rough light/contrast/motion proxy. No video or images are recorded, stored, or uploaded. The camera is released when you stop or leave the app; Nemro does not request microphone or storage access.';

  @override
  String get privacyStorageTitle => 'Storage';

  @override
  String get privacyStorageBody =>
      'Data lives in the app\'s private storage. You can delete everything in Settings.';

  @override
  String get privacySharingTitle => 'Sharing';

  @override
  String get privacySharingBody =>
      'No analytics, ads, or third-party data-collecting SDKs. The bundled decoder and camera proxy do not call a server.';

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

  @override
  String get liveStartTitle => 'Camera attention proxy';

  @override
  String get liveStartBody =>
      'A rough, on-device proxy built from light, contrast, and motion. It is not mind reading and not a medical measurement.';

  @override
  String get liveStartBullet1 => 'The camera starts only when you tap Start.';

  @override
  String get liveStartBullet2 =>
      'Frames are processed on-device. No video is recorded or uploaded.';

  @override
  String get liveStartBullet3 =>
      'Stop anytime. The camera is released when the session ends.';

  @override
  String get liveStartButton => 'Start camera session';

  @override
  String get liveStarting => 'Starting camera…';

  @override
  String get liveStartingBody =>
      'If prompted, allow camera access. Nemro does not use the microphone.';

  @override
  String get livePermissionHint =>
      'If you permanently denied access, enable Camera for Nemro in Android Settings.';

  @override
  String get liveOpenSettings => 'Open Settings';

  @override
  String get liveCameraLabel => 'Camera';

  @override
  String get liveCameraFront => 'Front';

  @override
  String get liveCameraBack => 'Back';

  @override
  String get livePreviewSemantics =>
      'Live camera preview. Frames are processed on-device.';

  @override
  String get liveLiveBadge => 'LIVE';

  @override
  String get liveScoreTitle => 'Proxy score';

  @override
  String get liveScoreCaption =>
      'Heuristic score from light, contrast, and stability. Not a measurement of thoughts.';

  @override
  String get liveScoreWarmingUp => 'Calibrating…';

  @override
  String get liveScoreWaiting => 'Waiting for frames…';

  @override
  String get liveScoreHigh => 'High';

  @override
  String get liveScoreMedium => 'Medium';

  @override
  String get liveScoreLow => 'Low';

  @override
  String get liveLightLabel => 'Light';

  @override
  String get liveStabilityLabel => 'Stability';

  @override
  String get liveFramesLabel => 'Frames analyzed';

  @override
  String get liveStopButton => 'Stop session';

  @override
  String get livePrivacyNote =>
      'Camera frames stay on this device. Nothing is recorded or uploaded.';

  @override
  String get liveSummaryTitle => 'Session summary';

  @override
  String get liveSummaryAverage => 'Average score';

  @override
  String get liveSummaryDuration => 'Duration';

  @override
  String get liveSummaryFrames => 'Frames';

  @override
  String get liveSummaryNoFrames =>
      'No frames were analyzed. Check camera access and try again.';

  @override
  String get liveSummaryPaused =>
      'The session stopped when the app left the foreground.';

  @override
  String get liveStartAgain => 'Start again';

  @override
  String get liveErrorTitle => 'Camera unavailable';

  @override
  String get liveErrorPermissionDenied =>
      'Camera permission was denied. Tap Retry to request it again.';

  @override
  String get liveErrorPermissionPermanentlyDenied =>
      'Camera access is blocked. Enable Camera for Nemro in Android Settings, then try again.';

  @override
  String get liveErrorRestricted =>
      'Camera access is restricted on this device.';

  @override
  String get liveErrorNoCamera => 'No camera was found on this device.';

  @override
  String get liveErrorUnavailable =>
      'Could not start the camera. Close other camera apps and try again.';

  @override
  String liveScoreSemantics(int score) {
    return 'Attention proxy score: $score out of 100';
  }
}
