#!/usr/bin/env python3
"""Train the second Lab decoder: a nearest-centroid model on the S001 replay.

This script uses only the Python standard library. It reads the bundled
60-second S001/R04 excerpt (the same windows the Lab replays), computes the
exact mu/beta log-power features the Dart decoder uses (per-window mean
removal, Hann window, Goertzel power at 0.5 Hz steps, log10), standardizes
them with the mean/std across the excerpt's task windows, and stores one
centroid per class (the mean standardized feature vector of that class).

Honesty notes, also written into the model JSON:
- The centroid model is trained AND evaluated on the same 7 task windows
  it replays, so its in-sample accuracy is inflated and is NOT comparable
  to the logistic model's held-out accuracy (66.7% on the full R04 run).
- Before writing the model, the script replays the shipped logistic model
  on the first task window and checks its right-fist probability against
  the Dart regression value (0.785649). If the feature pipeline drifts,
  the script refuses to write anything.

Usage:
    python3 tool/train_centroid_decoder.py
"""

import csv
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CSV_PATH = ROOT / 'assets' / 'eeg' / 's001_r04_60s.csv'
META_PATH = ROOT / 'assets' / 'eeg' / 's001_r04_60s.json'
LOGISTIC_PATH = ROOT / 'assets' / 'models' / 'eeg_decoder.json'
OUT_PATH = ROOT / 'assets' / 'models' / 'eeg_decoder_centroid.json'

MODEL_CHANNELS = ['C3', 'C4', 'CP3', 'CP4']
MU = (8.0, 13.0)
BETA = (13.0, 30.0)
FREQUENCY_STEP = 0.5
SAMPLING_RATE = 160.0
WINDOW_SECONDS = 4.1
EXPECTED_FIRST_WINDOW_RIGHT_PROB = 0.785649


def goertzel_power(samples, frequency, sampling_rate):
    omega = 2 * math.pi * frequency / sampling_rate
    coefficient = 2 * math.cos(omega)
    s0 = s1 = s2 = 0.0
    for sample in samples:
        s0 = sample + coefficient * s1 - s2
        s2 = s1
        s1 = s0
    power = s1 * s1 + s2 * s2 - coefficient * s1 * s2
    return power if math.isfinite(power) and power > 0 else 0.0


def band_power(windowed, low, high, step, sampling_rate):
    power = 0.0
    frequency = low
    while frequency < high - 1e-9:
        power += goertzel_power(windowed, frequency, sampling_rate)
        frequency += step
    return math.log10(power + 1e-12)


def window_features(channel_samples, start, length):
    windowed = []
    mean = sum(channel_samples[start:start + length]) / length
    for i in range(length):
        hann = 0.5 * (1 - math.cos(2 * math.pi * i / (length - 1)))
        windowed.append((channel_samples[start + i] - mean) * hann)
    return [
        band_power(windowed, MU[0], MU[1], FREQUENCY_STEP, SAMPLING_RATE),
        band_power(windowed, BETA[0], BETA[1], FREQUENCY_STEP, SAMPLING_RATE),
    ]


