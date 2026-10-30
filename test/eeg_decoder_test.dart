import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nemro/features/lab/data/eeg_decoder.dart';
import 'package:nemro/features/lab/data/eeg_decoder_repository.dart';
import 'package:nemro/features/lab/data/eeg_recording.dart';
import 'package:nemro/features/lab/data/eeg_repository.dart';

EegDecoderModel _syntheticModel() {
  return const EegDecoderModel(
    name: 'Synthetic test decoder',
    type: 'logistic_regression',
    classes: ['left_fist', 'right_fist'],
    channels: ['C3', 'C4'],
    muLow: 8,
    muHigh: 13,
    betaLow: 13,
    betaHigh: 30,
    frequencyStep: 0.5,
    samplingRate: 160,
    windowSeconds: 1,
    featureOrder: 'channel-major, mu then beta',
    mean: [0, 0, 0, 0],
    std: [1, 1, 1, 1],
    weights: [1, 0, -1, 0],
    bias: 0,
    training: EegDecoderTraining(
      dataset: 'Synthetic',
      subject: 'S000',
      trainRuns: [],
      testRun: '',
      trainEpochs: 0,
      heldOutAccuracy: 0,
      leaveOneRunOutAccuracy: 0,
      chanceAccuracy: 0.5,
      heldOutConfusion: [],
    ),
    preprocessing: 'test',
    limitations: 'test',
  );
}

EegRecording _recording({
  required List<List<double>> samples,
  double duration = 1,
  List<EegEvent> events = const [EegEvent(onset: 0, duration: 1, label: 'T1')],
}) {
  return EegRecording(
    source: 'Synthetic',
    doi: '10.0000/test',
    subject: 'S000',
    run: 'R00',
    license: 'test',
    units: 'uV',
    samplingRate: 160,
    channels: const ['C3', 'C4'],
    events: events,
    samples: samples,
    duration: duration,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the bundled decoder model has the expected shape', () async {
    final source = await rootBundle.loadString(eegDecoderModelAsset);
    final model = EegDecoderModel.fromJson(source);

    expect(model.channels, ['C3', 'C4', 'CP3', 'CP4']);
    expect(model.featureCount, 8);
    expect(model.samplingRate, 160);
    expect(model.windowSeconds, 4.1);
    expect(model.training.trainRuns, ['R08', 'R12']);
    expect(model.training.testRun, 'R04');
    expect(model.training.heldOutAccuracy, closeTo(0.667, 0.001));
    expect(model.training.leaveOneRunOutAccuracy, closeTo(0.6, 0.001));
  });

  test(
    'the decoder runs on every complete task in the bundled replay',
    () async {
      final modelSource = await rootBundle.loadString(eegDecoderModelAsset);
      final csv = await rootBundle.loadString(eegSampleCsvAsset);
      final metadata = await rootBundle.loadString(eegSampleMetadataAsset);
      final model = EegDecoderModel.fromJson(modelSource);
      final recording = EegRecording.parse(csv: csv, metadataJson: metadata);
      final decoder = EegDecoder(model);

      final tasks = recording.events
          .where(
            (event) =>
                event.kind == EegEventKind.leftFist ||
                event.kind == EegEventKind.rightFist,
          )
          .toList();
      expect(tasks, hasLength(7));

      for (final event in tasks) {
        final prediction = decoder.decode(recording, event);
        expect(prediction.rightProbability, inInclusiveRange(0, 1));
        expect(prediction.confidence, greaterThanOrEqualTo(0.5));
      }

      // Regression check: the Dart feature pipeline must match the Python
      // training pipeline for the first complete task in the bundled replay.
      final firstTask = tasks.firstWhere((event) => event.onset == 4.2);
      final firstPrediction = decoder.decode(recording, firstTask);
      expect(firstPrediction.rightProbability, closeTo(0.785649, 0.001));
    },
  );

  test('mu-band power separates a 10 Hz signal from a silent channel', () {
    final samples = List.generate(2, (channel) {
      if (channel == 1) return List<double>.filled(160, 0);
      return List.generate(
        160,
        (i) => 100 * math.sin(2 * math.pi * 10 * i / 160),
      );
    });
    final recording = _recording(samples: samples);
    final prediction = EegDecoder(_syntheticModel())
        .decode(recording, recording.events.first);

    expect(prediction.isRight, isTrue);
    expect(prediction.rightProbability, greaterThan(0.9));
  });

  test('the decoder rejects an incomplete task window', () {
    final recording = _recording(
      samples: List.generate(2, (_) => List<double>.filled(80, 0)),
      duration: 0.5,
      events: const [EegEvent(onset: 0, duration: 0.5, label: 'T1')],
    );

    expect(
      () =>
          EegDecoder(_syntheticModel())
              .decode(recording, recording.events.first),
      throwsStateError,
    );
  });

  test(
    'rejects a non-finite model number and falls back for chance accuracy',
    () async {
      final source = await rootBundle.loadString(eegDecoderModelAsset);

      // A string 'NaN' sampling rate must not slip past validation: NaN
      // comparisons are false, so the old `<= 0` check would have passed
      // it and broken decoding later.
      final mutated = jsonDecode(source) as Map<String, dynamic>;
      mutated['sampling_rate_hz'] = 'NaN';
      expect(
        () => EegDecoderModel.fromJson(jsonEncode(mutated)),
        throwsFormatException,
      );

      // Chance accuracy has a default, so an unusable value falls back
      // to it instead of failing the whole model.
      final chanceMutated = jsonDecode(source) as Map<String, dynamic>;
      (chanceMutated['training'] as Map<String, dynamic>)['chance_accuracy'] =
          'NaN';
      expect(
        EegDecoderModel.fromJson(jsonEncode(chanceMutated))
            .training
            .chanceAccuracy,
        0.5,
      );
    },
  );
}
