# Architecture

## Principles

1. **Local-first.** No network dependency for the core experience. Release builds do not request `INTERNET`.
2. **Honest AI.** Show real data, real model outputs, and real limitations. Never present a heuristic as mind reading.
3. **Small, replaceable modules.** The UI can grow without locking the data or model layers together.
4. **Bilingual by default.** Every user-facing string goes through ARB localization.

## Structure

```text
lib/
  app.dart                 MaterialApp.router, theme, locale, router
  main.dart                SharedPreferences bootstrap + ProviderScope
  core/
    constants/             app metadata, preference keys
    l10n/                  ARB files + generated localizations
    preferences/           SharedPreferences-backed Riverpod notifiers
    router/                go_router route table and onboarding redirect
    theme/                 Material 3 light/dark themes
    widgets/               shared cards, brand mark, empty states
  features/
    onboarding/            language + consent
    shell/                 bottom navigation shell
    home/                  landing screen
    lab/                   EEG replay + on-device decoder
    live/                  camera attention placeholder
    insights/              history placeholder
    learn/                 lesson list placeholder
    settings/              language, theme, privacy, data, about
    about/                 project, sources, disclaimer
    privacy/               in-app privacy policy
tool/
  train_eeg_decoder.py     reproducible model training (stdlib only)
  extract_eeg_excerpt.py   CSV/JSON excerpt exporter (stdlib only)
assets/
  eeg/                     bundled 60-second EEGMMIDB excerpt + metadata
  models/                  bundled logistic-regression weights + metadata
docs/
  model-card.md            model details, evaluation, limitations
```

## State and routing

- **Riverpod** owns app state. `sharedPreferencesProvider` is overridden in `main()` with a real instance, and in tests with a mock.
- **go_router** owns navigation. A `ShellRoute` hosts the four bottom-nav tabs; Lab, Live, About, and Privacy are full-screen routes.
- Onboarding completion is read from `SharedPreferences` by the router redirect. Completing onboarding writes the flag and navigates to `/`; deleting data clears the flag and returns to `/onboarding`.
- Language and theme are `Notifier`s backed by preferences. Changing either updates `MaterialApp` immediately.

## Localization

- Source strings: `lib/core/l10n/app_en.arb` and `app_vi.arb`.
- Generated code: `lib/core/l10n/generated/` (excluded from analysis).
- `l10n.yaml` sets `nullable-getter: false` and an explicit output directory.
- The app uses `material_ui`'s `GlobalMaterialLocalizations.delegates` so Material widgets are localized with the same Material implementation as the app. The generated `AppLocalizations.localizationsDelegates` list is intentionally not used.

## Data flow

### Lab (S1) — complete

1. **Bundle:** a small, documented public EEG window with source metadata. See [data-sources.md](data-sources.md).
2. **Preprocess:** extract complete 4.1-second task windows from the replay; remove the window mean and apply a Hann window.
3. **Decode:** compute mu/beta Goertzel power for C3, C4, CP3, and CP4, standardize the 8 features, and run a bundled logistic regression entirely in Dart.
4. **Show:** waveform, task markers, playhead, prediction, class probabilities, and the known marker side by side, with the held-out accuracy and a clear demo label.
5. **Next:** store a session summary locally for Insights.

### Lab replay implementation

- `assets/eeg/s001_r04_60s.csv` is a 60-second, 8-channel excerpt from EEGMMIDB S001/R04 at 160 Hz. `s001_r04_60s.json` records the source, channel order, license, and task markers.
- `lib/features/lab/data/eeg_recording.dart` parses and validates the CSV/metadata pair. It rejects mismatched channel orders, malformed rows, and non-increasing timestamps.
- `lib/features/lab/widgets/eeg_chart.dart` paints the scrolling multi-channel waveform, task-marker bands, channel labels, and playhead.
- Playback is a local timer in `LabScreen`; it never touches the network. The dataset page opens in the user's external browser.

### Lab decoder implementation

- `assets/models/eeg_decoder.json` stores the weights, normalization values, feature order, and training/evaluation metadata.
- `lib/features/lab/data/eeg_decoder.dart` parses the model, extracts Goertzel band power, standardizes features, and applies the sigmoid. It is pure Dart; there is no TFLite or native dependency.
- `lib/features/lab/data/eeg_decoder_repository.dart` loads the asset and exposes `eegDecoderProvider` and `eegPredictionsProvider`. Predictions are computed once for every complete left/right task, not on each playback tick, so the UI timer stays cheap.
- The decoder card shows the prediction, left/right probabilities, the known marker, and the held-out accuracy. A mismatch is visible; the app does not hide it.
- The model is trained on S001/R08 + R12 and evaluated on the held-out S001/R04, the same run used for the replay. Held-out accuracy is 66.7% (chance 50%); leave-one-run-out mean is 60.0%. Full details and limitations: [model-card.md](model-card.md).
- The EDF+ TAL onsets are absolute seconds. The excerpt exporter uses them directly; earlier record-relative handling was a bug and was fixed before the decoder was trained.

### Live (S2)

1. Camera permission is requested only when the user starts a session.
2. Face/eye signals are extracted on-device.
3. A transparent heuristic (blink rate, eye closure, head stability) produces an attention proxy.
4. No frames are recorded; only aggregate scores may be stored.
5. The UI labels the result as a proxy, not a measurement of thoughts or medical state.

### Insights (S3+)

- A local database (planned: Drift/SQLite) stores session summaries.
- Export is explicit and user-initiated.
- Deleting local data clears both preferences and session tables.

## Privacy boundary

- No analytics SDK, ad SDK, account system, or remote logging.
- No `INTERNET` permission in `android/app/src/main/AndroidManifest.xml`.
- Debug/profile manifests add `INTERNET` only for Flutter tooling.
- Model files and datasets are bundled or generated locally; inference does not call a server.
- External links open in the user's browser and are outside the app's data boundary.

## Testing

- `flutter analyze` must be clean.
- `flutter test` covers first-launch onboarding, onboarding completion, ARB key parity, EEG CSV/metadata parsing, the bundled asset shape, decoder model parsing, inference on the bundled replay, synthetic band-power behavior, incomplete-window rejection, Lab replay, and the Vietnamese narrow-screen layout.
- CI builds a release APK on an x64 runner so ARM64 development machines are not a blocker.

## Build versions

The Android template is aligned with Flutter 3.47 stable's verified matrix:

- Java 17
- Kotlin 2.4.0
- AGP 9.1.1
- Gradle 9.5.0
- compile/target SDK 36, min SDK 24