def main():
    metadata = json.loads(META_PATH.read_text(encoding='utf-8'))
    channels = metadata['channels']
    indices = [channels.index(name) for name in MODEL_CHANNELS]

    with CSV_PATH.open(newline='', encoding='utf-8') as handle:
        rows = list(csv.DictReader(handle))
    samples_by_channel = {
        name: [float(row[name]) for row in rows] for name in MODEL_CHANNELS
    }
    del rows

    length = round(WINDOW_SECONDS * SAMPLING_RATE)
    tasks = []  # (onset, label) for T1/T2 events only
    for event in metadata['events']:
        if event['label'] not in ('T1', 'T2'):
            continue
        start = round(event['onset'] * SAMPLING_RATE)
        if start + length > len(samples_by_channel[MODEL_CHANNELS[0]]):
            continue
        tasks.append((event['onset'], event['label']))

    features = []
    for onset, _ in tasks:
        start = round(onset * SAMPLING_RATE)
        row = []
        for name in MODEL_CHANNELS:
            row.extend(window_features(samples_by_channel[name], start, length))
        features.append(row)

    # Cross-check the feature pipeline against the Dart regression value.
    logistic = json.loads(LOGISTIC_PATH.read_text(encoding='utf-8'))
    first = features[0]
    standardized = [
        (value - mean) / std
        for value, mean, std in zip(first, logistic['mean'], logistic['std'])
    ]
    logit = logistic['bias'] + sum(
        weight * value for weight, value in zip(logistic['weights'], standardized)
    )
    right_prob = 1 / (1 + math.exp(-logit))
    if abs(right_prob - EXPECTED_FIRST_WINDOW_RIGHT_PROB) > 0.001:
        raise SystemExit(
            f'Feature pipeline drift: first window right probability '
            f'{right_prob:.6f} != {EXPECTED_FIRST_WINDOW_RIGHT_PROB}; '
            f'refusing to write the centroid model.'
        )

    # Standardize with the mean/std across these 7 windows (population std,
    # documented in the model JSON so the choice is auditable).
    n_features = len(features[0])
    mean = [
        sum(row[i] for row in features) / len(features) for i in range(n_features)
    ]
    std = [
        math.sqrt(
            sum((row[i] - mean[i]) ** 2 for row in features) / len(features)
        )
        for i in range(n_features)
    ]
    if any(value <= 0 for value in std):
        raise SystemExit('A feature has zero variance; cannot standardize.')

    standardized_rows = [
        [(value - mean[i]) / std[i] for i, value in enumerate(row)]
        for row in features
    ]

    classes = ['left_fist', 'right_fist']
    label_to_class = {'T1': 0, 'T2': 1}
    centroids = []
    for class_index in range(2):
        members = [
            row
            for row, (_, label) in zip(standardized_rows, tasks)
            if label_to_class[label] == class_index
        ]
        centroids.append([
            sum(row[i] for row in members) / len(members)
            for i in range(n_features)
        ])

    def predict(row):
        distances = [
            math.sqrt(
                sum((value - center) ** 2 for value, center in zip(row, centroid))
            )
            for centroid in centroids
        ]
        total = distances[0] + distances[1]
        right_probability = 0.5 if total == 0 else distances[0] / total
        return (1 if right_probability >= 0.5 else 0, right_probability)

    confusion = [[0, 0], [0, 0]]
    predictions = []
    for row, (onset, label) in zip(standardized_rows, tasks):
        predicted, probability = predict(row)
        actual = label_to_class[label]
        confusion[actual][predicted] += 1
        predictions.append((onset, label, predicted, probability))
    correct = confusion[0][0] + confusion[1][1]
    in_sample_accuracy = correct / len(tasks)

    model = {
        'name': 'S001 mu/beta nearest centroid',
        'version': 1,
        'type': 'nearest_centroid',
        'classes': classes,
        'channels': MODEL_CHANNELS,
        'bands': {'mu_hz': [MU[0], MU[1]], 'beta_hz': [BETA[0], BETA[1]]},
        'frequency_step_hz': FREQUENCY_STEP,
        'sampling_rate_hz': SAMPLING_RATE,
        'window_seconds': WINDOW_SECONDS,
        'feature_order': 'channel-major, mu then beta',
        'mean': mean,
        'std': std,
        'centroids': centroids,
        'training': {
            'dataset': 'PhysioNet EEGMMIDB v1.0.0',
            'subject': 'S001',
            'train_runs': ['R04 (excerpt)'],
            'test_run': '',
            'in_sample_accuracy': in_sample_accuracy,
            'in_sample_confusion': confusion,
            'chance_accuracy': 0.5,
        },
        'preprocessing': (
            '4.1 s epochs; per-window mean removal; Hann window; Goertzel '
            'power at 0.5 Hz steps; log10 power; standardized features '
            '(population std across the 7 excerpt windows); nearest '
            'centroid in standardized space.'
        ),
        'limitations': (
            'Trained and evaluated on the same 60-second excerpt '
            '(in-sample): its accuracy is inflated and NOT comparable to '
            'held-out accuracy. Single subject (S001), small sample '
            '(7 windows), binary imagined fist task. Not a medical device '
            'and not mind reading.'
        ),
        'license': 'MIT for the code and weights; EEG data ODC-BY 1.0.',
    }
    OUT_PATH.write_text(json.dumps(model, indent=2) + '\n', encoding='utf-8')

    print(f'Wrote {OUT_PATH}')
    print(f'Task windows: {len(tasks)} (T1 left: '
          f'{sum(1 for _, label in tasks if label == "T1")}, T2 right: '
          f'{sum(1 for _, label in tasks if label == "T2")})')
    print(f'In-sample accuracy: {in_sample_accuracy:.3f} '
          f'({correct}/{len(tasks)}), confusion {confusion}')
    for onset, label, predicted, probability in predictions:
        print(f'  onset {onset:5.1f}s actual {label} -> '
              f'{"right" if predicted == 1 else "left "} '
              f'(p_right={probability:.3f})')


if __name__ == '__main__':
    main()
