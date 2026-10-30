# Changelog

All notable changes to Nemro are documented here.

## [Unreleased]

### Added

- Practice: an adaptive breathing session whose pace follows the Live camera signal proxy in real time (inhale 4s, hold 1s, exhale 4–8s by score, hold 1s), with 1/3/5-minute lengths and an on-screen-only summary. The camera opens only after **Start**; frames are analyzed in memory and never recorded, stored, or uploaded, and the screen states plainly that the pace is not a measure of calm, focus, or any medical state.

## [0.4.0] - 2026-10-30

### Added

- Insights history: opt-in saved Live session summaries, weekly averages, current/longest streaks, best/worst session, per-session delete with confirmation, and CSV export through the Android share sheet.
- Personal Live camera baseline: calibrate a usual range, show relative scores, clear the baseline from Live, and include it in **Delete all local data**.
- Second bundled Lab replay from S002/R04, selectable next to S001/R04.
- Cross-subject labelling in the Lab: S002 is marked as a demo and never shows S001's held-out accuracy or confusion matrix.
- Wilson 95% interval (41.7%–84.8%) and leave-one-run-out accuracy (60.0%) in the Lab model summary; the model card also records the one-sided p-value (≈0.15).
- Version-consistency test so `AppConstants.version` and `pubspec.yaml` cannot drift.
- Android `dataExtractionRules` that exclude app data from device-to-device transfer as well as cloud backup.

### Changed

- Version bumped to 0.4.0+4.
- User-facing "attention proxy" wording is now "camera signal proxy" / "camera proxy score" in both languages. The analyzer was renamed `CameraProxyAnalyzer`.
- Model preprocessing and limitations text in the Lab is localized instead of showing raw English JSON.
- README, privacy policy, architecture, data-sources, model card, and security policy now match the actual storage and export behavior.
- CSV timestamps are exported in UTC with a `Z` suffix.
- Streak and weekly grouping use calendar-day ordinals so DST transitions do not break a streak.
- Settings deletion now invalidates the in-memory camera baseline and session-store providers.
- CI pins Flutter 3.47.8 and action commits, checks formatting, runs `flutter analyze --fatal-infos`, and forbids additional media/storage permissions.

### Fixed

- Deleting all local data no longer leaves the old camera baseline active until the app restarts.
- A "Baseline saved" message no longer survives into the next Live session.
- The Lab no longer attaches S001's accuracy to S002.
- A stale `predictedClass` getter that hardcoded class names was removed.

### Security

- Release manifest removes `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_MEDIA_AUDIO`, `READ_MEDIA_VISUAL_USER_SELECTED`, and `ACCESS_MEDIA_LOCATION` in addition to audio/storage permissions.
- Android cloud backup and device-to-device transfer are both disabled.

## [0.3.0] - 2026-10-28

### Added

- Live camera proxy with explicit **Start** and **Stop**, a camera preview, a 3-frame warmup, a smoothed 0–100 score, light/stability bars, and an in-memory session summary.
- `camera`/CameraX integration that prefers the front camera, falls back to the first available camera, disables audio, and requests a low-resolution YUV420 stream.
- Pure-Dart frame converter (Y-plane and BGRA) and a transparent analyzer based on central contrast, lighting, and frame-to-frame stability. No face, eye, or attention detection.
- Camera gateway abstraction so widget tests can run without a physical camera.
- Tests for frame conversion, analyzer behavior, Live start/permission/error states, and the session summary.
- `CAMERA` permission for Live, plus manifest rules that remove the camera plugin's `RECORD_AUDIO` and `WRITE_EXTERNAL_STORAGE` declarations, suppress the implied `READ_EXTERNAL_STORAGE` permission, and make `android.hardware.camera.any` optional.
- CI assertions that the release APK contains `CAMERA` and does not contain `INTERNET`, `RECORD_AUDIO`, `READ_EXTERNAL_STORAGE`, or `WRITE_EXTERNAL_STORAGE`.

### Changed

- Live is no longer a placeholder; the Home card opens the working Live screen.
- Home, onboarding, privacy, README, architecture, data-source, and model-card copy now describe the Live proxy and its limits.
- Version bumped to 0.3.0+3.
- Live session summaries are not persisted in this release; Insights history remains planned for S3.

### Security

- Live frames are processed on-device and are never recorded, stored, or uploaded.
- The camera is released on **Stop**, on leaving the screen, and when the app goes to the background.
- The release build keeps no `INTERNET` permission and requests no microphone or storage permission.

### Known limitations

- The Live score is a rough light/contrast/stability heuristic, not a measurement of attention, fatigue, or any medical state.
- Analyzer and UI tests use a fake camera gateway. A physical Android camera smoke test is still pending.

## [0.2.0] - 2026-10-27

### Added

- On-device logistic-regression decoder for imagined left/right fist movement in the Lab.
- Mu/beta Goertzel features from C3, C4, CP3, and CP4; pure-Dart inference with no native or network dependency.
- Bundled model weights (`assets/models/eeg_decoder.json`) with training metadata and a reproducible training tool (`tool/train_eeg_decoder.py`).
- Model card with held-out evaluation, confusion matrix, calibration caveats, and limitations (`docs/model-card.md`).
- Lab decoder card showing the prediction, left/right probabilities, the known task marker, and the held-out accuracy.
- Reproducible EEG excerpt exporter (`tool/extract_eeg_excerpt.py`) and dataset/model attribution updates.
- Decoder tests for model parsing, bundled replay inference, synthetic band-power behavior, and incomplete-window rejection.

### Changed

- Lab is no longer a placeholder; it now includes both replay and on-device decoding.
- Home, About, privacy, README, architecture, and data-source docs now describe the decoder and its limits.
- Version bumped to 0.2.0+2.
- Release builds sign with the keystore from `android/key.properties` when present, falling back to the debug key otherwise (see `docs/release-signing.md`).
- CI now fails if the release manifest requests the `INTERNET` permission.
- Enabled the `avoid_print` and `prefer_single_quotes` lints.

### Fixed

- EEG task markers now use the EDF+ TAL absolute onsets directly. The previous record-relative handling shifted markers later in the file; the bundled excerpt and training data were regenerated.

### Security

- `.gitignore` now explicitly excludes `*.jks`, `*.keystore`, `*.p12`, `*.pfx`, `key.properties`, and `.env` files.

## [0.1.0] - 2026-10-27

### Added

- Flutter Android app scaffold with package id `io.github.herbalblitz.nemro`.
- Bilingual Vietnamese–English onboarding with language choice and consent.
- Material 3 light/dark themes, selectable in Settings.
- Bottom navigation for Home, Insights, Learn, and Settings.
- Home entry cards for Lab and Live, plus honest placeholder screens.
- In-app privacy policy, about screen, disclaimer, and open-source licenses.
- Local settings with `shared_preferences`; no accounts, ads, analytics, or release `INTERNET` permission.
- Riverpod state, `go_router` navigation, and ARB localization.
- GitHub Actions CI: analyze, test, and release APK artifact.
- MIT license and contributor/security documentation.
