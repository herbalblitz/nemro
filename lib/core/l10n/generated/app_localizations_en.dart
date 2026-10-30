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
      'Replay real EEG, watch an on-device decoder estimate the imagined hand, and try a camera-based light/contrast/stability proxy.';

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
  String get homeLiveSubtitle => 'Camera signal proxy';

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
  String labDecoderAccuracyDetail(int trials, int low, int high) {
    return 'n = $trials; 95% Wilson interval $low%–$high%.';
  }

  @override
  String labDecoderTrainingCrossSubject(
    String trainingSubject,
    String train,
    String subject,
  ) {
    return 'Trained on $trainingSubject runs $train; not evaluated on $subject.';
  }

  @override
  String labDecoderCrossSubject(String subject, String trainingSubject) {
    return 'Cross-subject demo only: there is no accuracy claim for $subject. The held-out result applies to $trainingSubject.';
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
  String get labDecoderPreprocessingText =>
      '4.1 s epochs; per-window mean removal; Hann window; Goertzel power; log10; standardized features.';

  @override
  String get labDecoderLimitationsLabel => 'Limitations';

  @override
  String get labDecoderLimitationsText =>
      'Single subject (S001), 30 training trials, binary imagined-fist task. Not a medical device and not mind reading.';

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
  String labRunDescription(String subject) {
    return '$subject · run 4 · imagined left/right fist';
  }

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
  String get insightsDeleteConfirmTitle => 'Delete this session?';

  @override
  String get insightsDeleteConfirmBody =>
      'This removes the session summary from this device.';

  @override
  String get insightsTrendsTitle => 'Trends';

  @override
  String get insightsTrendCurrentStreak => 'Current streak';

  @override
  String get insightsTrendLongestStreak => 'Longest streak';

  @override
  String insightsTrendStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get insightsTrendBest => 'Best session';

  @override
  String get insightsTrendWorst => 'Weakest session';

  @override
  String get insightsTrendWeeklyTitle => 'Weekly averages';

  @override
  String insightsTrendSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
    );
    return '$_temp0';
  }

  @override
  String get insightsExport => 'Export CSV';

  @override
  String get insightsExportDone => 'Session history exported.';

  @override
  String get insightsExportFailed => 'Could not export session history.';

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
      'Nemro stores settings and an optional camera baseline locally. Live session summaries are saved only when you turn that on.';

  @override
  String get settingsDeleteData => 'Delete all local data';

  @override
  String get settingsDeleteDataBody =>
      'This removes settings, the camera baseline, saved Live sessions, and onboarding state.';

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
      'The Lab bundles 60-second EEGMMIDB excerpts from S001, S002, and S003 (ODC-BY 1.0). The decoder is a small logistic regression trained on S001 runs 8 and 12 and evaluated on run 4: 67% held-out accuracy, 50% chance. The S002 and S003 replays are cross-subject demos with no accuracy claim. Research demo only.';

  @override
  String get aboutRepo => 'Source on GitHub';

  @override
  String get aboutLicense => 'MIT License';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String privacyIntro(String version) {
    return 'Nemro is local-first. Version $version has Internet permission. The bundled EEG sample, decoder, and Live camera proxy run entirely on-device.';
  }

  @override
  String get privacyDataTitle => 'What data is stored?';

  @override
  String get privacyDataBody =>
      'Language, theme, onboarding state, camera lens preference, and an optional camera baseline range. Live session summaries are saved on this device only if you turn saving on in Settings, and deleting all data in Settings wipes them. The Lab decoder processes the bundled sample locally; no EEG is collected from you.';

  @override
  String get privacyDecoderTitle => 'On-device AI';

  @override
  String get privacyDecoderBody =>
      'The Lab decoder is a small model bundled with the app. It runs locally on the EEG sample, and predictions never leave the device.';

  @override
  String get privacyCameraTitle => 'Camera';

  @override
  String get privacyCameraBody =>
      'Live opens the camera only after you tap Start. Frames are downsampled and processed on-device to estimate a rough light/contrast/motion proxy. No video or images are recorded, stored, or uploaded. An optional calibration baseline (two numbers) can be stored locally. The camera is released when you stop or leave the app.';

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
  String get liveStartTitle => 'Camera signal proxy';

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
  String get liveBaselineTitle => 'Your baseline';

  @override
  String get liveBaselineBody =>
      'Calibrate once in your usual room and lighting. Later scores show relative to your usual range — still a camera proxy, never a brain measurement.';

  @override
  String liveBaselineRange(int low, int high) {
    return 'Usual range: $low–$high';
  }

  @override
  String get liveBaselineCalibrate => 'Calibrate baseline';

  @override
  String get liveBaselineRecalibrate => 'Recalibrate';

  @override
  String get liveBaselineCapturing =>
      'Calibrating… sit normally and stay in frame.';

  @override
  String liveBaselineProgress(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count frames captured',
      one: '1 frame captured',
    );
    return '$_temp0';
  }

  @override
  String liveBaselineNeeds(int min) {
    return 'Needs at least $min frames to save.';
  }

  @override
  String get liveBaselineStopSave => 'Stop and save baseline';

  @override
  String get liveBaselineCancel => 'Cancel calibration';

  @override
  String get liveBaselineSaved => 'Baseline saved.';

  @override
  String get liveBaselineClear => 'Clear baseline';

  @override
  String get liveBaselineSaveFailed =>
      'Could not save the baseline. Try again.';

  @override
  String get liveBaselineTooShort =>
      'Not enough frames to set a baseline. Stay in frame a little longer and try again.';

  @override
  String get liveBaselineRelativeNote =>
      'Relative to your usual range. Still a camera proxy, not a brain measurement.';

  @override
  String liveBaselineAbsolute(int score) {
    return 'Absolute proxy score: $score';
  }

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
    return 'Camera proxy score: $score out of 100';
  }

  @override
  String get labDecoderConfusionTitle =>
      'Confusion matrix (rows = actual, columns = predicted)';

  @override
  String get homePracticeTitle => 'Practice';

  @override
  String get homePracticeSubtitle =>
      'Adaptive breathing paced by the camera signal';

  @override
  String get homePracticeAction => 'Open';

  @override
  String get homePracticeBadge => 'New';

  @override
  String get practiceTitle => 'Practice';

  @override
  String get practiceIntro =>
      'A breathing session whose pace follows the camera signal. Sit in front of the camera, breathe with the circle, and let the exhale stretch when the signal is steady.';

  @override
  String get practiceHonestNote =>
      'The pace follows a camera-signal heuristic, not a measure of calm, focus, or any medical state. Nothing is recorded or uploaded.';

  @override
  String get practiceDurationLabel => 'Session length';

  @override
  String practiceMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get practiceStartButton => 'Start practice';

  @override
  String get practiceStopButton => 'Stop';

  @override
  String get practiceInhale => 'Breathe in';

  @override
  String get practiceHold => 'Hold';

  @override
  String get practiceExhale => 'Breathe out';

  @override
  String get practiceRemaining => 'Remaining';

  @override
  String get practiceSummaryTitle => 'Practice summary';

  @override
  String get practiceSummaryAverage => 'Average proxy score';

  @override
  String get practiceSummaryDuration => 'Duration';

  @override
  String get practiceSummaryCycles => 'Breathing cycles';

  @override
  String get practiceStartAgain => 'Practice again';

  @override
  String get homeResearchTitle => 'Research';

  @override
  String get homeResearchSubtitle =>
      'Landmark findings and self-run camera experiments';

  @override
  String get homeResearchAction => 'Open';

  @override
  String get homeResearchBadge => 'New';

  @override
  String get researchTitle => 'Research';

  @override
  String get researchSubtitle =>
      'Four landmark findings, each with its limits and sources — plus two short experiments you can run on this device to see how the camera proxy behaves.';

  @override
  String get researchHonestNote =>
      'Nothing here measures attention, calm, or any medical state. The experiments describe a camera signal only.';

  @override
  String get researchMilestonesTitle => 'Landmark findings';

  @override
  String get researchExperimentsTitle => 'Self-run experiments';

  @override
  String get researchLimitLabel => 'Limit';

  @override
  String get researchSourceLabel => 'Source';

  @override
  String get researchOpenSource => 'Open source';

  @override
  String get researchStartButton => 'Start experiment';

  @override
  String get researchStopButton => 'Stop';

  @override
  String get researchResultTitle => 'Experiment result';

  @override
  String get researchResultAverage => 'Average proxy score';

  @override
  String get researchResultStability => 'Average stability';

  @override
  String get researchResultLighting => 'Average lighting';

  @override
  String get researchResultPresence => 'Average presence';

  @override
  String get researchResultNote =>
      'This describes the camera signal during those 30 seconds only. It is not evidence about attention, calm, or any mental state.';

  @override
  String get researchRunAgain => 'Run again';

  @override
  String get researchBackToList => 'Back to list';

  @override
  String get researchMilestone1Title => '1929 — The first human EEG';

  @override
  String get researchMilestone1Body =>
      'Hans Berger in Jena, Germany, recorded electrical activity from the human scalp and described the alpha rhythm (roughly 8–13 Hz, strongest at rest with eyes closed). It was the start of electroencephalography — and of every non-invasive brain recording that followed.';

  @override
  String get researchMilestone1Limit =>
      'Crude early equipment and a handful of first subjects; the finding was a beginning, not a validated clinical tool.';

  @override
  String get researchMilestone1Source =>
      'Berger, H. (1929). Über das Elektrenkephalogramm des Menschen. Archiv für Psychiatrie und Nervenkrankheiten.';

  @override
  String get researchMilestone2Title => '1988 — Spelling with the P300 wave';

  @override
  String get researchMilestone2Body =>
      'Farwell and Donchin showed that a person can pick letters on a screen by attention alone: the brain produces a P300 response about 300 ms after a rare, attended stimulus, and a computer can decode which letter was chosen. It was one of the first non-invasive BCIs with a practical use — assisted communication.';

  @override
  String get researchMilestone2Limit =>
      'Slow (a few characters per minute at the time), needs per-person calibration and training; it decodes a choice among shown options, not free-form thought.';

  @override
  String get researchMilestone2Source =>
      'Farwell, L. A., & Donchin, E. (1988). Talking off the top of your head. Electroencephalography and Clinical Neurophysiology.';

  @override
  String get researchMilestone3Title =>
      '2004 — An open motor-imagery EEG dataset';

  @override
  String get researchMilestone3Body =>
      'The EEG Motor Movement/Imagery Dataset on PhysioNet recorded 109 people performing and imagining hand and foot movements (64 channels). It became an open standard for building and comparing decoders — Nemro\'s Lab replays three excerpts from it (S001, S002, and S003).';

  @override
  String get researchMilestone3Limit =>
      'Lab data from healthy volunteers following cues — far from everyday use; accuracy on this set says nothing about clinical effectiveness.';

  @override
  String get researchMilestone3Source =>
      'PhysioNet EEG Motor Movement/Imagery Dataset (EEGMMIDB); Schalk et al., BCI2000 (2004).';

  @override
  String get researchMilestone4Title => '2010 — Not everyone can drive a BCI';

  @override
  String get researchMilestone4Body =>
      'Work from the Berlin BCI group found that a substantial minority of users — often cited around 15–30% — never gain reliable control of a motor-imagery BCI despite training, a phenomenon called \'BCI illiteracy\'. BCI performance depends on the person, not just the technology.';

  @override
  String get researchMilestone4Limit =>
      'The share depends on how \'control\' is defined, the task, and training length; it does not mean those people\'s brains are in any way deficient.';

  @override
  String get researchMilestone4Source =>
      'Blankertz, B., et al. (2010). Neurophysiological predictor of SMR-based BCI performance. NeuroImage.';

  @override
  String get researchExperimentStillTitle => 'Sit still for 30 seconds';

  @override
  String get researchExperimentStillBody =>
      'Sit in front of the camera and stay as still as you can for 30 seconds. Watch what happens to the stability component and the score.';

  @override
  String get researchExperimentStillReading =>
      'If you sat still, stability usually rises and the score rises with it. That shows the score reacts to movement — not to focus, calm, or effort.';

  @override
  String get researchExperimentCoverTitle => 'Cover the lens, then uncover it';

  @override
  String get researchExperimentCoverBody =>
      'Start the run, cover the camera with your hand for a few seconds, then uncover it. Watch what happens to the presence component and the score.';

  @override
  String get researchExperimentCoverReading =>
      'Covering the lens collapses central contrast, so presence and the score fall with it — no change in mental state needed. The score follows the image it is given.';

  @override
  String get labDecoderModelLabel => 'Decoder';

  @override
  String get labDecoderModelLogistic => 'Logistic';

  @override
  String get labDecoderModelCentroid => 'Centroid';

  @override
  String labDecoderModelCentroidLine(Object count) {
    return 'Nearest centroid · mu/beta power · $count channels';
  }

  @override
  String labDecoderTrainingInSample(Object train) {
    return 'Trained on the replay itself ($train); no held-out run.';
  }

  @override
  String labDecoderAccuracyInSample(Object percent) {
    return 'In-sample accuracy: $percent% (chance 50%)';
  }

  @override
  String get labDecoderInSampleNote =>
      'In-sample accuracy flatters the model: it was tested on the very windows it learned from, so it cannot be compared with held-out accuracy.';

  @override
  String get algorithmsTitle => 'Algorithms that build AI';

  @override
  String get algorithmsSubtitle =>
      'Four algorithms, from 1847 to 2017, that turn data into a learning machine — plus three hands-on experiments that run real training on this device.';

  @override
  String get algorithmsHonestNote =>
      'Everything here runs on-device with tiny toy data. These demos teach how the algorithms work; they are not powerful models and they prove nothing about the brain.';

  @override
  String get algorithmsCardsTitle => 'The algorithms';

  @override
  String get algorithmsExperimentsTitle => 'Try the algorithms';

  @override
  String get algorithmsCard1Title => '1847 — Gradient descent';

  @override
  String get algorithmsCard1Body =>
      'To teach a model, first define how wrong it is (a loss), then walk downhill: nudge every parameter a little against the slope of the loss, and repeat. Cauchy described the idea in 1847; it still trains nearly every model today.';

  @override
  String get algorithmsCard1Limit =>
      'It finds a downhill step, not the best answer: it can stall in a shallow valley or bounce forever if the step is too big.';

  @override
  String get algorithmsCard1Source =>
      'Cauchy, A. (1847). Méthode générale pour la résolution des systèmes d\'équations simultanées.';

  @override
  String get algorithmsCard2Title => '1958 — The perceptron';

  @override
  String get algorithmsCard2Body =>
      'Rosenblatt\'s perceptron is the first machine that learns from examples: it draws a line between two classes and moves the line a little every time it misclassifies a point, until the line separates them — or it proves they cannot be separated.';

  @override
  String get algorithmsCard2Limit =>
      'A single line can only separate linearly separable classes. It cannot learn XOR, which is why networks needed hidden layers.';

  @override
  String get algorithmsCard2Source =>
      'Rosenblatt, F. (1958). The perceptron: A probabilistic model for information storage and organization in the brain.';

  @override
  String get algorithmsCard3Title => '1986 — Backpropagation';

  @override
  String get algorithmsCard3Body =>
      'Backpropagation answers \'who is to blame?\' for a wrong answer: it sends the error backwards through the network, layer by layer, so every weight learns how much it contributed — and gradient descent then corrects each one.';

  @override
  String get algorithmsCard3Limit =>
      'It needs labelled examples and differentiable math; it explains how weights move, not what the network \'understands\'.';

  @override
  String get algorithmsCard3Source =>
      'Rumelhart, D. E., Hinton, G. E., & Williams, R. J. (1986). Learning representations by back-propagating errors. Nature.';

  @override
  String get algorithmsCard4Title => '2017 — Attention and the transformer';

  @override
  String get algorithmsCard4Body =>
      'Instead of reading words one by one, attention lets every word weigh every other word at once, so context shapes meaning. The transformer stacked attention into the architecture behind today\'s language models.';

  @override
  String get algorithmsCard4Limit =>
      'Attention is weighted averaging, not comprehension: fluent text is not evidence of understanding, and its cost grows with sequence length.';

  @override
  String get algorithmsCard4Source =>
      'Vaswani, A., et al. (2017). Attention is all you need. Advances in Neural Information Processing Systems.';

  @override
  String get algorithmsExperimentPerceptronTitle =>
      'Teach a line to separate two classes';

  @override
  String get algorithmsExperimentPerceptronBody =>
      'Tap the board to place points: red for class A, blue for class B. Then press Train and watch the line move until it separates them — or fails, if you placed them so no line can.';

  @override
  String get algorithmsExperimentPerceptronReading =>
      'The line only moves when it makes a mistake. If your points overlap, no line can separate them: that is the perceptron\'s limit, not a bug.';

  @override
  String get algorithmsExperimentGradientTitle =>
      'Walk downhill without falling off';

  @override
  String get algorithmsExperimentGradientBody =>
      'Move the learning-rate slider, then press Run. A small step crawls downhill; a huge step bounces out of the valley. The algorithm is the same — only the step size changes.';

  @override
  String get algorithmsExperimentGradientReading =>
      'Step size is the whole game: too small wastes time, too big diverges. Tuning it is most of practical training.';

  @override
  String get algorithmsExperimentOverfitTitle =>
      'Fit the noise, miss the pattern';

  @override
  String get algorithmsExperimentOverfitBody =>
      'Slide the degree from 1 to 9 and watch the curve. A straight line underfits; a wiggly degree-9 curve memorises every noisy point and will fail on new data.';

  @override
  String get algorithmsExperimentOverfitReading =>
      'Training error always falls as the curve gets wigglier — that is why it cannot be trusted alone. Generalisation, not memorisation, is the goal.';

  @override
  String get algorithmsPerceptronClassA => 'Class A';

  @override
  String get algorithmsPerceptronClassB => 'Class B';

  @override
  String get algorithmsPerceptronDemo => 'Load demo points';

  @override
  String get algorithmsPerceptronTrain => 'Train';

  @override
  String get algorithmsPerceptronClear => 'Clear';

  @override
  String algorithmsPerceptronAccuracy(int percent) {
    return 'Accuracy: $percent%';
  }

  @override
  String algorithmsPerceptronEpochs(int epochs) {
    return 'Line after $epochs epochs';
  }

  @override
  String algorithmsGradientLearningRate(String value) {
    return 'Learning rate: $value';
  }

  @override
  String get algorithmsGradientRun => 'Run';

  @override
  String algorithmsGradientConverged(String loss) {
    return 'Converged: final loss $loss';
  }

  @override
  String get algorithmsGradientDiverged =>
      'Diverged: the steps left the valley';

  @override
  String algorithmsGradientNotYet(int steps) {
    return 'Not yet converged after $steps steps';
  }

  @override
  String algorithmsOverfitDegree(int degree) {
    return 'Degree: $degree';
  }

  @override
  String algorithmsOverfitTrainError(String error) {
    return 'Training error: $error';
  }

  @override
  String get homeAlgorithmsTitle => 'Algorithms';

  @override
  String get homeAlgorithmsSubtitle =>
      'The algorithms that build AI, with experiments that really train.';

  @override
  String get homeAlgorithmsAction => 'Explore';

  @override
  String get homeAlgorithmsBadge => 'New';

  @override
  String get algorithmsAdvancedTitle => 'In-depth experiments';

  @override
  String get algorithmsExperimentMlpTitle =>
      'Teach a real network XOR with backpropagation';

  @override
  String get algorithmsExperimentMlpBody =>
      'The perceptron card said a single line cannot learn XOR. This network has a hidden layer of 4 units and learns with real backpropagation: forward pass, error, backward pass, weight update — repeated 5,000 times. Press Train and watch the loss fall and the boundary bend around XOR.';

  @override
  String get algorithmsExperimentMlpReading =>
      'The hidden layer bends the boundary: the network solves XOR by combining lines. That is the whole trick of deep learning — stacked simple units.';

  @override
  String algorithmsMlpLoss(String loss) {
    return 'Loss: $loss';
  }

  @override
  String get algorithmsExperimentAttentionTitle =>
      'Watch attention weigh words';

  @override
  String get algorithmsExperimentAttentionBody =>
      'Four words, each with a small query and key vector. Tap a word to make it the query: its attention weights over all four words are dot products passed through a softmax. The output for that word would be just the weighted average of the values.';

  @override
  String get algorithmsExperimentAttentionReading =>
      'Attention is arithmetic, not understanding: a word pulls numbers from other words according to fixed vectors. Nothing here knows what \'cat\' means.';

  @override
  String get algorithmsAttentionTokens => 'The,cat,chases,mouse';

  @override
  String get algorithmsExperimentInitTitle => 'Zero weights learn nothing';

  @override
  String get algorithmsExperimentInitBody =>
      'Same network, same data, two starts. Random weights break symmetry and the network learns XOR; all-zero weights keep every hidden unit identical forever, so the network stays stuck.';

  @override
  String get algorithmsExperimentInitReading =>
      'Symmetry is the enemy: if all units start equal, they receive equal updates and stay equal. Initialization is part of the algorithm, not a detail.';

  @override
  String get algorithmsInitRandom => 'Random start';

  @override
  String get algorithmsInitZeros => 'Zero start';
}
