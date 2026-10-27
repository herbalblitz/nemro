# Data and model sources

Nemro 0.1.0 does **not** bundle any EEG dataset or AI model. Lab and Live are placeholders. This page records the sources the next milestones will use and the rules for adding them.

## Planned datasets

### PhysioNet EEG Motor Movement/Imagery Dataset (EEGMMIDB)

- **What:** 64-channel EEG recordings from 109 subjects performing motor execution and motor imagery tasks.
- **Use in Nemro:** a small, documented replay window for the Lab screen.
- **Source:** <https://physionet.org/content/eegmmidb/>
- **Citation:** Schalk, G., McFarland, D. J., Hinterberger, T., Birbaumer, N., & Wolpaw, J. R. (2004). BCI2000: A General-Purpose Brain-Computer Interface (BCI) System. *IEEE Transactions on Biomedical Engineering*, 51(6), 1034–1043.
- **Rules:** check the current PhysioNet license and attribution requirements before bundling; keep the raw archive out of the repository if the license requires it.

### BCI Competition IV Dataset 2a

- **What:** four-class motor imagery EEG from nine subjects.
- **Use in Nemro:** a second evaluation dataset for the Lab decoder, if the license allows redistribution.
- **Source:** <https://www.bbci.de/competition/iv/>
- **Citation:** Tangermann, M., Müller, K.-R., Aertsen, A., et al. (2012). Review of the BCI Competition IV. *Frontiers in Neuroscience*, 6:55.
- **Rules:** do not redistribute the data unless the competition terms allow it. Document preprocessing and subject-wise splits.

## Model rules

- Prefer a small model that runs comfortably on a mid-range Android phone.
- Record the model architecture, training data, preprocessing, input shape, output labels, accuracy, and known failure modes in `docs/model-card.md`.
- Do not claim that a motor-imagery classifier reads thoughts, intentions, or medical state.
- Keep inference on-device. Do not add a remote inference endpoint.
- Check the license of every model weight file before committing it.

## Attribution in the app

The About screen credits the datasets above. When a dataset or model is actually bundled, update:

1. `lib/features/about/about_screen.dart`;
2. `lib/core/l10n/app_en.arb` and `app_vi.arb`;
3. `docs/privacy.md` if data handling changes;
4. `CHANGELOG.md`.
