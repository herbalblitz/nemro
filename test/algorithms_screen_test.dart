import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nemro/core/l10n/generated/app_localizations.dart';
import 'package:nemro/features/algorithms/algorithms_screen.dart';

void main() {
  Future<void> pumpAlgorithms(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AlgorithmsScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Algorithms screen trains the demo perceptron to 100%', (
    tester,
  ) async {
    await pumpAlgorithms(tester);

    expect(find.text('Algorithms that build AI'), findsOneWidget);
    expect(find.text('Teach a line to separate two classes'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('algorithms-demo-perceptron')),
    );
    await tester.tap(find.byKey(const ValueKey('algorithms-demo-perceptron')));
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const ValueKey('algorithms-train-perceptron')),
    );
    await tester.tap(find.byKey(const ValueKey('algorithms-train-perceptron')));
    await tester.pump();

    expect(find.text('Accuracy: 100%'), findsOneWidget);
  });

  testWidgets('MLP experiment trains XOR to 100%', (tester) async {
    await pumpAlgorithms(tester);

    await tester.ensureVisible(
      find.byKey(const ValueKey('algorithms-train-mlp')),
    );
    await tester.tap(find.byKey(const ValueKey('algorithms-train-mlp')));
    await tester.pump();

    expect(find.text('Accuracy: 100%'), findsOneWidget);
  });

  testWidgets('Gradient run with the default rate converges', (tester) async {
    await pumpAlgorithms(tester);

    await tester.ensureVisible(
      find.byKey(const ValueKey('algorithms-run-gradient')),
    );
    await tester.tap(find.byKey(const ValueKey('algorithms-run-gradient')));
    await tester.pump();

    expect(find.textContaining('Converged:'), findsOneWidget);
  });
}
