import 'dart:convert';
import 'dart:math' as math;

import 'package:nemro/features/lab/data/eeg_recording.dart';

/// Metadata about how the bundled decoder was trained and evaluated.
class EegDecoderTraining {
  const EegDecoderTraining({
    required this.dataset,
    required this.subject,
    required this.trainRuns,
    required this.testRun,
    required this.trainEpochs,
    required this.heldOutAccuracy,
    required this.leaveOneRunOutAccuracy,
    required this.chanceAccuracy,
    required this.heldOutConfusion,
  });

  final String dataset;
  final String subject;
  final List<String> trainRuns;
  final String testRun;
  final int trainEpochs;
  final double heldOutAccuracy;
  final double leaveOneRunOutAccuracy;
  final double chanceAccuracy;
  final List<List<int>> heldOutConfusion;

  factory EegDecoderTraining.fromJson(Map<String, dynamic> json) {
    return EegDecoderTraining(
      dataset: _readString(json['dataset'], fallback: 'Unknown dataset'),
      subject: _readString(json['subject']),
      trainRuns: _readStringList(json['train_runs']),
      testRun: _readString(json['test_run']),
      trainEpochs: _readInt(json['train_epochs']),
      heldOutAccuracy: _readDouble(json['held_out_accuracy']),
      leaveOneRunOutAccuracy: _readDouble(json['leave_one_run_out_accuracy']),
      chanceAccuracy: _readDouble(json['chance_accuracy'], fallback: 0.5),
      heldOutConfusion: _readConfusion(json['held_out_confusion']),
    );
  }
}

/// A trained linear decoder for imagined left/right fist movements.
///
/// The model consumes channel-major mu/beta log-power features. Class 0 is the
/// left fist and class 1 is the right fist, matching the order in [classes].
class EegDecoderModel {
  const EegDecoderModel({
    required this.name,
    required this.type,
    required this.classes,
    required this.channels,
    required this.muLow,
    required this.muHigh,
    required this.betaLow,
    required this.betaHigh,
    required this.frequencyStep,
    required this.samplingRate,
    required this.windowSeconds,
    required this.featureOrder,
    required this.mean,
    required this.std,
    required this.weights,
    required this.bias,
    required this.training,
    required this.preprocessing,
    required this.limitations,
  });

  final String name;
  final String type;
  final List<String> classes;
  final List<String> channels;
  final double muLow;
  final double muHigh;
  final double betaLow;
  final double betaHigh;
  final double frequencyStep;
  final double samplingRate;
  final double windowSeconds;
  final String featureOrder;
  final List<double> mean;
  final List<double> std;
  final List<double> weights;
  final double bias;
  final EegDecoderTraining training;
  final String preprocessing;
  final String limitations;

  int get featureCount => weights.length;
  int get expectedFeatureCount => channels.length * 2;

  factory EegDecoderModel.fromJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Decoder model must be a JSON object.');
    }

    final bands = decoded['bands'];
    if (bands is! Map<String, dynamic>) {
      throw const FormatException('Decoder model is missing bands.');
    }
    final mu = _readRange(bands['mu_hz']);
    final beta = _readRange(bands['beta_hz']);

    final training = decoded['training'];
    if (training is! Map<String, dynamic>) {
      throw const FormatException('Decoder model is missing training data.');
    }

    final model = EegDecoderModel(
      name: _readString(decoded['name'], fallback: 'EEG decoder'),
      type: _readString(decoded['type'], fallback: 'logistic_regression'),
      classes: _readStringList(decoded['classes']),
      channels: _readStringList(decoded['channels']),
      muLow: mu[0],
      muHigh: mu[1],
      betaLow: beta[0],
      betaHigh: beta[1],
      frequencyStep: _readDouble(decoded['frequency_step_hz']),
      samplingRate: _readDouble(decoded['sampling_rate_hz']),
      windowSeconds: _readDouble(decoded['window_seconds']),
      featureOrder: _readString(decoded['feature_order']),
      mean: _readDoubleList(decoded['mean']),
      std: _readDoubleList(decoded['std']),
      weights: _readDoubleList(decoded['weights']),
      bias: _readDouble(decoded['bias']),
      training: EegDecoderTraining.fromJson(training),
      preprocessing: _readString(decoded['preprocessing']),
      limitations: _readString(decoded['limitations']),
    );

    if (model.classes.length != 2) {
      throw const FormatException('Decoder model needs exactly two classes.');
    }
    if (model.channels.isEmpty) {
      throw const FormatException('Decoder model has no channels.');
    }
    if (model.featureCount != model.expectedFeatureCount) {
      throw const FormatException(
        'Decoder weights do not match the channel count.',
      );
    }
    if (model.mean.length != model.featureCount ||
        model.std.length != model.featureCount) {
      throw const FormatException(
        'Decoder normalization arrays do not match the weights.',
      );
    }
    if (model.samplingRate <= 0 ||
        model.windowSeconds <= 0 ||
        model.frequencyStep <= 0) {
      throw const FormatException('Decoder model has invalid timing values.');
    }
    if (model.std.any((value) => !value.isFinite || value <= 0)) {
      throw const FormatException('Decoder model has invalid std values.');
    }
    if (model.mean.any((value) => !value.isFinite) ||
        model.weights.any((value) => !value.isFinite)) {
      throw const FormatException('Decoder model has non-finite values.');
    }
    if (model.muLow >= model.muHigh || model.betaLow >= model.betaHigh) {
      throw const FormatException('Decoder model has invalid band edges.');
    }
    return model;
  }
}

