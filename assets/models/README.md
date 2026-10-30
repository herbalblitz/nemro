# Bundled decoder

`eeg_decoder.json` is the model used by Nemro's Lab. It is a binary
logistic-regression classifier for imagined left/right fist movement from
subject S001 of the PhysioNet EEGMMIDB dataset.

- **Input:** 4.1 s at 160 Hz from C3, C4, CP3, and CP4.
- **Features:** mu (8–13 Hz) and beta (13–30 Hz) Goertzel power at 0.5 Hz steps,
  log-transformed and standardized; 8 features.
- **Training:** S001 runs R08 and R12 (30 trials, 15 left / 15 right).
- **Held-out evaluation:** S001 run R04 (15 trials), 66.7% accuracy; chance 50%;
  95% Wilson interval 41.7%–84.8%; one-sided p ≈ 0.15.
- **Cross-subject demo:** the S002 replay runs the same model but has no
  accuracy claim; the model was trained and evaluated on S001 only.
- **Inference:** pure Dart, on-device. No network or native runtime.
- **License:** MIT for the code and weights; EEG data ODC-BY 1.0.

Do not edit the JSON by hand. Regenerate it with:

```bash
python3 tool/train_eeg_decoder.py \
  --data-dir /path/to/S001 \
  --out assets/models/eeg_decoder.json
```

The raw EDF files are not part of this repository. Full evaluation details,
limitations, and the data citation are in
[`docs/model-card.md`](../../docs/model-card.md).
