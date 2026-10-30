import 'package:material_ui/material_ui.dart';

import 'package:nemro/core/l10n/generated/app_localizations.dart';
import 'package:nemro/features/algorithms/data/algorithm_content.dart';
import 'package:nemro/features/algorithms/data/gradient_descent.dart';
import 'package:nemro/features/algorithms/data/overfit_demo.dart';
import 'package:nemro/features/algorithms/data/perceptron_trainer.dart';

/// Algorithms that build AI: four landmark algorithms, each with its
/// limit and source, plus three experiments that run real training
/// on-device with toy data.
///
/// Nothing here trains a powerful model and nothing here measures a
/// mental state. The demos teach how the algorithms move: a line that
/// learns from mistakes, a walk downhill, and a curve that memorises.
class AlgorithmsScreen extends StatelessWidget {
  const AlgorithmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cards = algorithmCards(l10n);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.algorithmsTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.algorithmsSubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.algorithmsHonestNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.algorithmsCardsTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            for (final card in cards) ...[
              _AlgorithmCard(card: card, l10n: l10n),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 24),
            Text(
              l10n.algorithmsExperimentsTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            const _PerceptronExperiment(),
            const SizedBox(height: 10),
            const _GradientExperiment(),
            const SizedBox(height: 10),
            const _OverfitExperiment(),
          ],
        ),
      ),
    );
  }
}

class _AlgorithmCard extends StatelessWidget {
  const _AlgorithmCard({required this.card, required this.l10n});

  final AlgorithmCard card;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              card.body,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.researchLimitLabel}: ${card.limit}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.researchSourceLabel}: ${card.source}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerceptronExperiment extends StatefulWidget {
  const _PerceptronExperiment();

  @override
  State<_PerceptronExperiment> createState() => _PerceptronExperimentState();
}

class _PerceptronExperimentState extends State<_PerceptronExperiment> {
  final _points = <LabeledPoint>[];
  var _selectedClass = 0;
  PerceptronModel? _model;
  int? _epochs;

  void _addPoint(Offset local, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final x = (local.dx / size.width).clamp(0.0, 1.0);
    final y = (local.dy / size.height).clamp(0.0, 1.0);
    setState(() {
      _points.add(LabeledPoint(x, y, _selectedClass));
      _model = null;
      _epochs = null;
    });
  }

  void _train() {
    final model = PerceptronModel();
    final epochs = model.train(_points);
    setState(() {
      _model = model;
      _epochs = epochs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accuracy = _model == null
        ? null
        : (_model!.accuracy(_points) * 100).round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.algorithmsExperimentPerceptronTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.algorithmsExperimentPerceptronBody,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, 260);
                return GestureDetector(
                  onTapDown: (details) =>
                      _addPoint(details.localPosition, size),
                  child: CustomPaint(
                    size: size,
                    painter: _ScatterPainter(points: _points, model: _model),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.algorithmsPerceptronClassA),
                  selected: _selectedClass == 0,
                  onSelected: (_) => setState(() => _selectedClass = 0),
                ),
                ChoiceChip(
                  label: Text(l10n.algorithmsPerceptronClassB),
                  selected: _selectedClass == 1,
                  onSelected: (_) => setState(() => _selectedClass = 1),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  key: const ValueKey('algorithms-demo-perceptron'),
                  onPressed: () => setState(() {
                    _points
                      ..clear()
                      ..addAll(demoSeparablePoints);
                    _model = null;
                    _epochs = null;
                  }),
                  child: Text(l10n.algorithmsPerceptronDemo),
                ),
                FilledButton(
                  key: const ValueKey('algorithms-train-perceptron'),
                  onPressed: _points.isEmpty ? null : _train,
                  child: Text(l10n.algorithmsPerceptronTrain),
                ),
                OutlinedButton(
                  onPressed: () => setState(() {
                    _points.clear();
                    _model = null;
                    _epochs = null;
                  }),
                  child: Text(l10n.algorithmsPerceptronClear),
                ),
              ],
            ),
            if (accuracy != null && _epochs != null) ...[
              const SizedBox(height: 12),
              Text(l10n.algorithmsPerceptronAccuracy(accuracy)),
              Text(l10n.algorithmsPerceptronEpochs(_epochs!)),
            ],
            const SizedBox(height: 8),
            Text(
              l10n.algorithmsExperimentPerceptronReading,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws the unit square, the placed points, and the learned line.
class _ScatterPainter extends CustomPainter {
  const _ScatterPainter({required this.points, required this.model});

  final List<LabeledPoint> points;
  final PerceptronModel? model;

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = const Color(0xFF9AA0A6)
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Offset.zero & size, border);
    final model = this.model;
    if (model != null && (model.w0 != 0 || model.w1 != 0)) {
      final line = _lineIntersections(model);
      if (line.length == 2) {
        final paint = Paint()
          ..color = const Color(0xFF1A73E8)
          ..strokeWidth = 2;
        canvas.drawLine(
          Offset(line[0].dx * size.width, line[0].dy * size.height),
          Offset(line[1].dx * size.width, line[1].dy * size.height),
          paint,
        );
      }
    }
    for (final point in points) {
      final paint = Paint()
        ..color = point.label == 0
            ? const Color(0xFFD93025)
            : const Color(0xFF1A73E8);
      canvas.drawCircle(
        Offset(point.x * size.width, point.y * size.height),
        7,
        paint,
      );
    }
  }

