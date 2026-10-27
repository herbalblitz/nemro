# Changelog

All notable changes to Nemro are documented here.

## [Unreleased]

### Added

- Lab replay of a real 60-second EEG window from the PhysioNet EEGMMIDB dataset (S001/R04, 8 channels, 160 Hz).
- Rest, left-fist, and right-fist task markers; play/pause, scrubbing, restart, and 0.5×/1×/2× speed controls.
- Bundled ODC-BY 1.0 EEG excerpt with source metadata, citation, and in-app attribution.
- Validated CSV/metadata parser and tests for the parser, bundled asset shape, Lab replay, and Vietnamese narrow-screen layout.

### Changed

- Lab is no longer a placeholder. The on-device AI decoder remains the next S1 step.
- About and privacy copy now describe the bundled EEG excerpt.

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
