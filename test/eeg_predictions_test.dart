import 'package:flutter_test/flutter_test.dart';

import 'package:nemro/features/lab/data/eeg_decoder.dart';
import 'package:nemro/features/lab/data/eeg_decoder_repository.dart';
import 'package:nemro/features/lab/data/eeg_recording.dart';

const _channels = ['C3', 'C4', 'CP3', 'CP4'];

EegDecoder _testDecoder() {
  return const EegDecoder(
    EegDecoderModel(
      name: 'Test decoder',
      type: 'logistic_regression',
      classes: ['left_fist', 'right_fist'],
      channels: _channels,
      muLow: 8,
      muHigh: 13,
      betaLow: 13,
      betaHigh: 30,
      frequencyStep: 0.5,
      samplingRate: 160,
      windowSeconds: 4.1,
      featureOrder: 'channel-major, mu then beta',
      mean: [0, 0, 0, 0, 0, 0, 0, 0],
      std: [1, 1, 1, 1, 1, 1, 1, 1],
      weights: [0, 0, 0, 0, 0, 0, 0, 0],
      bias: 0,
      training: EegDecoderTraining(
        dataset: 'Test dataset',
        subject: 'S001',
        trainRuns: ['R08', 'R12'],
        testRun: 'R04',
        trainEpochs: 4000,
        heldOutAccuracy: 0.667,
        leaveOneRunOutAccuracy: 0.6,
        chanceAccuracy: 0.5,
        heldOutConfusion: [
          [5, 3],
          [2, 5],
        ],
      ),
      preprocessing: 'Test preprocessing',
      limitations: 'Test limitations',
    ),
  );
}

/// A synthetic 10-second, 160 Hz recording: one window that decodes fine
/// and one whose model window runs past the end of the samples.
EegRecording _recordingWithOverflowWindow() {
  final csv = StringBuffer('time_s,${_channels.join(',')}\n');
  for (var i = 0; i < 1600; i++) {
    csv.write('${(i / 160).toStringAsFixed(4)},0,0,0,0\n');
  }
  return EegRecording.parse(
    csv: csv.toString(),
    metadataJson: '''
{
  "channels": ["C3", "C4", "CP3", "CP4"],
  "sampling_rate_hz": 160,
  "duration_s": 10,
  "events": [
    {"onset": 0.0, "duration": 4.1, "label": "T1"},
    {"onset": 9.0, "duration": 1.0, "label": "T2"}
  ]
}
''',
  );
}

EegRecording _recordingMissingDecoderChannel() {
  final csv = StringBuffer('time_s,C3,C4\n');
  for (var i = 0; i < 1600; i++) {
    csv.write('${(i / 160).toStringAsFixed(4)},0,0\n');
  }
  return EegRecording.parse(
    csv: csv.toString(),
    metadataJson: '''
{
  "channels": ["C3", "C4"],
  "sampling_rate_hz": 160,
  "duration_s": 10,
  "events": [
    {"onset": 0.0, "duration": 4.1, "label": "T1"}
  ]
}
''',
  );
}

void main() {
  test('a window that fails to decode is skipped, not fatal', () {
    final predictions = decodeAllEvents(
      _testDecoder(),
      _recordingWithOverflowWindow(),
    );

    // The 9.0s window ends at 10.0s (inside the recording) but its 4.1s
    // model window runs past the last sample, so decode throws — and
    // must not take the valid 0.0s prediction down with it.
    expect(predictions.keys, [0.0]);
    expect(predictions[0.0], isNotNull);
  });

  test('a recording missing a model channel yields no prediction', () {
    final predictions = decodeAllEvents(
      _testDecoder(),
      _recordingMissingDecoderChannel(),
    );

    expect(predictions, isEmpty);
  });
}
