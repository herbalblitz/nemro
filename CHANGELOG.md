# Changelog

All notable changes to Nemro are documented here.

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
