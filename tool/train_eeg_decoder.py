#!/usr/bin/env python3
"""Train the small, on-device EEG decoder used by Nemro's Lab.

This script uses only the Python standard library. It reads the public
EEGMMIDB EDF files, extracts 4.1-second imagined-fist windows, computes
mu/beta band power with a Goertzel filter, trains an L2-regularized logistic
regression, and writes the weights as JSON for the Flutter app.

The raw EDF files are not part of this repository. Download them from:
https://physionet.org/content/eegmmidb/1.0.0/

Example:
    python3 tool/train_eeg_decoder.py \
        --data-dir /path/to/eegmmidb/S001 \
        --out assets/models/eeg_decoder.json

The deployed model is trained on runs 8 and 12 and evaluated on the held-out
run 4, which is also the run bundled for the Lab replay. That keeps the demo
predictions out-of-sample for this subject.
"""

import argparse
import json
import math
import statistics
import struct
from pathlib import Path

CHANNELS = ['C3', 'C4', 'CP3', 'CP4']
WINDOW_SECONDS = 4.1
FREQUENCY_STEP = 0.5
MU = (8.0, 13.0)
BETA = (13.0, 30.0)
L2 = 0.1
LEARNING_RATE = 0.1
GRADIENT_EPOCHS = 4000


def _field(raw, offset, width):
    return raw[offset:offset + width].decode('latin-1').strip()


def parse_edf(path):
    """Parse the BCI2000-flavoured EDF used by EEGMMIDB."""
    raw = Path(path).read_bytes()
    header_bytes = int(_field(raw, 184, 8))
    n_records = int(_field(raw, 236, 8))
    record_duration = float(_field(raw, 244, 8))
    n_signals = int(_field(raw, 252, 4))

    offsets = {}
    cursor = 256
    for name, width in [
        ('label', 16), ('transducer', 80), ('dim', 8), ('phys_min', 8),
        ('phys_max', 8), ('dig_min', 8), ('dig_max', 8), ('prefilter', 80),
        ('spr', 8), ('reserved', 32),
    ]:
        offsets[name] = cursor
        cursor += n_signals * width
    if cursor != header_bytes:
        raise ValueError(f'Unexpected EDF header size: {cursor} != {header_bytes}')

    signals = []
    for i in range(n_signals):
        def get(name, width, cast=str):
            off = offsets[name] + i * width
            value = _field(raw, off, width)
            return cast(value) if value else None

        signals.append({
            'label': get('label', 16),
            'spr': get('spr', 8, int),
        })

    annotation_index = next(
        i for i, signal in enumerate(signals)
        if 'Annotations' in signal['label']
    )
    record_size = sum(signal['spr'] * 2 for signal in signals)
    data = raw[header_bytes:header_bytes + n_records * record_size]
    if len(data) != n_records * record_size:
        raise ValueError('EDF data section is truncated.')

    channel_offsets = []
    running = 0
    for signal in signals:
        channel_offsets.append(running)
        running += signal['spr'] * 2

    label_to_index = {
        signal['label'].rstrip('.').upper(): i
        for i, signal in enumerate(signals)
    }
    channels = {}
    for name in CHANNELS:
        index = label_to_index[name]
        spr = signals[index]['spr']
        values = []
        offset = channel_offsets[index]
        for record in range(n_records):
            block = data[record * record_size:(record + 1) * record_size]
            values.extend(struct.unpack_from(f'<{spr}h', block, offset))
        channels[name] = values

    annotation_offset = channel_offsets[annotation_index]
    annotation_length = signals[annotation_index]['spr'] * 2

    def decode_tals(block):
        out = []
        for chunk in block.split(b'\x00'):
            if not chunk:
                continue
            parts = chunk.replace(b'\x15', b'\x14').split(b'\x14')
            try:
                onset = float(parts[0].lstrip(b'+'))
            except ValueError:
                continue
            duration = None
            text = ''
            if len(parts) >= 3:
                try:
                    duration = float(parts[1])
                except ValueError:
                    duration = None
                text = parts[2].decode('latin-1')
            elif len(parts) == 2:
                text = parts[1].decode('latin-1')
            out.append((onset, duration, text))
        return out

    events = []
    for record in range(n_records):
        block = data[record * record_size:(record + 1) * record_size]
        annotation = block[annotation_offset:annotation_offset + annotation_length]
        for onset, duration, text in decode_tals(annotation):
            if text in ('T1', 'T2'):
                events.append({
                    'onset': onset,
                    'duration': duration,
                    'label': text,
                })

    fs = signals[label_to_index['C3']]['spr'] / record_duration
    return {
        'fs': fs,
        'duration': n_records * record_duration,
        'channels': channels,
        'events': events,
    }


