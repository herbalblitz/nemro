# Nemro

**The AI–brain loop, in your hands.**

Nemro is a free, open-source Android app for exploring how AI and the brain can meet without expensive EEG hardware. It is built with Flutter, works offline, and is bilingual **Vietnamese–English**.

> Nemro is not a medical device. It does not read minds. It is an educational and experimental project.

[![CI](https://github.com/herbalblitz/nemro/actions/workflows/ci.yml/badge.svg)](https://github.com/herbalblitz/nemro/actions/workflows/ci.yml)

## Status

**S1 — Lab replay + on-device decoder.** The app shell, onboarding, bilingual UI, navigation, settings, and privacy surfaces are in place. The Lab replays a real 60-second EEG window from PhysioNet, shows its task markers, and runs a small logistic-regression decoder entirely on-device. On the held-out run that supplies the replay excerpt, it scores 66.7% (10/15; chance 50%); it is a research demo, not a BCI product.

| Milestone | Scope | Status |
| --- | --- | --- |
| S0 | Flutter scaffold, vi/en l10n, onboarding, navigation, settings, CI | Done |
| S1 | Lab: replay public EEG, run an AI decoder on-device, show real charts | Done |
| S2 | Live: camera-based attention proxy, entirely on-device | Planned |
| S3 | Learn: bilingual lessons; Insights: local session history | Planned |
| S4 | Polish, accessibility, release build, store-ready docs | Planned |

## What works now

- First-launch language choice (Tiếng Việt / English) and a clear consent screen.
- Material 3 light and dark themes, selectable in Settings.
- Home with Lab and Live entry points, Insights, Learn, and Settings tabs.
- Lab replay of a real 60-second EEG window from EEGMMIDB (S001/R04, 8 channels, 160 Hz) with rest/left/right task markers, play/pause, scrubbing, and speed controls.
- On-device decoder: 4 sensorimotor channels, mu/beta power, logistic regression, 66.7% held-out accuracy on S001/R04 (chance 50%). The Lab shows the prediction, class probabilities, and the known marker side by side.
- Reproducible training tool (`tool/train_eeg_decoder.py`) and a full model card (`docs/model-card.md`).
- Dataset and ODC-BY 1.0 attribution in the Lab and About screens.
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
- Bundled, locally parsed EEG excerpt (ODC-BY 1.0) and a pure-Dart logistic-regression model (MIT); no network access
- GitHub Actions for CI and release APK builds

Future milestones add `drift` (local sessions), `camera`, and `google_mlkit_face_detection`. Dataset and model rules are documented in [docs/data-sources.md](docs/data-sources.md); the bundled model is described in [docs/model-card.md](docs/model-card.md).

## Decoder

The Lab's decoder is a binary logistic regression over mu/beta band power from
four sensorimotor channels (C3, C4, CP3, CP4). It was trained on EEGMMIDB S001
runs 8 and 12 and evaluated on the held-out run 4, the same run used for the
replay. Held-out accuracy is **66.7%** (10/15 trials; chance 50%); the
leave-one-run-out mean is 60.0%. The 60-second replay is a seven-task subset of
that held-out run, so the 66.7% figure is for all 15 trials, not the excerpt.
The model and EEG excerpt are bundled, and inference is pure Dart on-device.

This is a small, honest baseline, not a medical device or a mind reader. Read
[`docs/model-card.md`](docs/model-card.md) for the confusion matrix, calibration
caveats, and limitations. Regenerate the weights with:

```bash
python3 tool/train_eeg_decoder.py \
  --data-dir /path/to/S001 \
  --out assets/models/eeg_decoder.json
```

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
    lab/             EEG replay + on-device decoder
    live/            camera attention placeholder
    insights/        session history placeholder
    learn/           bilingual lessons placeholder
    settings/        language, theme, privacy, data, about
    about/           project and disclaimer
    privacy/         local privacy policy
```

## Privacy

Nemro is local-first. The release build has no `INTERNET` permission, no accounts, no ads, and no tracking. Settings stay in the app's private storage. The Lab decoder is bundled and runs on-device; predictions never leave the phone. Future camera frames will be processed on-device and never recorded. See [docs/privacy.md](docs/privacy.md) for the full policy.

Debug builds add the `INTERNET` permission through Flutter's debug manifest for hot reload; release builds do not.

## Contributing

Issues and pull requests are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) and keep the project's honesty rule: no fake mind-reading claims, no medical claims, and no hidden data collection.

## License

MIT — see [LICENSE](LICENSE).

---

## Tiếng Việt

**Nemro** là ứng dụng Android mã nguồn mở, miễn phí, giúp bạn khám phá vòng lặp AI–não mà không cần thiết bị EEG đắt tiền. Ứng dụng chạy offline, song ngữ Việt–Anh.

> Nemro không phải thiết bị y tế, không đọc suy nghĩ và không thay thế tư vấn y tế.

Hiện tại là mốc **S1**: khung ứng dụng, onboarding, giao diện song ngữ, điều hướng, cài đặt và chính sách riêng tư đã có. Lab phát lại EEG thật và chạy bộ giải mã logistic nhỏ ngay trên thiết bị; độ chính xác trên run giữ lại là 66,7% (mức ngẫu nhiên 50%). Live vẫn là placeholder trung thực cho mốc tiếp theo. Xem [`docs/model-card.md`](docs/model-card.md).

Bộ giải mã dùng 4 kênh C3, C4, CP3, CP4, đặc trưng công suất mu/beta, huấn luyện trên run 8 và 12 của S001, đánh giá trên run 4. Mô hình và mẫu EEG đi kèm ứng dụng; suy luận chạy hoàn toàn trên thiết bị.

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
