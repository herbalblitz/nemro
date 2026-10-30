import 'dart:math' as math;

/// A tiny multi-layer network that really learns: 2 inputs, 4 tanh
/// hidden units, 1 sigmoid output, trained by full-batch gradient
/// descent with hand-written backpropagation.
///
/// This is the network the perceptron card points at: a single line
/// cannot learn XOR, but this hidden layer can — by combining lines.
/// Nothing is faked: [train] runs the forward pass, the error, the
/// backward pass, and the weight update, and returns the loss it
/// actually measured along the way.
class XorSample {
  const XorSample(this.inputs, this.target);

  final List<double> inputs;
  final double target;
}

const List<XorSample> xorData = [
  XorSample([0, 0], 0),
  XorSample([0, 1], 1),
  XorSample([1, 0], 1),
  XorSample([1, 1], 0),
];

enum MlpInit { random, zeros }

class MlpModel {
  MlpModel._({
    required this.w1,
    required this.b1,
    required this.w2,
    required this.b2,
  });

  factory MlpModel.random({int seed = 42}) {
    final rand = math.Random(seed);
    double next() => rand.nextDouble() * 2 - 1;
    return MlpModel._(
      w1: List.generate(4, (_) => [next(), next()]),
      b1: List.filled(4, 0),
      w2: [
        [next(), next(), next(), next()],
      ],
      b2: [0],
    );
  }

  factory MlpModel.zeros() => MlpModel._(
    w1: List.generate(4, (_) => [0.0, 0.0]),
    b1: List.filled(4, 0),
    w2: [
      [0.0, 0.0, 0.0, 0.0],
    ],
    b2: [0],
  );

  /// Hidden weights [4][2].
  final List<List<double>> w1;

  /// Hidden biases [4].
  final List<double> b1;

  /// Output weights [1][4].
  final List<List<double>> w2;

  /// Output bias [1].
  final List<double> b2;

  double _sigmoid(double x) => 1 / (1 + math.exp(-x));

  double predict(List<double> inputs) {
    final hidden = List.generate(4, (i) {
      final pre = w1[i][0] * inputs[0] + w1[i][1] * inputs[1] + b1[i];
      return (math.exp(pre) - math.exp(-pre)) /
          (math.exp(pre) + math.exp(-pre));
    });
    var pre = b2[0];
    for (var i = 0; i < 4; i++) {
      pre += w2[0][i] * hidden[i];
    }
    return _sigmoid(pre);
  }

  int predictClass(List<double> inputs) => predict(inputs) >= 0.5 ? 1 : 0;

  double accuracy() {
    var correct = 0;
    for (final sample in xorData) {
      if (predictClass(sample.inputs) == sample.target.round()) correct++;
    }
    return correct / xorData.length;
  }

  double meanSquaredError() {
    var sum = 0.0;
    for (final sample in xorData) {
      final diff = predict(sample.inputs) - sample.target;
      sum += diff * diff;
    }
    return sum / xorData.length;
  }

  /// Trains on XOR and returns the mean squared error sampled every
  /// [sampleEvery] epochs, starting with the loss before training.
  List<double> train({
    int epochs = 5000,
    double lr = 0.5,
    int sampleEvery = 50,
  }) {
    final losses = <double>[meanSquaredError()];
    for (var epoch = 0; epoch < epochs; epoch++) {
      final gw1 = List.generate(4, (_) => [0.0, 0.0]);
      final gb1 = List.filled(4, 0.0);
      final gw2 = [
        [0.0, 0.0, 0.0, 0.0],
      ];
      final gb2 = [0.0];
      for (final sample in xorData) {
        final x = sample.inputs;
        final hiddenPre = List.generate(
          4,
          (i) => w1[i][0] * x[0] + w1[i][1] * x[1] + b1[i],
        );
        final hidden = hiddenPre
            .map(
              (pre) =>
                  (math.exp(pre) - math.exp(-pre)) /
                  (math.exp(pre) + math.exp(-pre)),
            )
            .toList();
        var outPre = b2[0];
        for (var i = 0; i < 4; i++) {
          outPre += w2[0][i] * hidden[i];
        }
        final out = _sigmoid(outPre);
        // dL/dout for mean squared error, averaged over the batch.
        final dout = 2 * (out - sample.target) / xorData.length;
        final doutPre = dout * out * (1 - out);
        for (var i = 0; i < 4; i++) {
          gw2[0][i] += doutPre * hidden[i];
        }
        gb2[0] += doutPre;
        for (var i = 0; i < 4; i++) {
          final dHidden = doutPre * w2[0][i];
          final dHiddenPre = dHidden * (1 - hidden[i] * hidden[i]);
          gw1[i][0] += dHiddenPre * x[0];
          gw1[i][1] += dHiddenPre * x[1];
          gb1[i] += dHiddenPre;
        }
      }
      for (var i = 0; i < 4; i++) {
        w1[i][0] -= lr * gw1[i][0];
        w1[i][1] -= lr * gw1[i][1];
        b1[i] -= lr * gb1[i];
      }
      for (var i = 0; i < 4; i++) {
        w2[0][i] -= lr * gw2[0][i];
      }
      b2[0] -= lr * gb2[0];
      if ((epoch + 1) % sampleEvery == 0) {
        losses.add(meanSquaredError());
      }
    }
    return losses;
  }
}
