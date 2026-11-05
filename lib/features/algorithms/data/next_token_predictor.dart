import 'dart:math' as math;

/// A first-order Markov next-token model: it counts which token followed
/// which in the training sequence, and nothing else.
///
/// This is the honest ancestor of the transformer: the same job —
/// predict the next token — with a memory of exactly one token instead
/// of attention over the whole sequence. Its misses are the point: with
/// one token of context, many futures look equally plausible, so the
/// model must sample from a distribution rather than state one answer.
///
/// Sampling follows the same two knobs the Kronos demo exposes:
/// temperature flattens (high) or sharpens (low) the distribution, and
/// top-p keeps only the smallest set of tokens whose probabilities sum
/// to at least [topP]. A fixed [Random] seed makes every run
/// reproducible, so the widget and the tests agree.
class MarkovPredictor {
  MarkovPredictor(this.bins);

  final int bins;

  final Map<int, List<int>> _counts = {};

  /// Counts every adjacent pair in [tokens]. Calling it twice trains
  /// twice: the caller owns the training sequence.
  void train(List<int> tokens) {
    for (var i = 0; i + 1 < tokens.length; i++) {
      final from = tokens[i];
      final to = tokens[i + 1];
      if (from < 0 || from >= bins || to < 0 || to >= bins) continue;
      _counts.putIfAbsent(from, () => List<int>.filled(bins, 0));
      _counts[from]![to]++;
    }
  }

  /// The probability distribution over the next token after [token].
  /// An unseen token has no counts, so it falls back to uniform: the
  /// model says plainly that it has never seen this context before.
  List<double> distributionAfter(int token) {
    final counts = _counts[token];
    if (counts == null) return List<double>.filled(bins, 1.0 / bins);
    final total = counts.fold<int>(0, (sum, c) => sum + c);
    if (total == 0) return List<double>.filled(bins, 1.0 / bins);
    return counts.map((c) => c / total).toList();
  }

  /// Samples one next token after [current], with temperature-scaled
  /// probabilities filtered to the top-p nucleus.
  int sampleNext(
    int current, {
    double temperature = 1.0,
    double topP = 1.0,
    math.Random? random,
  }) {
    final rand = random ?? math.Random();
    final base = distributionAfter(current);
    final t = temperature <= 0 ? 0.05 : temperature;
    // Temperature scaling on log-probabilities: T below 1 sharpens the
    // distribution towards the most frequent follower, T above 1
    // flattens it towards uniform.
    final scaled = base.map((p) => math.pow(p, 1.0 / t).toDouble()).toList();
    final sum = scaled.fold<double>(0, (a, b) => a + b);
    final probs = sum <= 0
        ? List<double>.filled(bins, 1.0 / bins)
        : scaled.map((p) => p / sum).toList();
    // Nucleus filter: keep the most probable tokens until their mass
    // reaches topP, always keeping at least the single most probable.
    final order = List<int>.generate(bins, (i) => i)
      ..sort((a, b) => probs[b].compareTo(probs[a]));
    final kept = <int>[];
    var mass = 0.0;
    for (final index in order) {
      kept.add(index);
      mass += probs[index];
      if (mass >= topP) break;
    }
    final keptSum = kept.fold<double>(0, (s, i) => s + probs[i]);
    var roll = rand.nextDouble() * keptSum;
    for (final index in kept) {
      roll -= probs[index];
      if (roll <= 0) return index;
    }
    return kept.last;
  }

  /// Rolls forward [steps] tokens from [start], feeding each sample back
  /// as the next context. Errors compound: step 24 is a guess built on
  /// guesses, which is why long rollouts drift.
  List<int> rollOut(
    int start,
    int steps, {
    double temperature = 1.0,
    double topP = 1.0,
    int seed = 42,
  }) {
    final rand = math.Random(seed);
    final out = <int>[];
    var current = start;
    for (var i = 0; i < steps; i++) {
      current = sampleNext(
        current,
        temperature: temperature,
        topP: topP,
        random: rand,
      );
      out.add(current);
    }
    return out;
  }
}

/// Fraction of positions where [predicted] equals [actual]. Both lists
/// must be the same length; comparing sequences of different lengths is
/// a caller error, not a score.
double sequenceAccuracy(List<int> predicted, List<int> actual) {
  assert(predicted.length == actual.length);
  if (actual.isEmpty) return 0;
  var correct = 0;
  for (var i = 0; i < actual.length; i++) {
    if (predicted[i] == actual[i]) correct++;
  }
  return correct / actual.length;
}
