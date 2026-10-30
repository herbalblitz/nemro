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
    live/                  camera gateway, YUV converter, frame analyzer, UI
    insights/              saved sessions, trends, per-session delete, CSV export
    learn/                 bilingual lessons
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
4. **Show:** waveform, task markers, playhead, prediction, class probabilities, and the known marker side by side, with the held-out accuracy, leave-one-run-out mean, confidence interval, and a clear demo label. A replay from S002 is labelled as a cross-subject demo instead of showing S001's score.
5. **History:** Live session summaries (not Lab predictions) can be saved locally for Insights when the user opts in.

### Lab replay implementation

- `assets/eeg/s001_r04_60s.csv` is a 60-second, 8-channel excerpt from EEGMMIDB S001/R04 at 160 Hz. `s001_r04_60s.json` records the source, channel order, license, and task markers. `assets/eeg/s002_r04_60s.csv` is a second excerpt with the same shape from S002/R04, selectable in Lab.
- `lib/features/lab/data/eeg_recording.dart` parses and validates the CSV/metadata pair. It rejects mismatched channel orders, malformed rows, and non-increasing timestamps.
- `lib/features/lab/widgets/eeg_chart.dart` paints the scrolling multi-channel waveform, task-marker bands, channel labels, and playhead.
- Playback is a local timer in `LabScreen`; it never touches the network. The dataset page opens in the user's external browser.

### Lab decoder implementation

- `assets/models/eeg_decoder.json` stores the weights, normalization values, feature order, and training/evaluation metadata.
- `lib/features/lab/data/eeg_decoder.dart` parses the model, extracts Goertzel band power, standardizes features, and applies the sigmoid. It is pure Dart; there is no TFLite or native dependency.
- `lib/features/lab/data/eeg_decoder_repository.dart` loads the asset and exposes `eegDecoderProvider` and `eegPredictionsProvider`. Predictions are computed once for every complete left/right task, not on each playback tick, so the UI timer stays cheap.
- The decoder card shows the prediction, left/right probabilities, the known marker, the held-out accuracy, the leave-one-run-out mean, and the Wilson 95% interval. A mismatch is visible; the app does not hide it.
- The model is trained on S001/R08 + R12 and evaluated on the held-out S001/R04, the same run used for the replay. Held-out accuracy is 66.7% (10/15; chance 50%; 95% Wilson interval 41.7%–84.8%); leave-one-run-out mean is 60.0%. Full details and limitations: [model-card.md](model-card.md).
- The S002/R04 replay is decoded for demonstration only. The card compares `recording.subject` with the model's training subject and, when they differ, replaces the accuracy and confusion matrix with a cross-subject note. S001's held-out number is never attached to S002.
- The EDF+ TAL onsets are absolute seconds. The excerpt exporter uses them directly; earlier record-relative handling was a bug and was fixed before the decoder was trained.

### Live (S2) — complete

1. The camera is untouched until the user taps **Start**. `DeviceLiveCameraGateway` then asks the camera plugin for available cameras, prefers the front lens, and falls back to the first available camera.
2. It opens a `CameraController` with `enableAudio: false`, `ResolutionPreset.low`, and `ImageFormatGroup.yuv420`, initializes it, and starts an image stream. The microphone is never opened.
3. `lumaFrameFromCameraImage` reads the Y plane (and BGRA on iOS-style frames), downsamples to at most 48 pixels on the long edge, and normalizes luminance to 0–1. Unsupported or malformed frames are dropped rather than crashing the stream.
4. `CameraProxyAnalyzer` computes mean brightness, central-region contrast, and mean absolute frame-to-frame motion. The proxy is `100 × presence × (0.6 × stability + 0.4 × lighting)`, smoothed over time; the first three frames are a warmup. A blank wall has near-zero central contrast and therefore stays low.
5. The UI shows the preview, a 0–100 proxy, light and stability bars, a warmup state, an optional personal baseline, and a session summary (average score, duration, frames). The summary stays in memory unless the user turns on **Save Live session summaries**; when on, it is appended to a capped local list.
6. **Stop**, leaving the screen, or the app going to the background cancels the frame subscription, stops the image stream, and disposes the controller. No video or images are written.

This path does **not** detect faces, eyes, blinks, head pose, or attention. It uses no ML Kit, no face model, and no server. The UI labels the number as a rough proxy, not a measurement of thoughts, fatigue, or medical state.

### Insights (S3) — complete

- Session summaries are a capped JSON list in `SharedPreferences` (`live_session_summaries`), not a database. This keeps the app free of native database dependencies while history is small (max 50 sessions).
- Saving is opt-in through `saveLiveSummariesProvider`; with saving off, completed sessions stay memory-only.
- `computeSessionTrends` derives weekly averages, best/worst sessions, and current/longest streaks from local data. Day and week boundaries are built from calendar fields and compared as UTC day ordinals, so DST transitions do not break a streak.
- Export is explicit and user-initiated: `SessionExporter` writes a CSV to the app's temporary directory and opens the Android share sheet. Timestamps are UTC.
- Deleting one session removes exactly one stored entry after confirmation. Deleting all local data clears preferences, the camera baseline, the lens choice, and session history.

## Privacy boundary

- No analytics SDK, ad SDK, account system, or remote logging.
- The release manifest requests `CAMERA` for Live, but no `INTERNET`, `RECORD_AUDIO`, storage, or media-library permission.
- The camera plugin declares audio, storage, and media permissions; `tools:node="remove"` entries in the app manifest remove them from the merged release manifest.
- Debug/profile manifests add `INTERNET` only for Flutter tooling.
- Live camera frames stay in memory and are never recorded, persisted, or uploaded. The only persisted Live data is the opt-in summary (score, duration, frames, end time) and the optional two-number baseline.
- Model files and datasets are bundled or generated locally; inference does not call a server.
- External links open in the user's browser and are outside the app's data boundary.

## Testing

- `flutter analyze --fatal-infos` must be clean, and hand-written Dart must pass `dart format --set-exit-if-changed`.
- `flutter test` covers first-launch onboarding, onboarding completion, ARB key parity, EEG CSV/metadata parsing, the bundled asset shape, decoder model parsing, inference on the bundled replay, synthetic band-power behavior, incomplete-window rejection, Lab replay, S002 cross-subject labelling, Wilson intervals, version consistency, and the Vietnamese narrow-screen layout.
- Live tests cover Y-plane/BGRA conversion, the analyzer's blank-wall, texture, motion, warmup, reset, and range behavior, and the Live UI with a fake camera gateway (start, permission failure, no-camera/error states, baseline save/clear, and session summary).
- Insights tests cover trend grouping, streaks, per-session delete confirmation, CSV UTC export, and the export share path.
- A physical Android camera smoke test is still pending; the fake-gateway tests cannot validate CameraX behavior on a real device.
- CI pins Flutter 3.47.8 and action commits, builds a release APK on an x64 runner, and checks the APK's permission set.

## Build versions

The Android template is aligned with Flutter 3.47 stable's verified matrix:

- Java 17
- Kotlin 2.4.10
- AGP 9.1.1
- Gradle 9.5.0
- compile/target SDK 36, min SDK 24
