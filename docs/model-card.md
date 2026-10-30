# Model card: S001 mu/beta logistic regression

- **Model version:** 1
- **App version:** Nemro 0.4.0
- **Date:** 2026-10-30
- **Weights:** `assets/models/eeg_decoder.json`
- **Training tool:** `tool/train_eeg_decoder.py`
- **License:** MIT for the code and weights; EEG data under ODC-BY 1.0

## What this model is

A small binary logistic-regression classifier. It estimates whether a 4.1-second
EEG window from subject **S001** was recorded during imagined **left-fist** or
**right-fist** movement. It is an educational demonstration of an end-to-end
on-device EEG decoding pipeline, not a brain-computer interface product.

## Intended use

- Run locally on the bundled S001/R04 replay in Nemro's Lab.
- Show a prediction, a class probability, and the known task marker side by side.
- Teach how band-power features, a linear classifier, and held-out evaluation
  fit together.

The Lab also bundles an S002/R04 replay. It is a **cross-subject demo only**:
the model was not trained or evaluated on S002, so the app labels that replay
as a demo and does not show S001's accuracy or confusion matrix next to it.

**Not intended for:** diagnosis, treatment, neurofeedback, lie detection,
surveillance, or any claim of reading thoughts or intentions. The model was not
validated on other people, other sessions, other hardware, or other tasks.

## Input and preprocessing

- **Channels:** C3, C4, CP3, CP4 (4 of the 64 EEGMMIDB channels).
- **Sampling rate:** 160 Hz.
- **Window:** 4.1 s (656 samples), starting at the T1/T2 marker onset.
- **Preprocessing:** per-window mean removal and a Hann window. No artifact
  rejection, ICA, or spatial filtering.
- **Features:** Goertzel power at 0.5 Hz steps, summed over mu (8–13 Hz, 10
  frequencies) and beta (13–30 Hz, 34 frequencies), then `log10(power + 1e-12)`.
  This gives 8 features in channel-major order (mu, beta per channel).
- **Classifier:** standardized features; `z = bias + w · x`;
  `P(right) = sigmoid(z)`. Class 0 is left, class 1 is right.

## Training data

- **Dataset:** PhysioNet EEG Motor Movement/Imagery Dataset (EEGMMIDB) v1.0.0.
- **Subject:** S001.
- **Training runs:** R08 and R12 (imagined left/right fist), 15 trials each.
- **Training trials:** 30 total; 15 left and 15 right.
- **Labels:** T1 = left-fist imagery, T2 = right-fist imagery.
- **Held-out run:** R04 (15 trials; 8 left, 7 right). This is also the run used
  for the Lab replay, so the in-app predictions are out-of-sample for S001.
- The raw EDF files are not redistributed; the app only bundles the 60-second
  CSV excerpt and the trained weights.

## Evaluation

- **Held-out R04 accuracy:** 10/15 = **66.7%** (chance 50%).
- **95% Wilson interval:** **41.7%–84.8%**. This is the honest uncertainty
  range for 10/15; the point estimate alone is not a precise benchmark.
- **One-sided binomial test** against chance (≥10 of 15): **p ≈ 0.15**. The
  result is not statistically significant at the usual 0.05 threshold.
- **Held-out confusion matrix** (rows = actual, columns = predicted):

  | | predicted left | predicted right |
  | --- | ---: | ---: |
  | actual left | 5 | 3 |
  | actual right | 2 | 5 |

- **Leave-one-run-out cross-validation** across R04/R08/R12: mean **60.0%**.
  - test R04: 66.7%
  - test R08: 46.7%
  - test R12: 66.7%
- **Sample size warning:** 15 held-out trials means one trial changes accuracy
  by 6.7 percentage points. The result is a rough estimate, not a precise
  benchmark. The S002 replay has no accuracy figure at all because the model
  was not evaluated on that subject.