def _hann_windowed(samples, start, length):
    mean = sum(samples[start:start + length]) / length
    return [
        (samples[start + i] - mean) *
        (0.5 * (1 - math.cos(2 * math.pi * i / (length - 1))))
        for i in range(length)
    ]


def _goertzel_power(samples, frequency, fs):
    omega = 2 * math.pi * frequency / fs
    coefficient = 2 * math.cos(omega)
    s0 = s1 = s2 = 0.0
    for sample in samples:
        s0 = sample + coefficient * s1 - s2
        s2 = s1
        s1 = s0
    return max(0.0, s1 * s1 + s2 * s2 - coefficient * s1 * s2)


def _band_power(windowed, low, high, fs):
    power = 0.0
    frequency = low
    while frequency < high - 1e-9:
        power += _goertzel_power(windowed, frequency, fs)
        frequency += FREQUENCY_STEP
    return math.log10(power + 1e-12)


def _features(recording, event):
    length = round(WINDOW_SECONDS * recording['fs'])
    start = round(event['onset'] * recording['fs'])
    out = []
    for name in CHANNELS:
        windowed = _hann_windowed(recording['channels'][name], start, length)
        out.append(_band_power(windowed, *MU, recording['fs']))
        out.append(_band_power(windowed, *BETA, recording['fs']))
    return out


def _fit_scaler(rows):
    columns = list(zip(*rows))
    mean = [sum(column) / len(column) for column in columns]
    std = [statistics.pstdev(column) or 1.0 for column in columns]
    return mean, std


def _scale(rows, mean, std):
    return [
        [(value - m) / s for value, m, s in zip(row, mean, std)]
        for row in rows
    ]


def _sigmoid(z):
    if z >= 0:
        return 1 / (1 + math.exp(-z))
    exp_z = math.exp(z)
    return exp_z / (1 + exp_z)


def _train_logreg(rows, labels):
    n = len(rows)
    d = len(rows[0])
    weights = [0.0] * d
    bias = 0.0
    for _ in range(GRADIENT_EPOCHS):
        grad_w = [0.0] * d
        grad_b = 0.0
        for row, label in zip(rows, labels):
            z = bias + sum(w * x for w, x in zip(weights, row))
            error = _sigmoid(z) - label
            for j in range(d):
                grad_w[j] += error * row[j]
            grad_b += error
        for j in range(d):
            weights[j] -= LEARNING_RATE * (grad_w[j] / n + L2 * weights[j])
        bias -= LEARNING_RATE * grad_b / n
    return weights, bias


def _predict(rows, weights, bias):
    return [
        1 if _sigmoid(bias + sum(w * x for w, x in zip(weights, row))) >= 0.5
        else 0
        for row in rows
    ]


def _evaluate(labels, predictions):
    correct = sum(1 for a, b in zip(labels, predictions) if a == b)
    confusion = [[0, 0], [0, 0]]
    for actual, predicted in zip(labels, predictions):
        confusion[actual][predicted] += 1
    return correct / len(labels), confusion


