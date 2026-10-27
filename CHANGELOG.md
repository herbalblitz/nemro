# Changelog

All notable changes to Nemro are documented here.

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