/// The decoder's output for one task window.
class EegPrediction {
  const EegPrediction({required this.rightProbability});

  /// Probability assigned to the right-fist class.
  final double rightProbability;

  double get leftProbability => 1 - rightProbability;
  double get confidence =>
      math.max(rightProbability, leftProbability).clamp(0.0, 1.0);
  bool get isRight => rightProbability >= 0.5;
}

/// Runs the bundled model entirely on-device.
class EegDecoder {
  const EegDecoder(this.model);

  final EegDecoderModel model;

  EegPrediction decode(EegRecording recording, EegEvent event) {
    if ((recording.samplingRate - model.samplingRate).abs() > 1e-6) {
      throw StateError(
        'Decoder expects ${model.samplingRate} Hz; '
        'recording is ${recording.samplingRate} Hz.',
      );
    }

    final length = (model.windowSeconds * model.samplingRate).round();
    final start = (event.onset * recording.samplingRate).round();
    if (start < 0 || start + length > recording.sampleCount) {
      throw StateError('Task window is incomplete.');
    }

    final features = <double>[];
    for (final channelName in model.channels) {
      final channel = recording.channels.indexOf(channelName);
      if (channel < 0) {
        throw StateError('Recording is missing channel $channelName.');
      }
      final windowed = _windowed(recording.samples[channel], start, length);
      features.add(
        _bandPower(
          windowed,
          model.muLow,
          model.muHigh,
          model.frequencyStep,
          model.samplingRate,
        ),
      );
      features.add(
        _bandPower(
          windowed,
          model.betaLow,
          model.betaHigh,
          model.frequencyStep,
          model.samplingRate,
        ),
      );
    }

    var logit = model.bias;
    for (var i = 0; i < features.length; i++) {
      final normalized = (features[i] - model.mean[i]) / model.std[i];
      logit += model.weights[i] * normalized;
    }
    final rightProbability = 1 / (1 + math.exp(-logit));
    return EegPrediction(rightProbability: rightProbability);
  }
}

List<double> _windowed(List<double> samples, int start, int length) {
  if (length < 2) {
    throw StateError('Decoder window is too short.');
  }
  var mean = 0.0;
  for (var i = 0; i < length; i++) {
    mean += samples[start + i];
  }
  mean /= length;

  final windowed = List<double>.filled(length, 0);
  for (var i = 0; i < length; i++) {
    final hann = 0.5 * (1 - math.cos(2 * math.pi * i / (length - 1)));
    windowed[i] = (samples[start + i] - mean) * hann;
  }
  return windowed;
}

double _bandPower(
  List<double> windowed,
  double low,
  double high,
  double step,
  double samplingRate,
) {
  var power = 0.0;
  for (var frequency = low; frequency < high - 1e-9; frequency += step) {
    power += _goertzelPower(windowed, frequency, samplingRate);
  }
  return math.log(power + 1e-12) / math.ln10;
}

double _goertzelPower(
  List<double> samples,
  double frequency,
  double samplingRate,
) {
  final omega = 2 * math.pi * frequency / samplingRate;
  final coefficient = 2 * math.cos(omega);
  var s0 = 0.0;
  var s1 = 0.0;
  var s2 = 0.0;
  for (final sample in samples) {
    s0 = sample + coefficient * s1 - s2;
    s2 = s1;
    s1 = s0;
  }
  final power = s1 * s1 + s2 * s2 - coefficient * s1 * s2;
  return power.isFinite && power > 0 ? power : 0.0;
}

List<double> _readRange(Object? value) {
  final values = _readDoubleList(value);
  if (values.length != 2) {
    throw const FormatException('Decoder band must have two edges.');
  }
  return values;
}

List<double> _readDoubleList(Object? value) {
  if (value is! List) {
    throw const FormatException('Decoder model has an invalid list.');
  }
  return value.map(_readDouble).toList();
}

List<String> _readStringList(Object? value) {
  if (value is! List) return const [];
  return value.map((item) => item.toString()).toList();
}

List<List<int>> _readConfusion(Object? value) {
  if (value is! List) return const [];
  return value
      .map((row) => row is List ? row.map(_readInt).toList() : const <int>[])
      .toList();
}

String _readString(Object? value, {String fallback = ''}) {
  return value is String && value.isNotEmpty ? value : fallback;
}

double _readDouble(Object? value, {double? fallback}) {
  // double.tryParse accepts 'NaN' and 'Infinity'. A NaN sampling rate or
  // band edge would slip past the `<= 0` validation (NaN comparisons are
  // false) and break decoding later, so a non-finite value counts as
  // unusable: fall back when a fallback exists, otherwise throw.
  double? parsed;
  if (value is num) {
    parsed = value.toDouble();
  } else if (value is String) {
    parsed = double.tryParse(value);
  }
  if (parsed == null || !parsed.isFinite) {
    if (fallback != null) return fallback;
    throw const FormatException('Decoder model has an invalid number.');
  }
  return parsed;
}

int _readInt(Object? value, {int? fallback}) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
  }
  if (fallback != null) return fallback;
  throw const FormatException('Decoder model has an invalid integer.');
}