def _load_run(path):
    recording = parse_edf(path)
    rows, labels = [], []
    for event in recording['events']:
        if event['duration'] is None:
            continue
        if event['duration'] < WINDOW_SECONDS - 0.01:
            continue
        if event['onset'] + WINDOW_SECONDS > recording['duration']:
            continue
        rows.append(_features(recording, event))
        labels.append(0 if event['label'] == 'T1' else 1)
    return rows, labels, recording


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        '--data-dir',
        type=Path,
        required=True,
        help='Directory containing S001R04.edf, S001R08.edf, and S001R12.edf.',
    )
    parser.add_argument(
        '--subject',
        default='S001',
        help='Subject id used in the EDF filenames (default: S001).',
    )
    parser.add_argument(
        '--out',
        type=Path,
        default=Path('assets/models/eeg_decoder.json'),
        help='Output model JSON path.',
    )
    args = parser.parse_args()

    paths = {
        run: args.data_dir / f'{args.subject}R{run:02d}.edf'
        for run in (4, 8, 12)
    }
    data = {}
    for run, path in paths.items():
        rows, labels, recording = _load_run(path)
        data[run] = {'rows': rows, 'labels': labels, 'fs': recording['fs']}
        print(
            f'R{run:02d}: {len(rows)} trials, '
            f'left={labels.count(0)}, right={labels.count(1)}, '
            f'duration={recording["duration"]:.1f}s'
        )

    fold_accuracies = []
    fold_details = []
    for test_run in (4, 8, 12):
        train_runs = [run for run in (4, 8, 12) if run != test_run]
        train_rows = [
            row for run in train_runs for row in data[run]['rows']
        ]
        train_labels = [
            label for run in train_runs for label in data[run]['labels']
        ]
        test_rows = data[test_run]['rows']
        test_labels = data[test_run]['labels']
        mean, std = _fit_scaler(train_rows)
        weights, bias = _train_logreg(_scale(train_rows, mean, std), train_labels)
        predictions = _predict(_scale(test_rows, mean, std), weights, bias)
        accuracy, confusion = _evaluate(test_labels, predictions)
        fold_accuracies.append(accuracy)
        fold_details.append({
            'test_run': f'R{test_run:02d}',
            'accuracy': accuracy,
            'confusion': confusion,
        })
        print(f'LORO test R{test_run:02d}: accuracy={accuracy:.3f}, '
              f'confusion={confusion}')
    loro_accuracy = sum(fold_accuracies) / len(fold_accuracies)
    print(f'LORO mean accuracy: {loro_accuracy:.3f}')

    train_runs = [8, 12]
    train_rows = [row for run in train_runs for row in data[run]['rows']]
    train_labels = [label for run in train_runs for label in data[run]['labels']]
    test_rows = data[4]['rows']
    test_labels = data[4]['labels']
    mean, std = _fit_scaler(train_rows)
    weights, bias = _train_logreg(_scale(train_rows, mean, std), train_labels)
    predictions = _predict(_scale(test_rows, mean, std), weights, bias)
    held_out_accuracy, held_out_confusion = _evaluate(test_labels, predictions)
    print(f'Held-out R04 accuracy: {held_out_accuracy:.3f}, '
          f'confusion={held_out_confusion}')

    model = {
        'name': f'{args.subject} mu/beta logistic regression',
        'version': 1,
        'type': 'logistic_regression',
        'classes': ['left_fist', 'right_fist'],
        'channels': CHANNELS,
        'bands': {'mu_hz': list(MU), 'beta_hz': list(BETA)},
        'frequency_step_hz': FREQUENCY_STEP,
        'sampling_rate_hz': data[4]['fs'],
        'window_seconds': WINDOW_SECONDS,
        'feature_order': 'channel-major, mu then beta',
        'mean': mean,
        'std': std,
        'weights': weights,
        'bias': bias,
        'training': {
            'dataset': 'PhysioNet EEGMMIDB v1.0.0',
            'subject': args.subject,
            'train_runs': [f'R{run:02d}' for run in train_runs],
            'test_run': 'R04',
            'train_epochs': GRADIENT_EPOCHS,
            'train_trials': len(train_rows),
            'class_counts': {
                'left': train_labels.count(0),
                'right': train_labels.count(1),
            },
            'held_out_accuracy': held_out_accuracy,
            'held_out_confusion': held_out_confusion,
            'leave_one_run_out_accuracy': loro_accuracy,
            'leave_one_run_out_folds': fold_details,
            'chance_accuracy': 0.5,
        },
        'preprocessing': (
            '4.1 s epochs; per-window mean removal; Hann window; Goertzel '
            'power at 0.5 Hz steps; log10 power; standardized features.'
        ),
        'limitations': (
            'Single subject (S001), small sample, binary imagined fist task. '
            'Not a medical device and not mind reading.'
        ),
        'license': 'MIT for the code and weights; EEG data ODC-BY 1.0.',
    }

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(model, indent=2) + '\n', encoding='utf-8')
    print(f'Wrote {args.out}')


if __name__ == '__main__':
    main()
