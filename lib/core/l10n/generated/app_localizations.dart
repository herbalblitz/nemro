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
  /// **'Camera frames are processed on-device and never recorded.'**
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
  /// **'Watch AI decode real EEG, track attention, and learn what BCI can really do.'**
  String get homeSubheadline;

  /// No description provided for @homeLabTitle.
  ///
  /// In en, this message translates to:
  /// **'Lab'**
  String get homeLabTitle;

  /// No description provided for @homeLabSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI reads real EEG'**
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
  /// **'Track attention'**
  String get homeLiveSubtitle;

  /// No description provided for @homeLiveAction.
  ///
  /// In en, this message translates to:
  /// **'Enable camera'**
  String get homeLiveAction;

  /// No description provided for @homeLiveBadge.
  ///
  /// In en, this message translates to:
  /// **'SOON'**
  String get homeLiveBadge;

  /// No description provided for @homeRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Latest session'**
  String get homeRecentTitle;

  /// No description provided for @homeRecentEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet. Start with Live.'**
  String get homeRecentEmpty;

  /// No description provided for @homeRecentAction.
  ///
  /// In en, this message translates to:
  /// **'Start Live'**
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

  /// No description provided for @labComingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'The EEG demo is being built'**
  String get labComingSoonTitle;

  /// No description provided for @labComingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'S1 brings real EEG data, an AI model, and brainwave charts here.'**
  String get labComingSoonBody;

  /// No description provided for @labBadge.
  ///
  /// In en, this message translates to:
  /// **'SOON'**
  String get labBadge;

  /// No description provided for @liveTitle.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get liveTitle;

  /// No description provided for @liveComingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Attention tracking is being built'**
  String get liveComingSoonTitle;

  /// No description provided for @liveComingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'S2 uses the camera to estimate attention and fatigue, entirely on-device.'**
  String get liveComingSoonBody;

  /// No description provided for @liveBadge.
  ///
  /// In en, this message translates to:
  /// **'SOON'**
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

  /// No description provided for @insightsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Live and Lab sessions will appear here.'**
  String get insightsEmptyBody;

  /// No description provided for @insightsStart.
  ///
  /// In en, this message translates to:
  /// **'Start Live'**
  String get insightsStart;

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

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsDataBody.
  ///
  /// In en, this message translates to:
  /// **'Nemro stores settings locally. Sessions will be added in later versions.'**
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

  /// No description provided for @aboutSourceBci.
  ///
  /// In en, this message translates to:
  /// **'BCI Competition IV 2a'**
  String get aboutSourceBci;

  /// No description provided for @aboutSourceNote.
  ///
  /// In en, this message translates to:
  /// **'Data sources are credited in the docs and in the app.'**
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
  /// **'Nemro is local-first. Version 0.1.0 has no Internet permission and sends no data off the device.'**
  String get privacyIntro;

  /// No description provided for @privacyDataTitle.
  ///
  /// In en, this message translates to:
  /// **'What data is stored?'**
  String get privacyDataTitle;

  /// No description provided for @privacyDataBody.
  ///
  /// In en, this message translates to:
  /// **'Language, theme, and onboarding state. Lab and Live sessions will be stored locally when added in later versions.'**
  String get privacyDataBody;

  /// No description provided for @privacyCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get privacyCameraTitle;

  /// No description provided for @privacyCameraBody.
  ///
  /// In en, this message translates to:
  /// **'When Live is enabled, the camera processes frames on-device to estimate attention. No video is stored or sent.'**
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
  /// **'No analytics, ads, or third-party data-collecting SDKs.'**
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
