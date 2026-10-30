import 'dart:math' as math;

/// A tiny self-attention computation with fixed 2D vectors, so the
/// weights are fully determined and the unit test can pin them.
///
/// Each token is its own query and key. Picking a query word scores it
/// against every key by dot product, then a softmax turns the scores
/// into weights that sum to 1. The output for that word would be the
/// weighted average of the values — arithmetic, not understanding.
/// Vectors are scaled by 3 so the softmax is sharp enough to read.
class AttentionToken {
  const AttentionToken(this.word, this.vector);

  final String word;

  /// 2D query = key vector.
  final (double, double) vector;
}

List<AttentionToken> attentionTokens(List<String> words) {
  const vectors = [(3.0, 0.0), (2.4, 1.8), (0.0, 3.0), (1.8, 2.4)];
  return List.generate(
    words.length,
    (i) => AttentionToken(words[i], vectors[i % vectors.length]),
  );
}

/// Softmax attention weights of [query] over [tokens], in token order.
List<double> attentionWeights(
  AttentionToken query,
  List<AttentionToken> tokens,
) {
  final scores = tokens.map((token) {
    final (qx, qy) = query.vector;
    final (kx, ky) = token.vector;
    return qx * kx + qy * ky;
  }).toList();
  final maxScore = scores.reduce(math.max);
  final exps = scores.map((s) => math.exp(s - maxScore)).toList();
  final sum = exps.reduce((a, b) => a + b);
  return exps.map((e) => e / sum).toList();
}
