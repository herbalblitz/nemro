import 'package:flutter_test/flutter_test.dart';

import 'package:nemro/features/algorithms/data/attention_demo.dart';
import 'package:nemro/features/algorithms/data/mlp_trainer.dart';

void main() {
  test('random-start MLP learns XOR', () {
    final model = MlpModel.random();
    final losses = model.train();
    expect(model.accuracy(), 1.0);
    expect(model.meanSquaredError(), lessThan(0.01));
    expect(losses.first, greaterThan(losses.last));
    expect(losses.length, 101);
  });

  test('zero-start MLP stays stuck on XOR', () {
    final model = MlpModel.zeros();
    model.train();
    expect(model.accuracy(), lessThanOrEqualTo(0.5));
    expect(model.meanSquaredError(), greaterThan(0.2));
  });

  test('attention weights sum to 1 and shift with the query', () {
    final tokens = attentionTokens(['The', 'cat', 'chases', 'mouse']);
    final forChases = attentionWeights(tokens[2], tokens);
    final forThe = attentionWeights(tokens[0], tokens);
    expect(forChases.reduce((a, b) => a + b), closeTo(1.0, 1e-9));
    expect(forThe.reduce((a, b) => a + b), closeTo(1.0, 1e-9));
    // Self-attention peaks on the query word itself.
    expect(forChases[2], greaterThan(0.5));
    expect(forThe[0], greaterThan(0.5));
    // And the two queries distribute weight differently.
    expect(forChases[0], isNot(closeTo(forThe[0], 0.01)));
  });
}
