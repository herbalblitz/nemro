import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nemro/core/l10n/generated/app_localizations.dart';
import 'package:nemro/core/l10n/generated/app_localizations_en.dart';
import 'package:nemro/core/l10n/generated/app_localizations_vi.dart';
import 'package:nemro/core/preferences/preferences_providers.dart';
import 'package:nemro/features/live/data/camera_proxy_analyzer.dart';
import 'package:nemro/features/live/data/live_camera_gateway.dart';
import 'package:nemro/features/research/data/research_content.dart';
import 'package:nemro/features/research/research_screen.dart';

void main() {
  test('every milestone carries a limit and a source in both languages', () {
    for (final l10n in [AppLocalizationsEn(), AppLocalizationsVi()]) {
      final milestones = researchMilestones(l10n);
      expect(milestones, hasLength(4));
      for (final milestone in milestones) {
        expect(milestone.title, isNotEmpty);
        expect(milestone.body, isNotEmpty);
        expect(milestone.limit, isNotEmpty);
        expect(milestone.source, isNotEmpty);
      }
      final experiments = researchExperiments(l10n);
      expect(experiments, hasLength(2));
      for (final experiment in experiments) {
        expect(experiment.id, isNotEmpty);
        expect(experiment.title, isNotEmpty);
        expect(experiment.body, isNotEmpty);
        expect(experiment.reading, isNotEmpty);
      }
    }
  });

  test('only the dataset milestone links out', () {
    final milestones = researchMilestones(AppLocalizationsEn());
    expect(milestones.where((m) => m.url != null).map((m) => m.title), [
      '2004 — An open motor-imagery EEG dataset',
    ]);
  });

  testWidgets('Research milestone expands to body, limit, and source', (
    tester,
  ) async {
    final gateway = _FakeResearchGateway();
    await _pumpResearch(tester, gateway);

    await tester.tap(find.text('1929 — The first human EEG'));
    await tester.pump();

    expect(find.textContaining('Hans Berger'), findsWidgets);
    expect(find.textContaining('Limit:'), findsOneWidget);
    expect(find.textContaining('Berger, H. (1929)'), findsOneWidget);
  });

  testWidgets('Research experiment stop shows a result with its reading', (
    tester,
  ) async {
    final gateway = _FakeResearchGateway();
    await _pumpResearch(tester, gateway);

    await tester.ensureVisible(
      find.byKey(const ValueKey('research-start-still')),
    );
    await tester.tap(find.byKey(const ValueKey('research-start-still')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const ValueKey('research-stop-button')), findsOneWidget);

    gateway.session!.addFrame(_checkerboard());
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const ValueKey('research-stop-button')));
    await tester.pump();

    expect(find.text('Experiment result'), findsOneWidget);
    expect(find.textContaining('reacts to movement'), findsOneWidget);
  });

  testWidgets('Research back while running ends the run, not the screen', (
    tester,
  ) async {
    final gateway = _FakeResearchGateway();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          liveCameraGatewayProvider.overrideWithValue(gateway),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ResearchScreen()),
                  ),
                  child: const Text('Open research'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open research'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('research-start-cover')),
    );
    await tester.tap(find.byKey(const ValueKey('research-start-cover')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pageBack();
    await tester.pump();

    expect(find.text('Experiment result'), findsOneWidget);
  });
}

class _FakeResearchGateway implements LiveCameraGateway {
  _FakeResearchSession? session;

  @override
  Future<LiveCameraSession> start({
    CameraLensDirection lensDirection = CameraLensDirection.front,
  }) async {
    final next = _FakeResearchSession();
    session = next;
    return next;
  }
}

class _FakeResearchSession implements LiveCameraSession {
  final StreamController<LumaFrame> _controller =
      StreamController<LumaFrame>.broadcast();
  bool disposed = false;

  @override
  Stream<LumaFrame> get frames => _controller.stream;

  @override
  double get aspectRatio => 4 / 3;

  @override
  Widget buildPreview() =>
      const SizedBox(key: ValueKey('fake-research-preview'));

  void addFrame(LumaFrame frame) {
    if (!_controller.isClosed) _controller.add(frame);
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await _controller.close();
  }
}

LumaFrame _checkerboard({int size = 16}) {
  final pixels = Float32List(size * size);
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      pixels[y * size + x] = (x + y).isEven ? 0.85 : 0.15;
    }
  }
  return LumaFrame(width: size, height: size, pixels: pixels);
}

Future<void> _pumpResearch(
  WidgetTester tester,
  _FakeResearchGateway gateway,
) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        liveCameraGatewayProvider.overrideWithValue(gateway),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: ResearchScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
