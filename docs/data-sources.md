# Data and model sources

Nemro 0.2.0 bundles one **60-second EEG excerpt** from EEGMMIDB and a small
**on-device decoder** trained on the same public dataset. Live remains a
placeholder. This page records the sources, licenses, evaluation rules, and
attribution requirements for the bundled data and model.

## Datasets

### PhysioNet EEG Motor Movement/Imagery Dataset (EEGMMIDB)

**Status:** bundled excerpt and decoder training/evaluation data.

- **What:** 64-channel EEG recordings from 109 subjects performing motor
  execution and motor imagery tasks.
- **Use in Nemro:**
  - The Lab bundles a 60-second window from **S001/R04** with 8 of 64 channels
    (C3, Cz, C4, FC3, FC4, CP3, CP4, Pz) at 160 Hz. The raw EDF is not
    redistributed.
  - The decoder uses four channels (C3, C4, CP3, CP4). It is trained on
    **S001/R08 + R12** and evaluated on the held-out **S001/R04**, which is the
    same run used for the replay. See [model-card.md](model-card.md).
- **Marker timing:** the EDF+ TAL onsets are absolute seconds. The extraction
  tool uses them directly; it does not add the record index. The 60-second
  excerpt contains seven complete imagined-fist tasks.
- **Source:** <https://physionet.org/content/eegmmidb/1.0.0/>
- **Dataset citation:** Schalk, G. (2009). *EEG Motor Movement/Imagery Dataset*
  (version 1.0.0). PhysioNet. <https://doi.org/10.13026/C28G6P>
- **BCI2000 citation:** Schalk, G., McFarland, D. J., Hinterberger, T.,
  Birbaumer, N., & Wolpaw, J. R. (2004). BCI2000: A General-Purpose
  Brain-Computer Interface (BCI) System. *IEEE Transactions on Biomedical
  Engineering*, 51(6), 1034–1043.
- **License:** Open Data Commons Attribution License v1.0. The excerpt is
  redistributed with attribution in the app, `assets/eeg/README.md`, and this
  page. The raw archive stays out of the repository.

### BCI Competition IV Dataset 2a

**Status:** planned for future evaluation; **not used in 0.2.0**.

- **What:** four-class motor imagery EEG from nine subjects.
- **Use in Nemro:** a possible second evaluation dataset for the Lab decoder, if
  the license allows redistribution.
- **Source:** <https://www.bbci.de/competition/iv/>
- **Citation:** Tangermann, M., Müller, K.-R., Aertsen, A., et al. (2012).
  Review of the BCI Competition IV. *Frontiers in Neuroscience*, 6:55.
- **Rules:** do not redistribute the data unless the competition terms allow it.
  Document preprocessing and subject-wise splits.

## Bundled model

**Status:** bundled in `assets/models/eeg_decoder.json`.

- **Type:** binary logistic regression (pure Dart inference).
- **Input:** 4.1 s, 160 Hz, four channels (C3, C4, CP3, CP4).
- **Features:** mu (8–13 Hz) and beta (13–30 Hz) Goertzel power at 0.5 Hz steps,
  log-transformed and standardized; 8 features.
- **Training:** S001/R08 + R12, 30 trials (15 left, 15 right).
- **Held-out evaluation:** S001/R04, 15 trials, 66.7% accuracy (chance 50%).
  Leave-one-run-out mean: 60.0%.
- **Weights license:** MIT. The weights are trained from ODC-BY 1.0 data; the
  dataset attribution remains in the app and in the model card.
- **Limitations:** single subject, small sample, binary imagined-fist task, no
  artifact rejection, not a medical device, not mind reading.
- **Reproduce:** `python3 tool/train_eeg_decoder.py --data-dir <S001> --out assets/models/eeg_decoder.json`.

Full details: [model-card.md](model-card.md).

## Model rules

- Prefer a small model that runs comfortably on a mid-range Android phone.
- Record the model architecture, training data, preprocessing, input shape,
  output labels, accuracy, and known failure modes in `docs/model-card.md`.
- Do not claim that a motor-imagery classifier reads thoughts, intentions, or
  medical state.
- Keep inference on-device. Do not add a remote inference endpoint.
- Check the license of every model weight file before committing it.
- Evaluate on a run/subject that is not in the training set. Report chance level
  and sample size next to accuracy.
- Show the model's mistakes and limitations in the UI, not only the successes.

## Attribution in the app

The About screen credits the EEG dataset and the bundled decoder, and links to
the model card. When a dataset or model is added or changed, update:

1. `lib/features/about/about_screen.dart`;
2. `lib/core/l10n/app_en.arb` and `app_vi.arb`;
3. `assets/eeg/README.md` and `assets/models/README.md`;
4. `docs/privacy.md` if data handling changes;
5. `CHANGELOG.md` and `docs/model-card.md`.