  /// The two points where w0*x + w1*y + bias = 0 crosses the unit square.
  List<Offset> _lineIntersections(PerceptronModel model) {
    final found = <Offset>[];
    void add(double x, double y) {
      if (x < -1e-9 || x > 1 + 1e-9 || y < -1e-9 || y > 1 + 1e-9) return;
      final offset = Offset(x.clamp(0.0, 1.0), y.clamp(0.0, 1.0));
      if (found.every((p) => (p - offset).distance > 1e-6)) found.add(offset);
    }

    if (model.w1.abs() > 1e-9) {
      add(0, -model.bias / model.w1);
      add(1, -(model.w0 + model.bias) / model.w1);
    }
    if (model.w0.abs() > 1e-9) {
      add(-model.bias / model.w0, 0);
      add(-(model.w1 + model.bias) / model.w0, 1);
    }
    return found.length >= 2 ? found.sublist(0, 2) : found;
  }

  @override
  bool shouldRepaint(_ScatterPainter old) =>
      old.points != points || old.model != model;
}

class _GradientExperiment extends StatefulWidget {
  const _GradientExperiment();

  @override
  State<_GradientExperiment> createState() => _GradientExperimentState();
}

class _GradientExperimentState extends State<_GradientExperiment> {
  var _learningRate = 0.1;
  DescentResult? _result;

  String _resultText(AppLocalizations l10n, DescentResult result) {
    switch (result.outcome) {
      case DescentOutcome.converged:
        return l10n.algorithmsGradientConverged(
          result.finalLoss.toStringAsFixed(4),
        );
      case DescentOutcome.diverged:
        return l10n.algorithmsGradientDiverged;
      case DescentOutcome.notYet:
        return l10n.algorithmsGradientNotYet(result.positions.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final result = _result;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.algorithmsExperimentGradientTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.algorithmsExperimentGradientBody,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 12),
            CustomPaint(
              size: const Size(double.infinity, 220),
              painter: _ParabolaPainter(result: result),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.algorithmsGradientLearningRate(
                _learningRate.toStringAsFixed(2),
              ),
            ),
            Slider(
              value: _learningRate,
              min: 0.05,
              max: 1.2,
              divisions: 23,
              onChanged: (value) => setState(() {
                _learningRate = value;
                _result = null;
              }),
            ),
            FilledButton(
              key: const ValueKey('algorithms-run-gradient'),
              onPressed: () => setState(
                () => _result = runGradientDescent(learningRate: _learningRate),
              ),
              child: Text(l10n.algorithmsGradientRun),
            ),
            if (result != null) ...[
              const SizedBox(height: 12),
              Text(_resultText(l10n, result)),
            ],
            const SizedBox(height: 8),
            Text(
              l10n.algorithmsExperimentGradientReading,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws f(x) = x^2 over x in [-3, 3] and the descent steps on it.
class _ParabolaPainter extends CustomPainter {
  const _ParabolaPainter({required this.result});

  final DescentResult? result;

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = const Color(0xFF9AA0A6)
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Offset.zero & size, border);
    double px(double x) => (x + 3) / 6 * size.width;
    double py(double loss) => size.height - (loss / 9) * size.height;
    final curve = Paint()
      ..color = const Color(0xFF9AA0A6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path();
    for (var i = 0; i <= 60; i++) {
      final x = -3 + i * 0.1;
      final point = Offset(px(x), py(x * x));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(path, curve);
    final result = this.result;
    if (result == null) return;
    Offset? previous;
    for (final x in result.positions) {
      if (x < -3 || x > 3) {
        previous = null;
        continue;
      }
      final point = Offset(px(x), py(x * x));
      if (previous != null) {
        canvas.drawLine(
          previous,
          point,
          Paint()
            ..color = const Color(0xFF1A73E8)
            ..strokeWidth = 2,
        );
      }
      canvas.drawCircle(point, 4, Paint()..color = const Color(0xFFD93025));
      previous = point;
    }
  }

  @override
  bool shouldRepaint(_ParabolaPainter old) => old.result != result;
}

class _OverfitExperiment extends StatefulWidget {
  const _OverfitExperiment();

  @override
  State<_OverfitExperiment> createState() => _OverfitExperimentState();
}

class _OverfitExperimentState extends State<_OverfitExperiment> {
  var _degree = 1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final coeffs = fitPolynomial(_degree);
    final error = trainMeanSquaredError(coeffs);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.algorithmsExperimentOverfitTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.algorithmsExperimentOverfitBody,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 12),
            CustomPaint(
              size: const Size(double.infinity, 220),
              painter: _CurvePainter(coeffs: coeffs),
            ),
            const SizedBox(height: 8),
            Text(l10n.algorithmsOverfitDegree(_degree)),
            Slider(
              value: _degree.toDouble(),
              min: 1,
              max: 9,
              divisions: 8,
              onChanged: (value) => setState(() => _degree = value.round()),
            ),
            Text(l10n.algorithmsOverfitTrainError(error.toStringAsFixed(4))),
            const SizedBox(height: 8),
            Text(
              l10n.algorithmsExperimentOverfitReading,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws the fixed demo points and the fitted polynomial curve.
class _CurvePainter extends CustomPainter {
  const _CurvePainter({required this.coeffs});

  final List<double> coeffs;

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = const Color(0xFF9AA0A6)
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Offset.zero & size, border);
    final curve = Paint()
      ..color = const Color(0xFF1A73E8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    for (var i = 0; i <= 60; i++) {
      final x = i / 60;
      final y = polynomialValue(coeffs, x).clamp(0.0, 1.0);
      final point = Offset(x * size.width, size.height - y * size.height);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(path, curve);
    for (final (x, y) in overfitPoints) {
      canvas.drawCircle(
        Offset(x * size.width, size.height - y * size.height),
        5,
        Paint()..color = const Color(0xFFD93025),
      );
    }
  }

  @override
  bool shouldRepaint(_CurvePainter old) => old.coeffs != coeffs;
}
