import 'package:flutter_test/flutter_test.dart';

import 'package:nemro/core/l10n/generated/app_localizations_en.dart';
import 'package:nemro/core/l10n/generated/app_localizations_vi.dart';
import 'package:nemro/features/algorithms/data/algorithm_content.dart';
import 'package:nemro/features/algorithms/data/gradient_descent.dart';
import 'package:nemro/features/algorithms/data/overfit_demo.dart';
import 'package:nemro/features/algorithms/data/perceptron_trainer.dart';

void main() {
  test(
    'every algorithm card carries a limit and a source in both languages',
    () {
      for (final l10n in [AppLocalizationsEn(), AppLocalizationsVi()]) {
        final cards = algorithmCards(l10n);
        expect(cards, hasLength(4));
        for (final card in cards) {
          expect(card.title, isNotEmpty);
          expect(card.body, isNotEmpty);
          expect(card.limit, isNotEmpty);
          expect(card.source, isNotEmpty);
        }
      }
    },
  );

  test('perceptron learns the separable demo set', () {
    final model = PerceptronModel();
    final epochs = model.train(demoSeparablePoints);
    expect(epochs, lessThanOrEqualTo(100));
    expect(model.accuracy(demoSeparablePoints), 1.0);
  });

  test('perceptron cannot separate identical points with opposite labels', () {
    final model = PerceptronModel();
    const points = [LabeledPoint(0.5, 0.5, 0), LabeledPoint(0.5, 0.5, 1)];
    final epochs = model.train(points, maxEpochs: 10);
    expect(epochs, 10);
    expect(model.mistakes(points), greaterThan(0));
  });

  test('gradient descent converges, stalls, and diverges by step size', () {
    final small = runGradientDescent(learningRate: 0.1);
    expect(small.outcome, DescentOutcome.converged);
    expect(small.finalLoss, lessThan(0.01));

    final edge = runGradientDescent(learningRate: 0.99);
    expect(edge.outcome, DescentOutcome.notYet);

    final huge = runGradientDescent(learningRate: 1.2);
    expect(huge.outcome, DescentOutcome.diverged);
  });

  test('polynomial fit returns degree + 1 coefficients', () {
    expect(fitPolynomial(1), hasLength(2));
    expect(fitPolynomial(3), hasLength(4));
    expect(fitPolynomial(9), hasLength(10));
  });

  test('training error never rises with degree on the same points', () {
    final e1 = trainMeanSquaredError(fitPolynomial(1));
    final e3 = trainMeanSquaredError(fitPolynomial(3));
    final e9 = trainMeanSquaredError(fitPolynomial(9));
    expect(e1, greaterThanOrEqualTo(e3 - 1e-9));
    expect(e3, greaterThanOrEqualTo(e9 - 1e-9));
  });

  test('polynomial value uses t-space', () {
    // Coeffs [2, 3] mean 2 + 3t with t = 2x - 1; at x = 0.5, t = 0.
    expect(polynomialValue([2, 3], 0.5), 2.0);
  });
}
