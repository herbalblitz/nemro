import 'dart:math' as math;

/// A fixed, deterministic toy signal: two slow waves plus seeded noise,
/// normalized into [0, 1]. It stands in for any continuous stream — a
/// market's candles, a sensor's brightness — because tokenization does
/// not care what the numbers mean, only how they move.
///
/// The seed is fixed so the demo, the widget, and the tests all see the
/// same signal: nothing here is cherry-picked per run.
List<double> demoSignal({int length = 96, int seed = 42}) {
  final rand = math.Random(seed);
  return List<double>.generate(length, (i) {
    final t = i / length;
    final value =
        0.5 +
        0.28 * math.sin(2 * math.pi * t * 3) +
        0.14 * math.sin(2 * math.pi * t * 7 + 1.3) +
        (rand.nextDouble() - 0.5) * 0.16;
    return value.clamp(0.0, 1.0);
  });
}

/// Quantizes each value into one of [bins] discrete tokens, 0..[bins]-1.
///
/// This is stage one of the Kronos idea, shrunk to toy size: a continuous
/// number becomes a word from a fixed vocabulary. The mapping is lossy
/// on purpose — every value inside a bin becomes the same token — and
/// that loss is exactly what the tokenizer experiment shows.
List<int> tokenizeSignal(List<double> values, int bins) {
  assert(bins >= 2, 'tokenization needs at least 2 bins');
  return values.map((value) {
    final clamped = value.clamp(0.0, 1.0);
    final token = (clamped * bins).floor();
    return token >= bins ? bins - 1 : token;
  }).toList();
}

/// Counts how many times each token appears. The counts always sum to
/// the number of tokens: a histogram that loses nothing is a bug.
List<int> tokenHistogram(List<int> tokens, int bins) {
  final counts = List<int>.filled(bins, 0);
  for (final token in tokens) {
    if (token >= 0 && token < bins) counts[token]++;
  }
  return counts;
}
