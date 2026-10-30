/// A tiny perceptron that learns a line between two classes, on-device.
///
/// Coordinates live in the unit square (0..1, 0..1) and labels are 0 or 1.
/// The classic update rule moves the line a little every time it
/// misclassifies a point; on linearly separable data it converges to a
/// separating line, and on overlapping data it never settles — which is
/// itself the lesson the demo teaches.
class LabeledPoint {
  const LabeledPoint(this.x, this.y, this.label);

  final double x;
  final double y;

  /// 0 or 1.
  final int label;
}

/// A preset separable set used by the demo button and the unit tests:
/// class 0 sums to at most 0.7, class 1 to at least 1.3, so the line
/// x + y = 1 separates them.
const List<LabeledPoint> demoSeparablePoints = [
  LabeledPoint(0.2, 0.2, 0),
  LabeledPoint(0.3, 0.3, 0),
  LabeledPoint(0.25, 0.4, 0),
  LabeledPoint(0.7, 0.7, 1),
  LabeledPoint(0.8, 0.6, 1),
  LabeledPoint(0.75, 0.85, 1),
];

class PerceptronModel {
  PerceptronModel({this.w0 = 0, this.w1 = 0, this.bias = 0});

  double w0;
  double w1;
  double bias;

  int predict(double x, double y) => (w0 * x + w1 * y + bias) >= 0 ? 1 : 0;

  int mistakes(List<LabeledPoint> points) {
    var count = 0;
    for (final point in points) {
      if (predict(point.x, point.y) != point.label) count++;
    }
    return count;
  }

  double accuracy(List<LabeledPoint> points) {
    if (points.isEmpty) return 0;
    return 1 - mistakes(points) / points.length;
  }

  /// Runs full passes over [points] until a pass makes no mistakes or
  /// [maxEpochs] passes are done. Returns the number of passes run.
  int train(List<LabeledPoint> points, {int maxEpochs = 100}) {
    var epochs = 0;
    while (epochs < maxEpochs) {
      var madeMistake = false;
      for (final point in points) {
        // Map label 0/1 to -1/+1 for the classic update rule.
        final target = point.label == 1 ? 1.0 : -1.0;
        final score = w0 * point.x + w1 * point.y + bias;
        final predicted = score >= 0 ? 1.0 : -1.0;
        if (predicted != target) {
          w0 += target * point.x;
          w1 += target * point.y;
          bias += target;
          madeMistake = true;
        }
      }
      epochs++;
      if (!madeMistake) break;
    }
    return epochs;
  }
}
