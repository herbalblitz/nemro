# Nemro

**The AI–brain loop, in your hands.**

Nemro is a free, open-source Android app for exploring how AI and the brain can meet without expensive EEG hardware. It is built with Flutter, works offline, and is bilingual **Vietnamese–English**.

> Nemro is not a medical device. It does not read minds. It is an educational and experimental project.

[![CI](https://github.com/herbalblitz/nemro/actions/workflows/ci.yml/badge.svg)](https://github.com/herbalblitz/nemro/actions/workflows/ci.yml)

## Status

**S0 — Foundation.** The app shell, onboarding, bilingual UI, navigation, settings, and privacy surfaces are in place. Lab and Live are honest placeholders for the next milestones.

| Milestone | Scope | Status |
| --- | --- | --- |
| S0 | Flutter scaffold, vi/en l10n, onboarding, navigation, settings, CI | Done |
| S1 | Lab: replay public EEG, run an AI decoder on-device, show real charts | Next |
| S2 | Live: camera-based attention proxy, entirely on-device | Planned |
| S3 | Learn: bilingual lessons; Insights: local session history | Planned |
| S4 | Polish, accessibility, release build, store-ready docs | Planned |

## What works now

- First-launch language choice (Tiếng Việt / English) and a clear consent screen.
- Material 3 light and dark themes, selectable in Settings.
- Home with Lab and Live entry points, Insights, Learn, and Settings tabs.
- Privacy policy and open-source license screens inside the app.
- Local settings stored with `shared_preferences`; no account, ads, or analytics.
- No `INTERNET` permission in the release manifest.
- CI that analyzes, tests, and builds a release APK on GitHub Actions.

## What Nemro is not

- Not a medical device, diagnosis tool, or therapy.
- Not a mind reader. EEG and camera signals are noisy proxies, not thoughts.
- Not a cloud service. The app is local-first by design.

## Why "AI in the loop"?

A real brain–computer interface needs a signal, a decoder, and feedback. Consumer EEG is expensive and noisy; camera-based attention estimation is limited. Nemro makes the **loop** visible with public data and on-device AI, so you can see what the technology can and cannot do.

## Tech

- Flutter / Dart, Android-first
- Material 3 via `material_ui`
- `go_router` for navigation
- Riverpod for state
- `shared_preferences` for local settings
- `flutter_localizations` + ARB files for vi/en
- GitHub Actions for CI and release APK builds

Future milestones add `drift` (local sessions), `tflite_flutter` (on-device models), `camera`, and `google_mlkit_face_detection`. Dataset and model rules are documented in [docs/data-sources.md](docs/data-sources.md).

## Build

Prerequisites: Flutter 3.47+ (stable), Android SDK 36, Java 17.

```bash
flutter pub get
flutter gen-l10n
flutter run
```

Build a debug APK:

```bash
flutter build apk --debug
```

Debug APKs are large because they bundle every ABI and the debug Flutter engine. For a small installable build, use:

```bash
flutter build apk --release
```

Until a release keystore is configured, release builds are signed with the debug key. The CI workflow uploads `nemro-release-apk` from the **Actions** tab, which is useful when you do not have a local Android toolchain.

The Android implementation of `shared_preferences` is pinned to 2.4.28. Version 2.5+ pulls in `package:jni`, which requires the Android NDK and CMake at build time; Nemro has no native code, so the pure-Kotlin implementation keeps builds simple.

### ARM64 Linux note

Google ships the Android build-tools `aapt2` binary for x86_64 only. On an ARM64 Linux host, install the matching ARM64 build tools from [Commit451/android-arm-build-tools](https://github.com/Commit451/android-arm-build-tools) and point Gradle at the binary in your user-level `~/.gradle/gradle.properties`:

```properties
android.aapt2FromMavenOverride=/path/to/android-sdk/build-tools/36.0.0/aapt2
```

The project's CI runs on x64 and does not need this override.

## Project structure

```text
lib/
  core/
    constants/       app constants and preference keys
    l10n/            ARB source files and generated localizations
    preferences/     SharedPreferences-backed Riverpod providers
    router/          go_router configuration
    theme/           Material 3 light/dark themes
    widgets/         shared UI components
  features/
    onboarding/      language + consent
    shell/           bottom navigation shell
    home/            landing screen
    lab/             EEG demo placeholder
    live/            camera attention placeholder
    insights/        session history placeholder
    learn/           bilingual lessons placeholder
    settings/        language, theme, privacy, data, about
    about/           project and disclaimer
    privacy/         local privacy policy
```

## Privacy

Nemro is local-first. The release build has no `INTERNET` permission, no accounts, no ads, and no tracking. Settings stay in the app's private storage. Future camera frames will be processed on-device and never recorded. See [docs/privacy.md](docs/privacy.md) for the full policy.

Debug builds add the `INTERNET` permission through Flutter's debug manifest for hot reload; release builds do not.

## Contributing

Issues and pull requests are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) and keep the project's honesty rule: no fake mind-reading claims, no medical claims, and no hidden data collection.

## License

MIT — see [LICENSE](LICENSE).

---

## Tiếng Việt

**Nemro** là ứng dụng Android mã nguồn mở, miễn phí, giúp bạn khám phá vòng lặp AI–não mà không cần thiết bị EEG đắt tiền. Ứng dụng chạy offline, song ngữ Việt–Anh.

> Nemro không phải thiết bị y tế, không đọc suy nghĩ và không thay thế tư vấn y tế.

Hiện tại là mốc **S0**: khung ứng dụng, onboarding, giao diện song ngữ, điều hướng, cài đặt và chính sách riêng tư. Lab và Live là placeholder trung thực cho các mốc tiếp theo.

Chạy thử:

```bash
flutter pub get
flutter gen-l10n
flutter run
```

Tạo APK debug:

```bash
flutter build apk --debug
```

Tạo APK release nhỏ gọn hơn:

```bash
flutter build apk --release
```

APK release hiện được ký bằng debug key cho đến khi cấu hình keystore chính thức. CI cũng tạo và tải lên `nemro-release-apk` trong tab **Actions** của GitHub. Dữ liệu chỉ nằm trên thiết bị; bản release không có quyền `INTERNET`, không tài khoản, không quảng cáo, không tracking. Xem [docs/privacy.md](docs/privacy.md).
