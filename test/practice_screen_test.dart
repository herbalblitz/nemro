import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nemro/core/l10n/generated/app_localizations.dart';
import 'package:nemro/core/preferences/preferences_providers.dart';
import 'package:nemro/features/live/data/camera_proxy_analyzer.dart';
import 'package:nemro/features/live/data/live_camera_gateway.dart';
import 'package:nemro/features/practice/practice_screen.dart';

class _FakePracticeGateway implements LiveCameraGateway {
  _FakePracticeSession? session;

  @override
  Future<LiveCameraSession> start({
    CameraLensDirection lensDirection = CameraLensDirection.front,
  }) async {
    final next = _FakePracticeSession();
    session = next;
    return next;
  }
}

class _FakePracticeSession implements LiveCameraSession {
  final StreamController<LumaFrame> _controller =
      StreamController<LumaFrame>.broadcast();
  bool disposed = false;

  @override
  Stream<LumaFrame> get frames => _controller.stream;

  @override
  double get aspectRatio => 4 / 3;

  @override
  Widget buildPreview() =>
      const SizedBox(key: ValueKey('fake-practice-preview'));

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

Future<void> _pumpPractice(
  WidgetTester tester,
  _FakePracticeGateway gateway,
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
        home: PracticeScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Practice start shows the breathing phase and stop button', (
    tester,
  ) async {
    final gateway = _FakePracticeGateway();
    await _pumpPractice(tester, gateway);

    await tester.tap(find.byKey(const ValueKey('practice-start-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const ValueKey('practice-phase-label')), findsOneWidget);
    expect(find.byKey(const ValueKey('practice-stop-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('fake-practice-preview')), findsOneWidget);
  });

  testWidgets('Practice stop shows a summary', (tester) async {
    final gateway = _FakePracticeGateway();
    await _pumpPractice(tester, gateway);

    await tester.tap(find.byKey(const ValueKey('practice-start-button')));
    await tester.pump();
    gateway.session!.addFrame(_checkerboard());
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const ValueKey('practice-stop-button')));
    await tester.pumpAndSettle();

    expect(find.text('Practice summary'), findsOneWidget);
    expect(find.text('Practice again'), findsOneWidget);
  });

  testWidgets('Practice duration choice changes the remaining time', (
    tester,
  ) async {
    final gateway = _FakePracticeGateway();
    await _pumpPractice(tester, gateway);

    await tester.tap(find.byKey(const ValueKey('practice-duration-5')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('practice-start-button')));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('practice-remaining-label')),
      findsOneWidget,
    );
    // Remaining truncates to whole seconds, so the first frame shows
    // 05:00 or 04:59 depending on real milliseconds elapsed.
    expect(
      find.textContaining(RegExp(r'Remaining: 0[45]:\d\d')),
      findsOneWidget,
    );
  });

  testWidgets('Practice back while running ends the session, not the screen', (
    tester,
  ) async {
    final gateway = _FakePracticeGateway();
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
                    MaterialPageRoute(builder: (_) => const PracticeScreen()),
                  ),
                  child: const Text('Open practice'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open practice'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('practice-start-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pageBack();
    await tester.pump();

    expect(find.text('Practice summary'), findsOneWidget);
    expect(find.byKey(const ValueKey('practice-start-button')), findsOneWidget);
  });
}
