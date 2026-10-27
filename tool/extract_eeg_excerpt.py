#!/usr/bin/env python3
"""Export a small, attributed EEG excerpt from an EEGMMIDB EDF file.

The app bundles the output CSV and JSON, not the raw EDF. This script uses only
the Python standard library.

Example:
    python3 tool/extract_eeg_excerpt.py \
        --edf /path/to/S001R04.edf \
        --csv assets/eeg/s001_r04_60s.csv \
        --json assets/eeg/s001_r04_60s.json \
        --seconds 60

EDF+ TAL onsets are absolute seconds, so they are used directly. Do not add the
record index to the onset; doing so shifts every marker later in the file.
"""

import argparse
import csv
import json
import struct
from pathlib import Path

DEFAULT_CHANNELS = ['C3', 'Cz', 'C4', 'FC3', 'FC4', 'CP3', 'CP4', 'Pz']
TASK_LABELS = ('T0', 'T1', 'T2')


def _field(raw, offset, width):
    return raw[offset:offset + width].decode('latin-1').strip()


def _parse_edf(path, wanted_channels):
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
    if abs(record_duration - 1.0) > 1e-9:
        raise ValueError('This exporter expects one-second EDF records.')

    signals = []
    for i in range(n_signals):
        def get(name, width, cast=str):
            offset = offsets[name] + i * width
            value = _field(raw, offset, width)
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
    indices = []
    for name in wanted_channels:
        key = name.upper()
        if key not in label_to_index:
            raise ValueError(f'Channel {name} is not in the EDF file.')
        indices.append(label_to_index[key])

    samples_per_record = signals[indices[0]]['spr']
    if any(signals[i]['spr'] != samples_per_record for i in indices):
        raise ValueError('Selected channels have different sampling rates.')

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
            # TAL onsets are absolute seconds; do not add the record index.
            if text in TASK_LABELS:
                events.append({
                    'onset': round(onset, 3),
                    'duration': duration,
                    'label': text,
                })

    return {
        'raw': raw,
        'data': data,
        'record_size': record_size,
        'n_records': n_records,
        'record_duration': record_duration,
        'samples_per_record': samples_per_record,
        'channel_offsets': channel_offsets,
        'indices': indices,
        'events': events,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--edf', type=Path, required=True)
    parser.add_argument('--csv', type=Path, required=True)
    parser.add_argument('--json', type=Path, required=True)
    parser.add_argument('--seconds', type=float, default=60.0)
    parser.add_argument('--subject', default='S001')
    parser.add_argument(
        '--run',
        default='R04 (imagined left/right fist)',
        help='Human-readable run description for the JSON sidecar.',
    )
    parser.add_argument(
        '--channels',
        nargs='+',
        default=DEFAULT_CHANNELS,
        help='Channel names in output order.',
    )
    args = parser.parse_args()

    parsed = _parse_edf(args.edf, args.channels)
    fs = parsed['samples_per_record'] / parsed['record_duration']
    total_duration = parsed['n_records'] * parsed['record_duration']
    if args.seconds <= 0 or args.seconds > total_duration:
        raise ValueError(
            f'--seconds must be in (0, {total_duration:.1f}].'
        )

    n_samples = int(round(args.seconds * fs))
    rows = []
    for n in range(n_samples):
        record = n // parsed['samples_per_record']
        sample = n % parsed['samples_per_record']
        block = parsed['data'][
            record * parsed['record_size']:(record + 1) * parsed['record_size']
        ]
        values = []
        for channel in parsed['indices']:
            offset = parsed['channel_offsets'][channel] + sample * 2
            values.append(
                struct.unpack_from('<h', block, offset)[0]
            )
        rows.append((n / fs, values))

    args.csv.parent.mkdir(parents=True, exist_ok=True)
    with args.csv.open('w', newline='', encoding='utf-8') as handle:
        writer = csv.writer(handle)
        writer.writerow(['time_s'] + list(args.channels))
        for timestamp, values in rows:
            writer.writerow([f'{timestamp:.4f}'] + values)

    events = [
        event for event in parsed['events']
        if event['onset'] < args.seconds
    ]
    metadata = {
        'source': 'PhysioNet EEG Motor Movement/Imagery Dataset (EEGMMIDB) v1.0.0',
        'doi': '10.13026/C28G6P',
        'subject': args.subject,
        'run': args.run,
        'sampling_rate_hz': fs,
        'channels': list(args.channels),
        'units': 'uV (digital units are 1:1 with physical uV in this file)',
        'duration_s': args.seconds,
        'events': events,
        'license': 'Open Data Commons Attribution License v1.0',
    }
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(
        json.dumps(metadata, indent=2) + '\n',
        encoding='utf-8',
    )

    print(f'Wrote {args.csv} ({len(rows)} samples x {len(args.channels)} channels)')
    print(f'Wrote {args.json} ({len(events)} markers)')
    for event in events:
        print(
            f'  {event["label"]:2s} onset={event["onset"]:6.2f}s '
            f'duration={event["duration"]}'
        )


if __name__ == '__main__':
    main()
