# Bundled EEG sample

`s001_r04_60s.csv` is a 60-second excerpt of real EEG from the
[PhysioNet EEG Motor Movement/Imagery Dataset](https://physionet.org/content/eegmmidb/1.0.0/)
(EEGMMIDB), version 1.0.0.

- **Subject / run:** S001, run R04 (imagined left/right fist)
- **Window:** 0–60 seconds
- **Channels:** C3, Cz, C4, FC3, FC4, CP3, CP4, Pz (8 of the 64 channels)
- **Sampling rate:** 160 Hz
- **Units:** microvolts (the EDF digital values map 1:1 to physical µV)
- **Processing:** channel selection and CSV export only; no filtering,
  artifact removal, or normalization
- **Markers:** `T0` rest, `T1` left-fist imagery, `T2` right-fist imagery

The EDF+ TAL onsets are absolute seconds. The exporter uses them directly; do
not add the record index to the onset. This 60-second excerpt contains seven
complete imagined-fist tasks (four right, three left).

The original EDF file is `S001/S001R04.edf` from the dataset. It is **not**
included in this repository. The excerpt is redistributed under the dataset's
[Open Data Commons Attribution License v1.0](https://opendatacommons.org/licenses/by/1-0/).

## Citation

Schalk, G. (2009). *EEG Motor Movement/Imagery Dataset* (version 1.0.0).
PhysioNet. <https://doi.org/10.13026/C28G6P>

Schalk, G., McFarland, D. J., Hinterberger, T., Birbaumer, N., & Wolpaw, J. R.
(2004). BCI2000: A General-Purpose Brain-Computer Interface (BCI) System.
*IEEE Transactions on Biomedical Engineering, 51*(6), 1034–1043.

## Regenerating

Download `S001/S001R04.edf` from PhysioNet, then run:

```bash
python3 tool/extract_eeg_excerpt.py \
  --edf /path/to/S001R04.edf \
  --csv assets/eeg/s001_r04_60s.csv \
  --json assets/eeg/s001_r04_60s.json \
  --seconds 60
```

The exporter reads the EDF annotation channel; a separate `.event` file is not
needed. The JSON sidecar records the source metadata and task markers used by
the app. Keep the raw EDF out of the repository.
