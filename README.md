# Nemro

**The AI–brain loop, in your hands.**

Nemro is a free, open-source Android app for exploring how AI and the brain can meet without expensive EEG hardware. It is built with Flutter, works offline, and is bilingual **Vietnamese–English**.

> Nemro is not a medical device. It does not read minds. It is an educational and experimental project.

[![CI](https://github.com/herbalblitz/nemro/actions/workflows/ci.yml/badge.svg)](https://github.com/herbalblitz/nemro/actions/workflows/ci.yml)

## Status

**S4 — Polish, accessibility, release build, store-ready docs (0.5.0).** The Lab replays three real 60-second EEG windows from PhysioNet (S001, S002, and S003) and runs a small logistic-regression decoder entirely on-device. On the held-out S001 run it scores 66.7% (10/15; chance 50%; 95% Wilson interval 41.7%–84.8%). The S002 and S003 replays are labelled as cross-subject demos and never borrow S001's accuracy. Live opens the camera only after **Start** and turns a downsampled luminance stream into a transparent 0–100 light/contrast/stability proxy. It does not detect faces, eyes, or attention, and it does not record or upload frames. Insights can keep opt-in session summaries, show weekly trends and streaks, delete one session, or export CSV. A personal camera baseline can be saved or cleared at any time. Practice adds an adaptive breathing session paced by the camera proxy, and Research adds four landmark findings plus two self-run camera experiments; the Lab also offers a second, centroid decoder for comparison.

| Milestone | Scope | Status |
| --- | --- | --- |
| S0 | Flutter scaffold, vi/en l10n, onboarding, navigation, settings, CI | Done |
| S1 | Lab: replay public EEG, run an AI decoder on-device, show real charts | Done |
| S2 | Live: camera signal proxy, entirely on-device | Done |
| S3 | Learn: bilingual lessons; Insights: local session history, trends, export | Done |
| S4 | Polish, accessibility, release build, store-ready docs | In progress |

Live is covered by analyzer and widget tests with a fake camera gateway. A physical Android camera smoke test is still pending before the camera path is treated as device-validated.

## What works now

- First-launch language choice (Tiếng Việt / English) and a clear consent screen.
- Material 3 light and dark themes, selectable in Settings.
- Home with Lab and Live entry points, Insights, Learn, and Settings tabs.
- Lab replay of three real 60-second EEG windows from EEGMMIDB (S001/R04, S002/R04, and S003/R04, 8 channels, 160 Hz) with rest/left/right task markers, play/pause, scrubbing, and speed controls.
- On-device decoder: 4 sensorimotor channels, mu/beta power, logistic regression, 66.7% held-out accuracy on S001/R04 (chance 50%; 95% CI 41.7%–84.8%). The Lab shows the prediction, class probabilities, the known marker, the leave-one-run-out mean, and the confidence interval side by side. Selecting S002 or S003 switches to a clearly labelled cross-subject demo instead of reusing S001's score. A second decoder (nearest centroid, same features, trained on the excerpt itself) can be selected for comparison; its accuracy is labelled in-sample, never held-out.
- Live camera signal proxy: camera permission is requested only after **Start**; the front camera is preferred with a fallback. A 3-frame warmup and smoothed 0–100 score combine central contrast, lighting, and frame-to-frame stability. The screen shows the preview, score, light/stability bars, an optional personal baseline, and a session summary.
- Live frames are processed on-device and are never recorded, stored, or uploaded. The camera is released on **Stop** or when the app leaves the foreground.
- Practice: an adaptive breathing session (1/3/5 minutes) whose exhale length follows the camera signal proxy in real time. The camera opens only after **Start**, the summary stays on screen only, and the screen states that the pace is not a measure of calm, focus, or any medical state.
- Research: four landmark BCI findings with limits and sources, plus two self-run 30-second camera experiments whose results stay on screen only.
- Insights: opt-in saved Live session summaries, weekly averages, current/longest streak, per-session delete with confirmation, and CSV export through the system share sheet.
- Settings can clear the personal camera baseline or delete all local data, including the baseline and saved summaries.
- Reproducible training tool (`tool/train_eeg_decoder.py`) and a full model card (`docs/model-card.md`) with confidence intervals, LORO folds, and limitations.
- Dataset and ODC-BY 1.0 attribution in the Lab and About screens.
- Privacy policy and open-source license screens inside the app.
- Local settings stored with `shared_preferences`; no account, ads, or analytics.
- Release manifest requests `CAMERA` for Live but has no `INTERNET`, `RECORD_AUDIO`, storage, or media-library permission. Android cloud backup and device-to-device transfer are both disabled.
- CI that checks formatting, analyzes with `--fatal-infos`, tests, builds a release APK on GitHub Actions, and asserts the release permission set.

## What Nemro is not

- Not a medical device, diagnosis tool, or therapy.
- Not a mind reader. EEG and camera signals are noisy proxies, not thoughts.
- Not a cloud service. The app is local-first by design.

## Why "AI in the loop"?

A real brain–computer interface needs a signal, a decoder, and feedback. Consumer EEG is expensive and noisy; camera-based signal proxies are limited. Nemro makes the **loop** visible with public data and on-device AI, so you can see what the technology can and cannot do.

## Tech

- Flutter / Dart, Android-first
- Material 3 via `material_ui`
- `go_router` for navigation
- Riverpod for state
- `shared_preferences` for local settings
- `flutter_localizations` + ARB files for vi/en
- `camera` / CameraX for the Live preview and YUV frames; a small pure-Dart analyzer computes the proxy on-device
- Bundled, locally parsed EEG excerpt (ODC-BY 1.0) and a pure-Dart logistic-regression model (MIT); no network access
- GitHub Actions for CI and release APK builds

Session history stays in `shared_preferences` (a capped JSON list), so the app still has no native database dependency. Nemro does not use ML Kit, face detection, or eye tracking. Dataset and model rules are documented in [docs/data-sources.md](docs/data-sources.md); the bundled model is described in [docs/model-card.md](docs/model-card.md).

## Decoder

The Lab's decoder is a binary logistic regression over mu/beta band power from
four sensorimotor channels (C3, C4, CP3, CP4). It was trained on EEGMMIDB S001
runs 8 and 12 and evaluated on the held-out run 4, the same run used for the
replay. Held-out accuracy is **66.7%** (10/15 trials; chance 50%); the
leave-one-run-out mean is 60.0%, and the 95% Wilson interval for the held-out
result is **41.7%–84.8%** (one-sided binomial p ≈ 0.15). The 60-second replay is
a seven-task subset of that held-out run, so the 66.7% figure is for all 15
trials, not the excerpt. The S002 replay is a cross-subject demo: the model was
not trained or evaluated on S002, and the Lab says so instead of showing S001's
score. The model and EEG excerpts are bundled, and inference is pure Dart
on-device.

This is a small, honest baseline, not a medical device or a mind reader. Read
[`docs/model-card.md`](docs/model-card.md) for the confusion matrix, confidence
interval, calibration caveats, and limitations. Regenerate the weights with:

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

Until a release keystore is configured, release builds are signed with the debug key. To configure a real release key locally or in GitHub Actions, see [docs/release-signing.md](docs/release-signing.md). The CI workflow uploads `nemro-release-apk` from the **Actions** tab, which is useful when you do not have a local Android toolchain.

The Android implementation of `shared_preferences` is pinned to 2.4.28. Version 2.5+ pulls in `package:jni`, which adds another NDK/CMake build path. Nemro's own Dart code has no native component; keeping the pure-Kotlin implementation avoids that extra build dependency.

### ARM64 Linux note

Google ships the Android build-tools `aapt2` binary for x86_64 only. On an ARM64 Linux host, install the matching ARM64 build tools from [Commit451/android-arm-build-tools](https://github.com/Commit451/android-arm-build-tools) and point Gradle at the binary in your user-level `~/.gradle/gradle.properties`:

```properties
android.aapt2FromMavenOverride=/path/to/android-sdk/build-tools/36.0.0/aapt2
```

The project's CI runs on x64 and does not need this override.

The Android NDK's Linux host tools are x86_64-only. If the Flutter/Gradle toolchain invokes its synthetic CMake step, local APK builds on ARM64 fail even though Nemro's Dart code has no native component. Use the CI artifact or an x64 host for APK builds.

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
    live/            camera proxy + on-device frame analyzer
    insights/        saved sessions, trends, per-session delete, CSV export
    learn/           bilingual lessons
    settings/        language, theme, privacy, data, about
    about/           project and disclaimer
    privacy/         local privacy policy
```

## Privacy

Nemro is local-first. The release build has no `INTERNET` permission, no accounts, no ads, and no tracking. Settings stay in the app's private storage. The Lab decoder is bundled and runs on-device; predictions never leave the phone.

Live adds only the `CAMERA` runtime permission. The camera opens only after you tap **Start**; frames are analyzed in memory and are never recorded or uploaded. The camera plugin's microphone, storage, and media-library permissions are removed from the manifest. The camera is released on **Stop** or when the app leaves the foreground. Live session summaries are off by default and saved only if you enable saving in Settings; an optional personal camera baseline stores two numbers locally. Both are included in **Delete all local data**. Android cloud backup and device-to-device transfer are disabled. See [docs/privacy.md](docs/privacy.md) for the full policy.

Debug builds add the `INTERNET` permission through Flutter's debug manifest for hot reload; release builds do not.

## Contributing

Issues and pull requests are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) and keep the project's honesty rule: no fake mind-reading claims, no medical claims, and no hidden data collection.

## License

MIT — see [LICENSE](LICENSE).

---

## Tiếng Việt

**Nemro** là ứng dụng Android mã nguồn mở, miễn phí, giúp bạn khám phá vòng lặp AI–não mà không cần thiết bị EEG đắt tiền. Ứng dụng chạy offline, song ngữ Việt–Anh.

> Nemro không phải thiết bị y tế, không đọc suy nghĩ và không thay thế tư vấn y tế.

Hiện tại là mốc **S4** (phiên bản 0.5.0): khung ứng dụng, onboarding, giao diện song ngữ, điều hướng, cài đặt và chính sách riêng tư đã có. Lab phát lại ba đoạn EEG thật (S001, S002 và S003) và chạy bộ giải mã logistic nhỏ ngay trên thiết bị; độ chính xác trên run giữ lại của S001 là 66,7% (mức ngẫu nhiên 50%; khoảng tin cậy Wilson 95%: 41,7%–84,8%). Chọn S002 hoặc S003 sẽ hiện nhãn demo cross-subject thay vì dùng điểm của S001. Live mở camera chỉ sau khi bạn nhấn **Bắt đầu** và biến luồng độ sáng đã thu nhỏ thành proxy 0–100 từ độ tương phản, ánh sáng và độ ổn định. Live không nhận diện khuôn mặt, mắt hay chú ý và không ghi hoặc tải khung hình lên. Insights lưu tóm tắt phiên khi bạn bật tính năng, hiển thị xu hướng tuần, chuỗi ngày, xóa từng phiên và xuất CSV. Luyện tập thêm buổi thở thích ứng theo tín hiệu camera, và Nghiên cứu thêm bốn phát hiện mốc cùng hai thí nghiệm tự chạy bằng camera; Lab cũng có thêm bộ giải mã centroid thứ hai để so sánh. Phần camera đã có kiểm thử phân tích/UI với camera giả; kiểm thử trên thiết bị thật vẫn đang chờ. Xem [`docs/model-card.md`](docs/model-card.md).

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

APK release hiện được ký bằng debug key cho đến khi cấu hình keystore chính thức. CI cũng tạo và tải lên `nemro-release-apk` trong tab **Actions** của GitHub. Trên Linux ARM64, công cụ NDK x86_64 có thể khiến build APK cục bộ thất bại; hãy dùng artifact CI hoặc máy x64.

Dữ liệu chỉ nằm trên thiết bị; bản release không có quyền `INTERNET`, không tài khoản, không quảng cáo, không tracking. Live chỉ yêu cầu quyền runtime `CAMERA`; các quyền micro, bộ nhớ và thư viện media do plugin camera khai báo hoặc suy ra đều bị loại bỏ khỏi manifest. Camera chỉ mở sau khi nhấn **Bắt đầu**, khung hình được xử lý trong bộ nhớ và không bị ghi hay tải lên. Tóm tắt phiên Live mặc định tắt và chỉ được lưu khi bạn bật trong Cài đặt; ngưỡng camera tùy chọn chỉ lưu hai con số cục bộ. Cả hai đều bị xóa bởi **Xóa toàn bộ dữ liệu cục bộ**. Sao lưu đám mây và chuyển dữ liệu sang thiết bị khác đều bị tắt. Xem [docs/privacy.md](docs/privacy.md).
