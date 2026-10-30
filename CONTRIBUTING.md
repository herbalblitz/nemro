# Contributing to Nemro

Thanks for helping build an honest, local-first AI–brain loop app.

## Ground rules

- **No fake mind reading.** EEG and camera signals are noisy proxies. Do not describe them as thoughts, intentions, or diagnoses.
- **No medical claims.** Nemro is not a medical device and must not be presented as one.
- **No hidden collection.** Do not add analytics, ads, accounts, or remote logging. Keep the release build offline.
- **Credit data and models.** Every dataset, model, and paper used by the app must be documented with its source and license.

## Setup

Prerequisites: Flutter 3.47+ (stable), Android SDK 36, Java 17.

```bash
flutter pub get
flutter gen-l10n
flutter run
```

Run checks before opening a pull request:

```bash
dart format --output=none --set-exit-if-changed \
  $(find lib test tool -name '*.dart' -not -path 'lib/core/l10n/generated/*')
flutter analyze --fatal-infos
flutter test
```

## Localization

- Add or change strings in both `lib/core/l10n/app_en.arb` and `lib/core/l10n/app_vi.arb`.
- Run `flutter gen-l10n` after changing ARB files.
- Keep keys descriptive and stable. Do not concatenate translated strings.
- Vietnamese and English must have the same set of keys; `test/l10n_keys_test.dart` checks this.

## Code style

- Follow `flutter_lints` and the formatting produced by `dart format`.
- Prefer small widgets and feature-local files.
- Use Riverpod for app state and `go_router` for navigation.
- Keep the release manifest free of `INTERNET` and other unnecessary permissions.

## Pull requests

A good PR:

1. explains the user-visible change and why it is honest;
2. includes tests for behavior changes;
3. passes `dart format`, `flutter analyze --fatal-infos`, and `flutter test`;
4. updates docs when privacy, data, models, or permissions change;
5. keeps the UI bilingual.

## Commit messages

Use a short imperative subject, for example:

```text
Add EEG replay screen skeleton
Fix Vietnamese onboarding title
Document model license
```

## Reporting issues

Use GitHub Issues. For security or privacy problems, follow [SECURITY.md](SECURITY.md) instead of opening a public issue.

By participating, you agree to follow [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
