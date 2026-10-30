import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Nemro'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your brain, in the loop'**
  String get appTagline;

  /// No description provided for @languageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get languageVietnamese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @onboardingLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get onboardingLanguageTitle;

  /// No description provided for @onboardingLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime in Settings.'**
  String get onboardingLanguageSubtitle;

  /// No description provided for @onboardingConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Before we start'**
  String get onboardingConsentTitle;

  /// No description provided for @onboardingConsentPoint1.
  ///
  /// In en, this message translates to:
  /// **'Nemro does not read minds.'**
  String get onboardingConsentPoint1;

  /// No description provided for @onboardingConsentPoint2.
  ///
  /// In en, this message translates to:
  /// **'It is not a medical device.'**
  String get onboardingConsentPoint2;

  /// No description provided for @onboardingConsentPoint3.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on this device.'**
  String get onboardingConsentPoint3;

  /// No description provided for @onboardingConsentPoint4.
  ///
  /// In en, this message translates to:
  /// **'Camera frames are processed on-device and never recorded or uploaded.'**
  String get onboardingConsentPoint4;

  /// No description provided for @onboardingConsentCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I understand and agree'**
  String get onboardingConsentCheckbox;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Agree and continue'**
  String get onboardingContinue;

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'The AI–brain loop, in your hands.'**
  String get homeHeadline;

  /// No description provided for @homeSubheadline.
  ///
  /// In en, this message translates to:
  /// **'Replay real EEG, watch an on-device decoder estimate the imagined hand, and try a camera-based light/contrast/stability proxy.'**
  String get homeSubheadline;

  /// No description provided for @homeLabTitle.
  ///
  /// In en, this message translates to:
  /// **'Lab'**
  String get homeLabTitle;

  /// No description provided for @homeLabSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replay + on-device decoder'**
  String get homeLabSubtitle;

  /// No description provided for @homeLabAction.
  ///
  /// In en, this message translates to:
  /// **'Open Lab'**
  String get homeLabAction;

  /// No description provided for @homeLabBadge.
  ///
  /// In en, this message translates to:
  /// **'DEMO'**
  String get homeLabBadge;

  /// No description provided for @homeLiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get homeLiveTitle;

  /// No description provided for @homeLiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Camera signal proxy'**
  String get homeLiveSubtitle;

  /// No description provided for @homeLiveAction.
  ///
  /// In en, this message translates to:
  /// **'Open Live'**
  String get homeLiveAction;

  /// No description provided for @homeLiveBadge.
  ///
  /// In en, this message translates to:
  /// **'DEMO'**
  String get homeLiveBadge;

  /// No description provided for @homeRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Latest session'**
  String get homeRecentTitle;

  /// No description provided for @homeRecentEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved sessions yet. Try the Lab decoder.'**
  String get homeRecentEmpty;

  /// No description provided for @homeRecentAction.
  ///
  /// In en, this message translates to:
  /// **'Open Lab'**
  String get homeRecentAction;

  /// No description provided for @homeFooter.
  ///
  /// In en, this message translates to:
  /// **'Open source. Not a medical device. Not mind reading.'**
  String get homeFooter;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navInsights;

  /// No description provided for @navLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navLearn;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @labTitle.
  ///
  /// In en, this message translates to:
  /// **'Lab'**
  String get labTitle;

  /// No description provided for @labReplayTitle.
  ///
  /// In en, this message translates to:
  /// **'EEG replay'**
  String get labReplayTitle;

  /// No description provided for @labReplayIntro.
  ///
  /// In en, this message translates to:
  /// **'A real 60-second window from the PhysioNet motor-imagery dataset. Press play to inspect the raw signal, its task markers, and the on-device decoder output.'**
  String get labReplayIntro;

  /// No description provided for @labReplayBadge.
  ///
  /// In en, this message translates to:
  /// **'REPLAY'**
  String get labReplayBadge;

  /// No description provided for @labChannelSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} channels · {rate} Hz'**
  String labChannelSummary(int count, int rate);

  /// No description provided for @labWindowLabel.
  ///
  /// In en, this message translates to:
  /// **'{seconds}-second window'**
  String labWindowLabel(int seconds);

  /// No description provided for @labPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get labPlay;

  /// No description provided for @labPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get labPause;

  /// No description provided for @labRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get labRestart;

  /// No description provided for @labNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get labNow;

  /// No description provided for @labRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get labRest;

  /// No description provided for @labLeftFist.
  ///
  /// In en, this message translates to:
  /// **'Left fist imagery'**
  String get labLeftFist;

  /// No description provided for @labRightFist.
  ///
  /// In en, this message translates to:
  /// **'Right fist imagery'**
  String get labRightFist;

  /// No description provided for @labDecoderTitle.
  ///
  /// In en, this message translates to:
  /// **'AI decoder'**
  String get labDecoderTitle;

  /// No description provided for @labDecoderBody.
  ///
  /// In en, this message translates to:
  /// **'A small model estimates the imagined hand from mu/beta band power. It runs entirely on this device; no EEG leaves the phone.'**
  String get labDecoderBody;

  /// No description provided for @labOnDeviceBadge.
  ///
  /// In en, this message translates to:
  /// **'ON-DEVICE'**
  String get labOnDeviceBadge;

  /// No description provided for @labDecoderModel.
  ///
  /// In en, this message translates to:
  /// **'Logistic regression · mu/beta power · {count} channels'**
  String labDecoderModel(int count);

  /// No description provided for @labDecoderTraining.
  ///
  /// In en, this message translates to:
  /// **'Trained on runs {train}; evaluated on run {test}.'**
  String labDecoderTraining(String train, String test);

  /// No description provided for @labDecoderTrainingLoro.
  ///
  /// In en, this message translates to:
  /// **'Trained on runs {train}; leave-one-run-out evaluation.'**
  String labDecoderTrainingLoro(String train);

  /// No description provided for @labDecoderAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Held-out accuracy: {percent}% (chance 50%)'**
  String labDecoderAccuracy(int percent);

  /// No description provided for @labDecoderAccuracyLoro.
  ///
  /// In en, this message translates to:
  /// **'Leave-one-run-out accuracy: {percent}% (chance 50%)'**
  String labDecoderAccuracyLoro(int percent);

  /// No description provided for @labDecoderAccuracyDetail.
  ///
  /// In en, this message translates to:
  /// **'n = {trials}; 95% Wilson interval {low}%–{high}%.'**
  String labDecoderAccuracyDetail(int trials, int low, int high);

  /// No description provided for @labDecoderTrainingCrossSubject.
  ///
  /// In en, this message translates to:
  /// **'Trained on {trainingSubject} runs {train}; not evaluated on {subject}.'**
  String labDecoderTrainingCrossSubject(
    String trainingSubject,
    String train,
    String subject,
  );

  /// No description provided for @labDecoderCrossSubject.
  ///
  /// In en, this message translates to:
  /// **'Cross-subject demo only: there is no accuracy claim for {subject}. The held-out result applies to {trainingSubject}.'**
  String labDecoderCrossSubject(String subject, String trainingSubject);

  /// No description provided for @labDecoderLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading the on-device model…'**
  String get labDecoderLoading;

  /// No description provided for @labDecoderIdle.
  ///
  /// In en, this message translates to:
  /// **'Rest — decoder idle.'**
  String get labDecoderIdle;

  /// No description provided for @labDecoderDecoding.
  ///
  /// In en, this message translates to:
  /// **'Decoding this window…'**
  String get labDecoderDecoding;

  /// No description provided for @labDecoderIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Not enough signal in this window.'**
  String get labDecoderIncomplete;

  /// No description provided for @labDecoderUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Decoder unavailable.'**
  String get labDecoderUnavailable;

  /// No description provided for @labDecoderPrediction.
  ///
  /// In en, this message translates to:
  /// **'Prediction'**
  String get labDecoderPrediction;

  /// No description provided for @labDecoderMarker.
  ///
  /// In en, this message translates to:
  /// **'Marker'**
  String get labDecoderMarker;

  /// No description provided for @labDecoderLimitations.
  ///
  /// In en, this message translates to:
  /// **'Single subject (S001). Demo only; not a medical device and not mind reading.'**
  String get labDecoderLimitations;

  /// No description provided for @labDecoderPreprocessingLabel.
  ///
  /// In en, this message translates to:
  /// **'Preprocessing'**
  String get labDecoderPreprocessingLabel;

  /// No description provided for @labDecoderPreprocessingText.
  ///
  /// In en, this message translates to:
  /// **'4.1 s epochs; per-window mean removal; Hann window; Goertzel power; log10; standardized features.'**
  String get labDecoderPreprocessingText;

  /// No description provided for @labDecoderLimitationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Limitations'**
  String get labDecoderLimitationsLabel;

  /// No description provided for @labDecoderLimitationsText.
  ///
  /// In en, this message translates to:
  /// **'Single subject (S001), 30 training trials, binary imagined-fist task. Not a medical device and not mind reading.'**
  String get labDecoderLimitationsText;

  /// No description provided for @labDatasetTitle.
  ///
  /// In en, this message translates to:
  /// **'Dataset & license'**
  String get labDatasetTitle;

  /// No description provided for @labSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get labSourceLabel;

  /// No description provided for @labRecordingLabel.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get labRecordingLabel;

  /// No description provided for @labChannelsLabel.
  ///
  /// In en, this message translates to:
  /// **'Signal'**
  String get labChannelsLabel;

  /// No description provided for @labLicenseLabel.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get labLicenseLabel;

  /// No description provided for @labRunDescription.
  ///
  /// In en, this message translates to:
  /// **'{subject} · run 4 · imagined left/right fist'**
  String labRunDescription(String subject);

  /// No description provided for @labOpenDataset.
  ///
  /// In en, this message translates to:
  /// **'Open dataset page'**
  String get labOpenDataset;

  /// No description provided for @labLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading EEG…'**
  String get labLoading;

  /// No description provided for @labLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the EEG sample.'**
  String get labLoadError;

  /// No description provided for @labRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get labRetry;

  /// No description provided for @liveTitle.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get liveTitle;

  /// No description provided for @liveBadge.
  ///
  /// In en, this message translates to:
  /// **'ON-DEVICE'**
  String get liveBadge;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// No description provided for @insightsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get insightsEmptyTitle;

  /// No description provided for @insightsEmptySavedOff.
  ///
  /// In en, this message translates to:
  /// **'Turn on saving Live session summaries in Settings to keep them here.'**
  String get insightsEmptySavedOff;

  /// No description provided for @insightsEmptySavedOn.
  ///
  /// In en, this message translates to:
  /// **'No saved sessions yet. Complete a Live session and it will appear here.'**
  String get insightsEmptySavedOn;

  /// No description provided for @insightsStart.
  ///
  /// In en, this message translates to:
  /// **'Start Live'**
  String get insightsStart;

  /// No description provided for @insightsSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Live sessions'**
  String get insightsSavedTitle;

  /// No description provided for @insightsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete session'**
  String get insightsDelete;

  /// No description provided for @insightsDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this session?'**
  String get insightsDeleteConfirmTitle;

  /// No description provided for @insightsDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the session summary from this device.'**
  String get insightsDeleteConfirmBody;

  /// No description provided for @insightsTrendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get insightsTrendsTitle;

  /// No description provided for @insightsTrendCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get insightsTrendCurrentStreak;

  /// No description provided for @insightsTrendLongestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get insightsTrendLongestStreak;

  /// No description provided for @insightsTrendStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day} other{{days} days}}'**
  String insightsTrendStreakDays(int days);

  /// No description provided for @insightsTrendBest.
  ///
  /// In en, this message translates to:
  /// **'Best session'**
  String get insightsTrendBest;

  /// No description provided for @insightsTrendWorst.
  ///
  /// In en, this message translates to:
  /// **'Weakest session'**
  String get insightsTrendWorst;

  /// No description provided for @insightsTrendWeeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly averages'**
  String get insightsTrendWeeklyTitle;

  /// No description provided for @insightsTrendSessions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session} other{{count} sessions}}'**
  String insightsTrendSessions(int count);

  /// No description provided for @insightsExport.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get insightsExport;

  /// No description provided for @insightsExportDone.
  ///
  /// In en, this message translates to:
  /// **'Session history exported.'**
  String get insightsExportDone;

  /// No description provided for @insightsExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not export session history.'**
  String get insightsExportFailed;

  /// No description provided for @learnTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learnTitle;

  /// No description provided for @learnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A clear look at BCI, EEG, and the limits of the technology.'**
  String get learnSubtitle;

  /// No description provided for @lesson1Title.
  ///
  /// In en, this message translates to:
  /// **'Neurons and EEG'**
  String get lesson1Title;

  /// No description provided for @lesson2Title.
  ///
  /// In en, this message translates to:
  /// **'What is a BCI?'**
  String get lesson2Title;

  /// No description provided for @lesson3Title.
  ///
  /// In en, this message translates to:
  /// **'Invasive vs non-invasive'**
  String get lesson3Title;

  /// No description provided for @lesson4Title.
  ///
  /// In en, this message translates to:
  /// **'Ultrasound, magnetism, light'**
  String get lesson4Title;

  /// No description provided for @lesson5Title.
  ///
  /// In en, this message translates to:
  /// **'Can Wi-Fi read the brain?'**
  String get lesson5Title;

  /// No description provided for @lesson6Title.
  ///
  /// In en, this message translates to:
  /// **'Ethics and privacy'**
  String get lesson6Title;

  /// No description provided for @lesson1Body.
  ///
  /// In en, this message translates to:
  /// **'Neurons talk in tiny electrical pulses. EEG listens from the scalp, picking up the summed activity of millions of neurons at once — a blurry, noisy window, never a single thought.'**
  String get lesson1Body;

  /// No description provided for @lesson2Body.
  ///
  /// In en, this message translates to:
  /// **'A brain–computer interface turns brain signals into commands or feedback: signal, decode, respond. Nemro’s loop is exactly that — and it is only as good as the signal it reads.'**
  String get lesson2Body;

  /// No description provided for @lesson3Body.
  ///
  /// In en, this message translates to:
  /// **'Implanted electrodes hear single neurons clearly, but need surgery. Scalp EEG is safe and easy, but coarse and noisy. Nemro stays on the non-invasive side — and Live uses no EEG at all, only a camera proxy.'**
  String get lesson3Body;

  /// No description provided for @lesson4Body.
  ///
  /// In en, this message translates to:
  /// **'Ultrasound, MEG, and near-infrared light each sense the brain differently, trading precision for cost and portability. None of them reads thoughts either — they all measure indirect, noisy signals.'**
  String get lesson4Body;

  /// No description provided for @lesson5Body.
  ///
  /// In en, this message translates to:
  /// **'No. Wi-Fi sensing notices movement and posture from disturbed radio waves — it never touches brain activity. Any product claiming to read your mind over Wi-Fi is hype, or a scam.'**
  String get lesson5Body;

  /// No description provided for @lesson6Body.
  ///
  /// In en, this message translates to:
  /// **'Brain data is intimate, even when it is noisy. Nemro keeps everything on this device: no accounts, no tracking, no uploads. Session history is opt-in, and you can delete it any time.'**
  String get lesson6Body;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Data stays on this device. No account, no ads, no tracking.'**
  String get settingsPrivacyBody;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsSaveLiveSummaries.
  ///
  /// In en, this message translates to:
  /// **'Save Live session summaries'**
  String get settingsSaveLiveSummaries;

  /// No description provided for @settingsSaveLiveSummariesBody.
  ///
  /// In en, this message translates to:
  /// **'When on, completed Live session summaries are saved on this device only. Turn off to stop saving new ones.'**
  String get settingsSaveLiveSummariesBody;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsDataBody.
  ///
  /// In en, this message translates to:
  /// **'Nemro stores settings and an optional camera baseline locally. Live session summaries are saved only when you turn that on.'**
  String get settingsDataBody;

  /// No description provided for @settingsDeleteData.
  ///
  /// In en, this message translates to:
  /// **'Delete all local data'**
  String get settingsDeleteData;

  /// No description provided for @settingsDeleteDataBody.
  ///
  /// In en, this message translates to:
  /// **'This removes settings, the camera baseline, saved Live sessions, and onboarding state.'**
  String get settingsDeleteDataBody;

  /// No description provided for @settingsDeleteDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all local data?'**
  String get settingsDeleteDataConfirm;

  /// No description provided for @settingsDeleteDataDone.
  ///
  /// In en, this message translates to:
  /// **'Local data cleared.'**
  String get settingsDeleteDataDone;

  /// No description provided for @settingsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settingsDelete;

  /// No description provided for @settingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get settingsLicenses;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Nemro'**
  String get aboutTitle;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Nemro is an open-source project for understanding the AI–brain loop: AI decoding neural signals, feeding back to the user, and the real limits of the technology.'**
  String get aboutBody;

  /// No description provided for @aboutDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get aboutDisclaimerTitle;

  /// No description provided for @aboutDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'Nemro is not a medical device, does not read minds, and is not a substitute for medical advice.'**
  String get aboutDisclaimerBody;

  /// No description provided for @aboutSources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get aboutSources;

  /// No description provided for @aboutSourceEeg.
  ///
  /// In en, this message translates to:
  /// **'PhysioNet EEG Motor Movement/Imagery Dataset'**
  String get aboutSourceEeg;

  /// No description provided for @aboutSourceModel.
  ///
  /// In en, this message translates to:
  /// **'On-device decoder'**
  String get aboutSourceModel;

  /// No description provided for @aboutSourcePlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get aboutSourcePlanned;

  /// No description provided for @aboutSourceBci.
  ///
  /// In en, this message translates to:
  /// **'BCI Competition IV 2a'**
  String get aboutSourceBci;

  /// No description provided for @aboutSourceNote.
  ///
  /// In en, this message translates to:
  /// **'The Lab bundles 60-second EEGMMIDB excerpts from S001, S002, and S003 (ODC-BY 1.0). The decoder is a small logistic regression trained on S001 runs 8 and 12 and evaluated on run 4: 67% held-out accuracy, 50% chance. The S002 and S003 replays are cross-subject demos with no accuracy claim. Research demo only.'**
  String get aboutSourceNote;

  /// No description provided for @aboutRepo.
  ///
  /// In en, this message translates to:
  /// **'Source on GitHub'**
  String get aboutRepo;

  /// No description provided for @aboutLicense.
  ///
  /// In en, this message translates to:
  /// **'MIT License'**
  String get aboutLicense;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyTitle;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Nemro is local-first. Version {version} has Internet permission. The bundled EEG sample, decoder, and Live camera proxy run entirely on-device.'**
  String privacyIntro(String version);

  /// No description provided for @privacyDataTitle.
  ///
  /// In en, this message translates to:
  /// **'What data is stored?'**
  String get privacyDataTitle;

  /// No description provided for @privacyDataBody.
  ///
  /// In en, this message translates to:
  /// **'Language, theme, onboarding state, camera lens preference, and an optional camera baseline range. Live session summaries are saved on this device only if you turn saving on in Settings, and deleting all data in Settings wipes them. The Lab decoder processes the bundled sample locally; no EEG is collected from you.'**
  String get privacyDataBody;

  /// No description provided for @privacyDecoderTitle.
  ///
  /// In en, this message translates to:
  /// **'On-device AI'**
  String get privacyDecoderTitle;

  /// No description provided for @privacyDecoderBody.
  ///
  /// In en, this message translates to:
  /// **'The Lab decoder is a small model bundled with the app. It runs locally on the EEG sample, and predictions never leave the device.'**
  String get privacyDecoderBody;

  /// No description provided for @privacyCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get privacyCameraTitle;

  /// No description provided for @privacyCameraBody.
  ///
  /// In en, this message translates to:
  /// **'Live opens the camera only after you tap Start. Frames are downsampled and processed on-device to estimate a rough light/contrast/motion proxy. No video or images are recorded, stored, or uploaded. An optional calibration baseline (two numbers) can be stored locally. The camera is released when you stop or leave the app.'**
  String get privacyCameraBody;

  /// No description provided for @privacyStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get privacyStorageTitle;

  /// No description provided for @privacyStorageBody.
  ///
  /// In en, this message translates to:
  /// **'Data lives in the app\'s private storage. You can delete everything in Settings.'**
  String get privacyStorageBody;

  /// No description provided for @privacySharingTitle.
  ///
  /// In en, this message translates to:
  /// **'Sharing'**
  String get privacySharingTitle;

  /// No description provided for @privacySharingBody.
  ///
  /// In en, this message translates to:
  /// **'No analytics, ads, or third-party data-collecting SDKs. The bundled decoder and camera proxy do not call a server.'**
  String get privacySharingBody;

  /// No description provided for @privacyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get privacyContactTitle;

  /// No description provided for @privacyContactBody.
  ///
  /// In en, this message translates to:
  /// **'Open an issue on the project\'s GitHub.'**
  String get privacyContactBody;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get commonComingSoon;

  /// No description provided for @commonLearnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get commonLearnMore;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonError;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @liveStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera signal proxy'**
  String get liveStartTitle;

  /// No description provided for @liveStartBody.
  ///
  /// In en, this message translates to:
  /// **'A rough, on-device proxy built from light, contrast, and motion. It is not mind reading and not a medical measurement.'**
  String get liveStartBody;

  /// No description provided for @liveStartBullet1.
  ///
  /// In en, this message translates to:
  /// **'The camera starts only when you tap Start.'**
  String get liveStartBullet1;

  /// No description provided for @liveStartBullet2.
  ///
  /// In en, this message translates to:
  /// **'Frames are processed on-device. No video is recorded or uploaded.'**
  String get liveStartBullet2;

  /// No description provided for @liveStartBullet3.
  ///
  /// In en, this message translates to:
  /// **'Stop anytime. The camera is released when the session ends.'**
  String get liveStartBullet3;

  /// No description provided for @liveStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start camera session'**
  String get liveStartButton;

  /// No description provided for @liveStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting camera…'**
  String get liveStarting;

  /// No description provided for @liveStartingBody.
  ///
  /// In en, this message translates to:
  /// **'If prompted, allow camera access. Nemro does not use the microphone.'**
  String get liveStartingBody;

  /// No description provided for @livePermissionHint.
  ///
  /// In en, this message translates to:
  /// **'If you permanently denied access, enable Camera for Nemro in Android Settings.'**
  String get livePermissionHint;

  /// No description provided for @liveOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get liveOpenSettings;

  /// No description provided for @liveCameraLabel.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get liveCameraLabel;

  /// No description provided for @liveCameraFront.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get liveCameraFront;

  /// No description provided for @liveCameraBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get liveCameraBack;

  /// No description provided for @livePreviewSemantics.
  ///
  /// In en, this message translates to:
  /// **'Live camera preview. Frames are processed on-device.'**
  String get livePreviewSemantics;

  /// No description provided for @liveLiveBadge.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get liveLiveBadge;

  /// No description provided for @liveScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Proxy score'**
  String get liveScoreTitle;

  /// No description provided for @liveScoreCaption.
  ///
  /// In en, this message translates to:
  /// **'Heuristic score from light, contrast, and stability. Not a measurement of thoughts.'**
  String get liveScoreCaption;

  /// No description provided for @liveScoreWarmingUp.
  ///
  /// In en, this message translates to:
  /// **'Calibrating…'**
  String get liveScoreWarmingUp;

  /// No description provided for @liveScoreWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for frames…'**
  String get liveScoreWaiting;

  /// No description provided for @liveScoreHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get liveScoreHigh;

  /// No description provided for @liveScoreMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get liveScoreMedium;

  /// No description provided for @liveScoreLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get liveScoreLow;

  /// No description provided for @liveLightLabel.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get liveLightLabel;

  /// No description provided for @liveStabilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Stability'**
  String get liveStabilityLabel;

  /// No description provided for @liveFramesLabel.
  ///
  /// In en, this message translates to:
  /// **'Frames analyzed'**
  String get liveFramesLabel;

  /// No description provided for @liveBaselineTitle.
  ///
  /// In en, this message translates to:
  /// **'Your baseline'**
  String get liveBaselineTitle;

  /// No description provided for @liveBaselineBody.
  ///
  /// In en, this message translates to:
  /// **'Calibrate once in your usual room and lighting. Later scores show relative to your usual range — still a camera proxy, never a brain measurement.'**
  String get liveBaselineBody;

  /// No description provided for @liveBaselineRange.
  ///
  /// In en, this message translates to:
  /// **'Usual range: {low}–{high}'**
  String liveBaselineRange(int low, int high);

  /// No description provided for @liveBaselineCalibrate.
  ///
  /// In en, this message translates to:
  /// **'Calibrate baseline'**
  String get liveBaselineCalibrate;

  /// No description provided for @liveBaselineRecalibrate.
  ///
  /// In en, this message translates to:
  /// **'Recalibrate'**
  String get liveBaselineRecalibrate;

  /// No description provided for @liveBaselineCapturing.
  ///
  /// In en, this message translates to:
  /// **'Calibrating… sit normally and stay in frame.'**
  String get liveBaselineCapturing;

  /// No description provided for @liveBaselineProgress.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 frame captured} other{{count} frames captured}}'**
  String liveBaselineProgress(int count);

  /// No description provided for @liveBaselineNeeds.
  ///
  /// In en, this message translates to:
  /// **'Needs at least {min} frames to save.'**
  String liveBaselineNeeds(int min);

  /// No description provided for @liveBaselineStopSave.
  ///
  /// In en, this message translates to:
  /// **'Stop and save baseline'**
  String get liveBaselineStopSave;

  /// No description provided for @liveBaselineCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel calibration'**
  String get liveBaselineCancel;

  /// No description provided for @liveBaselineSaved.
  ///
  /// In en, this message translates to:
  /// **'Baseline saved.'**
  String get liveBaselineSaved;

  /// No description provided for @liveBaselineClear.
  ///
  /// In en, this message translates to:
  /// **'Clear baseline'**
  String get liveBaselineClear;

  /// No description provided for @liveBaselineSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the baseline. Try again.'**
  String get liveBaselineSaveFailed;

  /// No description provided for @liveBaselineTooShort.
  ///
  /// In en, this message translates to:
  /// **'Not enough frames to set a baseline. Stay in frame a little longer and try again.'**
  String get liveBaselineTooShort;

  /// No description provided for @liveBaselineRelativeNote.
  ///
  /// In en, this message translates to:
  /// **'Relative to your usual range. Still a camera proxy, not a brain measurement.'**
  String get liveBaselineRelativeNote;

  /// No description provided for @liveBaselineAbsolute.
  ///
  /// In en, this message translates to:
  /// **'Absolute proxy score: {score}'**
  String liveBaselineAbsolute(int score);

  /// No description provided for @liveStopButton.
  ///
  /// In en, this message translates to:
  /// **'Stop session'**
  String get liveStopButton;

  /// No description provided for @livePrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Camera frames stay on this device. Nothing is recorded or uploaded.'**
  String get livePrivacyNote;

  /// No description provided for @liveSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Session summary'**
  String get liveSummaryTitle;

  /// No description provided for @liveSummaryAverage.
  ///
  /// In en, this message translates to:
  /// **'Average score'**
  String get liveSummaryAverage;

  /// No description provided for @liveSummaryDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get liveSummaryDuration;

  /// No description provided for @liveSummaryFrames.
  ///
  /// In en, this message translates to:
  /// **'Frames'**
  String get liveSummaryFrames;

  /// No description provided for @liveSummaryNoFrames.
  ///
  /// In en, this message translates to:
  /// **'No frames were analyzed. Check camera access and try again.'**
  String get liveSummaryNoFrames;

  /// No description provided for @liveSummaryPaused.
  ///
  /// In en, this message translates to:
  /// **'The session stopped when the app left the foreground.'**
  String get liveSummaryPaused;

  /// No description provided for @liveStartAgain.
  ///
  /// In en, this message translates to:
  /// **'Start again'**
  String get liveStartAgain;

  /// No description provided for @liveErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable'**
  String get liveErrorTitle;

  /// No description provided for @liveErrorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission was denied. Tap Retry to request it again.'**
  String get liveErrorPermissionDenied;

  /// No description provided for @liveErrorPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera access is blocked. Enable Camera for Nemro in Android Settings, then try again.'**
  String get liveErrorPermissionPermanentlyDenied;

  /// No description provided for @liveErrorRestricted.
  ///
  /// In en, this message translates to:
  /// **'Camera access is restricted on this device.'**
  String get liveErrorRestricted;

  /// No description provided for @liveErrorNoCamera.
  ///
  /// In en, this message translates to:
  /// **'No camera was found on this device.'**
  String get liveErrorNoCamera;

  /// No description provided for @liveErrorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not start the camera. Close other camera apps and try again.'**
  String get liveErrorUnavailable;

  /// No description provided for @liveScoreSemantics.
  ///
  /// In en, this message translates to:
  /// **'Camera proxy score: {score} out of 100'**
  String liveScoreSemantics(int score);

  /// No description provided for @labDecoderConfusionTitle.
  ///
  /// In en, this message translates to:
  /// **'Confusion matrix (rows = actual, columns = predicted)'**
  String get labDecoderConfusionTitle;

  /// No description provided for @homePracticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get homePracticeTitle;

  /// No description provided for @homePracticeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adaptive breathing paced by the camera signal'**
  String get homePracticeSubtitle;

  /// No description provided for @homePracticeAction.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get homePracticeAction;

  /// No description provided for @homePracticeBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get homePracticeBadge;

  /// No description provided for @practiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceTitle;

  /// No description provided for @practiceIntro.
  ///
  /// In en, this message translates to:
  /// **'A breathing session whose pace follows the camera signal. Sit in front of the camera, breathe with the circle, and let the exhale stretch when the signal is steady.'**
  String get practiceIntro;

  /// No description provided for @practiceHonestNote.
  ///
  /// In en, this message translates to:
  /// **'The pace follows a camera-signal heuristic, not a measure of calm, focus, or any medical state. Nothing is recorded or uploaded.'**
  String get practiceHonestNote;

  /// No description provided for @practiceDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Session length'**
  String get practiceDurationLabel;

  /// No description provided for @practiceMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String practiceMinutes(int minutes);

  /// No description provided for @practiceStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start practice'**
  String get practiceStartButton;

  /// No description provided for @practiceStopButton.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get practiceStopButton;

  /// No description provided for @practiceInhale.
  ///
  /// In en, this message translates to:
  /// **'Breathe in'**
  String get practiceInhale;

  /// No description provided for @practiceHold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get practiceHold;

  /// No description provided for @practiceExhale.
  ///
  /// In en, this message translates to:
  /// **'Breathe out'**
  String get practiceExhale;

  /// No description provided for @practiceRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get practiceRemaining;

  /// No description provided for @practiceSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice summary'**
  String get practiceSummaryTitle;

  /// No description provided for @practiceSummaryAverage.
  ///
  /// In en, this message translates to:
  /// **'Average proxy score'**
  String get practiceSummaryAverage;

  /// No description provided for @practiceSummaryDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get practiceSummaryDuration;

  /// No description provided for @practiceSummaryCycles.
  ///
  /// In en, this message translates to:
  /// **'Breathing cycles'**
  String get practiceSummaryCycles;

  /// No description provided for @practiceStartAgain.
  ///
  /// In en, this message translates to:
  /// **'Practice again'**
  String get practiceStartAgain;

  /// No description provided for @homeResearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Research'**
  String get homeResearchTitle;

  /// No description provided for @homeResearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Landmark findings and self-run camera experiments'**
  String get homeResearchSubtitle;

  /// No description provided for @homeResearchAction.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get homeResearchAction;

  /// No description provided for @homeResearchBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get homeResearchBadge;

  /// No description provided for @researchTitle.
  ///
  /// In en, this message translates to:
  /// **'Research'**
  String get researchTitle;

  /// No description provided for @researchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Four landmark findings, each with its limits and sources — plus two short experiments you can run on this device to see how the camera proxy behaves.'**
  String get researchSubtitle;

  /// No description provided for @researchHonestNote.
  ///
  /// In en, this message translates to:
  /// **'Nothing here measures attention, calm, or any medical state. The experiments describe a camera signal only.'**
  String get researchHonestNote;

  /// No description provided for @researchMilestonesTitle.
  ///
  /// In en, this message translates to:
  /// **'Landmark findings'**
  String get researchMilestonesTitle;

  /// No description provided for @researchExperimentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Self-run experiments'**
  String get researchExperimentsTitle;

  /// No description provided for @researchLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get researchLimitLabel;

  /// No description provided for @researchSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get researchSourceLabel;

  /// No description provided for @researchOpenSource.
  ///
  /// In en, this message translates to:
  /// **'Open source'**
  String get researchOpenSource;

  /// No description provided for @researchStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start experiment'**
  String get researchStartButton;

  /// No description provided for @researchStopButton.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get researchStopButton;

  /// No description provided for @researchResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Experiment result'**
  String get researchResultTitle;

  /// No description provided for @researchResultAverage.
  ///
  /// In en, this message translates to:
  /// **'Average proxy score'**
  String get researchResultAverage;

  /// No description provided for @researchResultStability.
  ///
  /// In en, this message translates to:
  /// **'Average stability'**
  String get researchResultStability;

  /// No description provided for @researchResultLighting.
  ///
  /// In en, this message translates to:
  /// **'Average lighting'**
  String get researchResultLighting;

  /// No description provided for @researchResultPresence.
  ///
  /// In en, this message translates to:
  /// **'Average presence'**
  String get researchResultPresence;

  /// No description provided for @researchResultNote.
  ///
  /// In en, this message translates to:
  /// **'This describes the camera signal during those 30 seconds only. It is not evidence about attention, calm, or any mental state.'**
  String get researchResultNote;

  /// No description provided for @researchRunAgain.
  ///
  /// In en, this message translates to:
  /// **'Run again'**
  String get researchRunAgain;

  /// No description provided for @researchBackToList.
  ///
  /// In en, this message translates to:
  /// **'Back to list'**
  String get researchBackToList;

  /// No description provided for @researchMilestone1Title.
  ///
  /// In en, this message translates to:
  /// **'1929 — The first human EEG'**
  String get researchMilestone1Title;

  /// No description provided for @researchMilestone1Body.
  ///
  /// In en, this message translates to:
  /// **'Hans Berger in Jena, Germany, recorded electrical activity from the human scalp and described the alpha rhythm (roughly 8–13 Hz, strongest at rest with eyes closed). It was the start of electroencephalography — and of every non-invasive brain recording that followed.'**
  String get researchMilestone1Body;

  /// No description provided for @researchMilestone1Limit.
  ///
  /// In en, this message translates to:
  /// **'Crude early equipment and a handful of first subjects; the finding was a beginning, not a validated clinical tool.'**
  String get researchMilestone1Limit;

  /// No description provided for @researchMilestone1Source.
  ///
  /// In en, this message translates to:
  /// **'Berger, H. (1929). Über das Elektrenkephalogramm des Menschen. Archiv für Psychiatrie und Nervenkrankheiten.'**
  String get researchMilestone1Source;

  /// No description provided for @researchMilestone2Title.
  ///
  /// In en, this message translates to:
  /// **'1988 — Spelling with the P300 wave'**
  String get researchMilestone2Title;

  /// No description provided for @researchMilestone2Body.
  ///
  /// In en, this message translates to:
  /// **'Farwell and Donchin showed that a person can pick letters on a screen by attention alone: the brain produces a P300 response about 300 ms after a rare, attended stimulus, and a computer can decode which letter was chosen. It was one of the first non-invasive BCIs with a practical use — assisted communication.'**
  String get researchMilestone2Body;

  /// No description provided for @researchMilestone2Limit.
  ///
  /// In en, this message translates to:
  /// **'Slow (a few characters per minute at the time), needs per-person calibration and training; it decodes a choice among shown options, not free-form thought.'**
  String get researchMilestone2Limit;

  /// No description provided for @researchMilestone2Source.
  ///
  /// In en, this message translates to:
  /// **'Farwell, L. A., & Donchin, E. (1988). Talking off the top of your head. Electroencephalography and Clinical Neurophysiology.'**
  String get researchMilestone2Source;

  /// No description provided for @researchMilestone3Title.
  ///
  /// In en, this message translates to:
  /// **'2004 — An open motor-imagery EEG dataset'**
  String get researchMilestone3Title;

  /// No description provided for @researchMilestone3Body.
  ///
  /// In en, this message translates to:
  /// **'The EEG Motor Movement/Imagery Dataset on PhysioNet recorded 109 people performing and imagining hand and foot movements (64 channels). It became an open standard for building and comparing decoders — Nemro\'s Lab replays three excerpts from it (S001, S002, and S003).'**
  String get researchMilestone3Body;

  /// No description provided for @researchMilestone3Limit.
  ///
  /// In en, this message translates to:
  /// **'Lab data from healthy volunteers following cues — far from everyday use; accuracy on this set says nothing about clinical effectiveness.'**
  String get researchMilestone3Limit;

  /// No description provided for @researchMilestone3Source.
  ///
  /// In en, this message translates to:
  /// **'PhysioNet EEG Motor Movement/Imagery Dataset (EEGMMIDB); Schalk et al., BCI2000 (2004).'**
  String get researchMilestone3Source;

  /// No description provided for @researchMilestone4Title.
  ///
  /// In en, this message translates to:
  /// **'2010 — Not everyone can drive a BCI'**
  String get researchMilestone4Title;

  /// No description provided for @researchMilestone4Body.
  ///
  /// In en, this message translates to:
  /// **'Work from the Berlin BCI group found that a substantial minority of users — often cited around 15–30% — never gain reliable control of a motor-imagery BCI despite training, a phenomenon called \'BCI illiteracy\'. BCI performance depends on the person, not just the technology.'**
  String get researchMilestone4Body;

  /// No description provided for @researchMilestone4Limit.
  ///
  /// In en, this message translates to:
  /// **'The share depends on how \'control\' is defined, the task, and training length; it does not mean those people\'s brains are in any way deficient.'**
  String get researchMilestone4Limit;

  /// No description provided for @researchMilestone4Source.
  ///
  /// In en, this message translates to:
  /// **'Blankertz, B., et al. (2010). Neurophysiological predictor of SMR-based BCI performance. NeuroImage.'**
  String get researchMilestone4Source;

  /// No description provided for @researchExperimentStillTitle.
  ///
  /// In en, this message translates to:
  /// **'Sit still for 30 seconds'**
  String get researchExperimentStillTitle;

  /// No description provided for @researchExperimentStillBody.
  ///
  /// In en, this message translates to:
  /// **'Sit in front of the camera and stay as still as you can for 30 seconds. Watch what happens to the stability component and the score.'**
  String get researchExperimentStillBody;

  /// No description provided for @researchExperimentStillReading.
  ///
  /// In en, this message translates to:
  /// **'If you sat still, stability usually rises and the score rises with it. That shows the score reacts to movement — not to focus, calm, or effort.'**
  String get researchExperimentStillReading;

  /// No description provided for @researchExperimentCoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Cover the lens, then uncover it'**
  String get researchExperimentCoverTitle;

  /// No description provided for @researchExperimentCoverBody.
  ///
  /// In en, this message translates to:
  /// **'Start the run, cover the camera with your hand for a few seconds, then uncover it. Watch what happens to the presence component and the score.'**
  String get researchExperimentCoverBody;

  /// No description provided for @researchExperimentCoverReading.
  ///
  /// In en, this message translates to:
  /// **'Covering the lens collapses central contrast, so presence and the score fall with it — no change in mental state needed. The score follows the image it is given.'**
  String get researchExperimentCoverReading;

  /// No description provided for @labDecoderModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Decoder'**
  String get labDecoderModelLabel;

  /// No description provided for @labDecoderModelLogistic.
  ///
  /// In en, this message translates to:
  /// **'Logistic'**
  String get labDecoderModelLogistic;

  /// No description provided for @labDecoderModelCentroid.
  ///
  /// In en, this message translates to:
  /// **'Centroid'**
  String get labDecoderModelCentroid;

  /// No description provided for @labDecoderModelCentroidLine.
  ///
  /// In en, this message translates to:
  /// **'Nearest centroid · mu/beta power · {count} channels'**
  String labDecoderModelCentroidLine(Object count);

  /// No description provided for @labDecoderTrainingInSample.
  ///
  /// In en, this message translates to:
  /// **'Trained on the replay itself ({train}); no held-out run.'**
  String labDecoderTrainingInSample(Object train);

  /// No description provided for @labDecoderAccuracyInSample.
  ///
  /// In en, this message translates to:
  /// **'In-sample accuracy: {percent}% (chance 50%)'**
  String labDecoderAccuracyInSample(Object percent);

  /// No description provided for @labDecoderInSampleNote.
  ///
  /// In en, this message translates to:
  /// **'In-sample accuracy flatters the model: it was tested on the very windows it learned from, so it cannot be compared with held-out accuracy.'**
  String get labDecoderInSampleNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
