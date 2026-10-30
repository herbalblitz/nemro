import 'dart:math' as math;

/// A fixed noisy dataset for the overfitting demo: twelve points whose
/// true shape is a gentle wave, plus fixed noise. The data never changes,
/// so the demo is reproducible and the unit test can pin its numbers.
///
/// x runs 0..1; the fit is done on t = 2x - 1 (in -1..1) because a raw
/// Vandermonde matrix on 0..1 is badly conditioned at high degrees.
const List<(double, double)> overfitPoints = [
  (0.0, 0.62),
  (0.09, 0.48),
  (0.18, 0.71),
  (0.27, 0.55),
  (0.36, 0.78),
  (0.45, 0.52),
  (0.55, 0.81),
  (0.64, 0.58),
  (0.73, 0.85),
  (0.82, 0.61),
  (0.91, 0.88),
  (1.0, 0.66),
];

/// Least-squares polynomial fit of [degree] on [overfitPoints], returned
/// as coefficients in t-space, lowest power first.
List<double> fitPolynomial(int degree) {
  final n = degree + 1;
  // Normal equations: A^T A c = A^T y, solved by Gaussian elimination
  // with partial pivoting.
  final ata = List.generate(n, (_) => List.filled(n, 0.0));
  final aty = List.filled(n, 0.0);
  for (final (x, y) in overfitPoints) {
    final t = 2 * x - 1;
    final powers = List.generate(
      2 * degree + 1,
      (i) => math.pow(t, i) as double,
    );
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n; j++) {
        ata[i][j] += powers[i + j];
      }
      aty[i] += powers[i] * y;
    }
  }
  // Augment and eliminate.
  final rows = List.generate(n, (i) => [...ata[i], aty[i]]);
  for (var col = 0; col < n; col++) {
    var pivot = col;
    for (var row = col + 1; row < n; row++) {
      if (rows[row][col].abs() > rows[pivot][col].abs()) pivot = row;
    }
    if (pivot != col) {
      final tmp = rows[col];
      rows[col] = rows[pivot];
      rows[pivot] = tmp;
    }
    final divisor = rows[col][col];
    if (divisor == 0) continue;
    for (var row = col + 1; row < n; row++) {
      final factor = rows[row][col] / divisor;
      for (var k = col; k <= n; k++) {
        rows[row][k] -= factor * rows[col][k];
      }
    }
  }
  final coeffs = List.filled(n, 0.0);
  for (var i = n - 1; i >= 0; i--) {
    var sum = rows[i][n];
    for (var j = i + 1; j < n; j++) {
      sum -= rows[i][j] * coeffs[j];
    }
    coeffs[i] = rows[i][i] == 0 ? 0 : sum / rows[i][i];
  }
  return coeffs;
}

double polynomialValue(List<double> coeffs, double x) {
  final t = 2 * x - 1;
  var value = 0.0;
  var power = 1.0;
  for (final c in coeffs) {
    value += c * power;
    power *= t;
  }
  return value;
}

/// Mean squared error of the fitted curve on the demo points.
/// Higher degrees always fit at least as well on these same points
/// (nested models), which is exactly why training error alone misleads.
double trainMeanSquaredError(List<double> coeffs) {
  var sum = 0.0;
  for (final (x, y) in overfitPoints) {
    final diff = polynomialValue(coeffs, x) - y;
    sum += diff * diff;
  }
  return sum / overfitPoints.length;
}