- **Calibration:** the sigmoid output is not calibrated. The Lab's displayed
  "confidence" is the larger class probability, not a guarantee of correctness.
  The 60-second replay contains seven of the 15 held-out trials (four right,
  three left); its excerpt accuracy is not the 66.7% figure. Visible mistakes
  are expected.

## Limitations

- One subject only; no evidence of cross-subject generalization.
- Small training set (30 trials) and high variance across runs.
- Binary imagined-fist task only; rest windows are not decoded.
- No artifact rejection; eye and muscle activity can dominate the signal.
- Four channels and simple band power; no CSP, Riemannian, or deep model.
- Predictions are computed for complete 4.1-second windows, not in real time.
- The model cannot determine what a person is thinking, intending, or feeling.

## Privacy and ethics

- The model and the EEG excerpt are bundled with the app.
- Inference is on-device; there is no remote inference endpoint.
- Nemro does not record the user's EEG.
- The Lab shows the held-out accuracy and compares the prediction with the known
  marker; it does not present the output as mind reading.
- Do not use this model for medical, employment, education, insurance, or
  surveillance decisions.

## Reproduce

Download `S001R04.edf`, `S001R08.edf`, and `S001R12.edf` from
<https://physionet.org/content/eegmmidb/1.0.0/>, then run:

```bash
python3 tool/train_eeg_decoder.py \
  --data-dir /path/to/S001 \
  --out assets/models/eeg_decoder.json
```

The training script uses only the Python standard library. It prints the
leave-one-run-out folds and the held-out R04 result before writing the model.

## Data citation

Schalk, G. (2009). *EEG Motor Movement/Imagery Dataset* (version 1.0.0).
PhysioNet. <https://doi.org/10.13026/C28G6P>

Schalk, G., McFarland, D. J., Hinterberger, T., Birbaumer, N., & Wolpaw, J. R.
(2004). BCI2000: A General-Purpose Brain-Computer Interface (BCI) System.
*IEEE Transactions on Biomedical Engineering, 51*(6), 1034–1043.

## Second decoder: nearest centroid (for comparison)

The Lab also ships a second model, `assets/models/eeg_decoder_centroid.json`,
so the same replay can be run through two different models. It uses the
exact same 8 mu/beta features and the same 4 channels, but a different
decision rule: each class is represented by the mean standardized feature
vector of its training windows, and a new window is assigned to the nearer
centroid.

- **Training:** the 7 task windows of the S001/R04 60-second excerpt itself
  (3 left, 4 right). It has no held-out run and no leave-one-run-out
  evaluation.
- **In-sample accuracy:** 5/7 = 71.4%, confusion [[2, 1], [1, 3]] (rows =
  actual, columns = predicted). This number is inflated by construction —
  the model is tested on the windows it learned from — and the Lab labels
  it "in-sample" wherever it appears. It must never be compared with the
  logistic model's held-out 66.7%.
- **Agreement with the logistic model:** the two models agree on only 3 of
  the 7 replay windows and disagree on 4, even though both score 5/7 on the
  excerpt. Accuracy alone hides disagreement; the comparison is the lesson.
- **Regeneration:** `python3 tool/train_centroid_decoder.py` (standard
  library only). It first replays the shipped logistic model on the first
  task window and refuses to write anything if the feature pipeline has
  drifted from the Dart regression value (right probability 0.785649).

## Version history

- **v1 (2026-10-27):** initial model; 4 channels, 8 features, held-out R04
  66.7%, leave-one-run-out mean 60.0%.
- **v1.1 (2026-10-30):** documentation and UI context only; weights unchanged.
  Added the Wilson interval (41.7%–84.8%), the one-sided p-value (≈0.15), the
  LORO line in the Lab, and explicit S002 cross-subject labelling.
- **v2 (2026-10-30):** second decoder added (nearest centroid, same features).
  The Lab lets the user switch models; the centroid's accuracy is labelled
  in-sample and never shown next to a held-out number without that label.
