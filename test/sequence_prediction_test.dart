import 'package:flutter_test/flutter_test.dart';

import 'package:nemro/features/algorithms/data/next_token_predictor.dart';
import 'package:nemro/features/algorithms/data/signal_tokenizer.dart';

void main() {
  test('demo signal stays in [0, 1] and is deterministic', () {
    final first = demoSignal();
    final second = demoSignal();
    expect(first, hasLength(96));
    expect(first, equals(second));
    for (final value in first) {
      expect(value, greaterThanOrEqualTo(0.0));
      expect(value, lessThanOrEqualTo(1.0));
    }
  });

  test('tokenizer maps values to bins, clamping the top edge', () {
    expect(tokenizeSignal([0.0, 0.24, 0.25, 0.99, 1.0], 4), [0, 0, 1, 3, 3]);
    expect(tokenizeSignal([-0.5, 1.5], 4), [0, 3]);
  });

  test('histogram counts sum to the token count', () {
    final tokens = tokenizeSignal(demoSignal(), 8);
    final histogram = tokenHistogram(tokens, 8);
    expect(histogram, hasLength(8));
    expect(histogram.fold<int>(0, (sum, c) => sum + c), tokens.length);
  });

  test('Markov distribution sums to 1 and peaks on the seen follower', () {
    final predictor = MarkovPredictor(4)..train([0, 1, 0, 1, 0, 2]);
    final dist = predictor.distributionAfter(0);
    expect(dist.reduce((a, b) => a + b), closeTo(1.0, 1e-9));
    expect(dist[1], closeTo(2 / 3, 1e-9));
    expect(dist[2], closeTo(1 / 3, 1e-9));
    expect(dist[0], 0.0);
  });

  test('unseen context falls back to uniform', () {
    final predictor = MarkovPredictor(4)..train([0, 1, 2]);
    expect(predictor.distributionAfter(3), [0.25, 0.25, 0.25, 0.25]);
  });

  test('rollout length matches steps and stays in vocabulary', () {
    final predictor = MarkovPredictor(8)
      ..train(tokenizeSignal(demoSignal(), 8).sublist(0, 72));
    final out = predictor.rollOut(3, 24, seed: 42);
    expect(out, hasLength(24));
    for (final token in out) {
      expect(token, greaterThanOrEqualTo(0));
      expect(token, lessThan(8));
    }
    // Same seed, same rollout: sampling is reproducible.
    expect(predictor.rollOut(3, 24, seed: 42), out);
  });

  test('sequence accuracy counts exact matches only', () {
    expect(sequenceAccuracy([0, 1, 2], [0, 1, 2]), 1.0);
    expect(sequenceAccuracy([0, 1, 2], [0, 2, 2]), closeTo(2 / 3, 1e-9));
    expect(sequenceAccuracy([0, 0], [1, 1]), 0.0);
  });
}
