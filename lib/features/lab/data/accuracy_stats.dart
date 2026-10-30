import 'dart:math' as math;

/// A two-sided confidence interval for a binomial proportion.
class WilsonInterval {
  const WilsonInterval({required this.low, required this.high});

  /// Lower bound, 0..1.
  final double low;

  /// Upper bound, 0..1.
  final double high;
}

/// The 95% Wilson score interval for [successes] out of [trials].
///
/// Wilson is used instead of the normal approximation because the held-out
/// sample is tiny (15 trials) and proportions near 0 or 1 would otherwise
/// produce an interval outside 0..1. With 10/15 the interval is roughly
/// 41.7%–84.8%, which is the honest context for the point estimate.
WilsonInterval wilson95Interval(int successes, int trials) {
  if (trials <= 0) return const WilsonInterval(low: 0, high: 1);

  final n = trials.toDouble();
  final p = (successes / n).clamp(0.0, 1.0);
  const z = 1.959963984540054;
  final zSquared = z * z;
  final denominator = 1 + zSquared / n;
  final center = (p + zSquared / (2 * n)) / denominator;
  final margin =
      z * math.sqrt((p * (1 - p) + zSquared / (4 * n)) / n) / denominator;

  return WilsonInterval(
    low: (center - margin).clamp(0.0, 1.0),
    high: (center + margin).clamp(0.0, 1.0),
  );
}
