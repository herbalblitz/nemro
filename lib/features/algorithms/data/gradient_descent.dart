/// Gradient descent on the toy loss f(x) = x^2, starting from x = 2.
///
/// The loss is a parabola with its minimum at 0, so the walk is easy to
/// follow: each step moves against the slope (2x) by [learningRate].
/// A small rate crawls to the minimum, a rate near 1 jumps straight to
/// it, and a rate above 1 overshoots further every step and diverges.
/// The classification at the end is fixed, not fitted to look good.
enum DescentOutcome { converged, notYet, diverged }

class DescentResult {
  const DescentResult({required this.positions, required this.outcome});

  /// Every visited x, starting with the start point.
  final List<double> positions;

  final DescentOutcome outcome;

  double get finalLoss {
    final x = positions.last;
    return x * x;
  }
}

DescentResult runGradientDescent({
  required double learningRate,
  double start = 2.0,
  int steps = 60,
}) {
  final positions = <double>[start];
  var x = start;
  for (var i = 0; i < steps; i++) {
    x -= learningRate * 2 * x;
    positions.add(x);
    if (x.abs() > 10) {
      return DescentResult(
        positions: positions,
        outcome: DescentOutcome.diverged,
      );
    }
  }
  final outcome = x.abs() < 0.05
      ? DescentOutcome.converged
      : DescentOutcome.notYet;
  return DescentResult(positions: positions, outcome: outcome);
}
