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
  /// **'Replay real EEG, watch an on-device decoder estimate the imagined hand, and try a camera-based attention proxy.'**
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
  /// **'Camera attention proxy'**
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

  /// No description provided for @labDecoderAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Held-out accuracy: {percent}% (chance 50%)'**
  String labDecoderAccuracy(int percent);

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
  /// **'S001 · run 4 · imagined left/right fist'**
  String get labRunDescription;

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

  /// No description provided for @learnComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Bilingual lessons arrive in S3.'**
  String get learnComingSoon;

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
  /// **'Nemro stores settings locally. Live session summaries are saved only when you turn that on.'**
  String get settingsDataBody;

  /// No description provided for @settingsDeleteData.
  ///
  /// In en, this message translates to:
  /// **'Delete all local data'**
  String get settingsDeleteData;

  /// No description provided for @settingsDeleteDataBody.
  ///
  /// In en, this message translates to:
  /// **'This removes settings, language choice, and onboarding state.'**
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
  /// **'The Lab bundles a 60-second EEGMMIDB excerpt (ODC-BY 1.0). Its decoder is a small logistic regression trained on S001 runs 8 and 12 and evaluated on run 4: 67% held-out accuracy, 50% chance. Research demo only.'**
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
  /// **'Nemro is local-first. Version 0.3.0 has no Internet permission. The bundled EEG sample, decoder, and Live camera proxy run entirely on-device.'**
  String get privacyIntro;

  /// No description provided for @privacyDataTitle.
  ///
  /// In en, this message translates to:
  /// **'What data is stored?'**
  String get privacyDataTitle;

  /// No description provided for @privacyDataBody.
  ///
  /// In en, this message translates to:
  /// **'Language, theme, and onboarding state. Live session summaries are shown on screen but are not saved in 0.3.0. The Lab decoder processes the bundled sample locally; no EEG is collected from you.'**
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
  /// **'Live opens the camera only after you tap Start. Frames are downsampled and processed on-device to estimate a rough light/contrast/motion proxy. No video or images are recorded, stored, or uploaded. The camera is released when you stop or leave the app; Nemro does not request microphone or storage access.'**
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
  /// **'Camera attention proxy'**
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
  /// **'Attention proxy score: {score} out of 100'**
  String liveScoreSemantics(int score);
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
