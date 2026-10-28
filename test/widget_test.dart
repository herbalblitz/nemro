import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nemro/app.dart';
import 'package:nemro/core/preferences/preferences_providers.dart';
import 'package:nemro/core/router/app_router.dart';
import 'package:nemro/features/home/home_screen.dart';
import 'package:nemro/features/insights/insights_screen.dart';
import 'package:nemro/features/insights/session_exporter.dart';
import 'package:nemro/features/lab/data/eeg_decoder.dart';
import 'package:nemro/features/lab/data/eeg_decoder_repository.dart';
import 'package:nemro/features/lab/data/eeg_recording.dart';
import 'package:nemro/features/lab/data/eeg_repository.dart';
import 'package:nemro/features/live/data/attention_analyzer.dart';
import 'package:nemro/features/live/data/frame_throttler.dart';
import 'package:nemro/features/live/data/live_camera_gateway.dart';
import 'package:nemro/features/live/data/live_session_summary.dart';
import 'package:nemro/features/live/data/system_settings_opener.dart';
import 'package:nemro/features/live/live_screen.dart';

/// Test double for the export share sheet: records the summaries handed
/// to it instead of writing a file, because real file I/O cannot
/// complete inside a widget test's fake async zone. The real file write
/// is covered by test/session_exporter_test.dart.
class _CapturingExporter extends SessionExporter {
  _CapturingExporter(this.captured)
      : super(
          tempDirectory: () async => Directory.systemTemp,
          shareFile: (_) async {},
        );

  final List<LiveSessionSummary> captured;

  @override
  Future<String> export(List<LiveSessionSummary> summaries) async {
    captured.addAll(summaries);
    return 'nemro-sessions.csv';
  }
}

Future<void> _pumpApp(
  WidgetTester tester, {
  Map<String, Object> values = const {'locale': 'vi'},
  EegRecording? labRecording,
  EegDecoder? labDecoder,
  Map<double, EegPrediction>? labPredictions,
  ValueNotifier<bool>? failLabLoad,
  LiveCameraGateway? liveCameraGateway,
  SystemSettingsOpener? systemSettingsOpener,
  FrameThrottler? frameThrottler,
  SessionExporter? sessionExporter,
  GoRouter? routerOverride,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        if (labRecording != null)
          eegRecordingProvider.overrideWith((ref) => labRecording)
        else if (failLabLoad != null)
          eegRecordingProvider.overrideWith((ref) async {
            if (failLabLoad.value) {
              throw Exception('Test load failure');
            }
            return _testRecording();
          }),
        if (labDecoder != null)
          eegDecoderProvider.overrideWith((ref) => labDecoder),
        if (labPredictions != null)
          eegPredictionsProvider.overrideWith((ref) => labPredictions),
        if (liveCameraGateway != null)
          liveCameraGatewayProvider.overrideWithValue(liveCameraGateway),
        if (systemSettingsOpener != null)
          systemSettingsOpenerProvider.overrideWithValue(systemSettingsOpener),
        if (frameThrottler != null)
          frameThrottlerProvider.overrideWithValue(frameThrottler),
        if (sessionExporter != null)
          sessionExporterProvider.overrideWithValue(sessionExporter),
        if (routerOverride != null)
          routerProvider.overrideWithValue(routerOverride),
      ],
      child: const NemroApp(),
    ),
  );
  await tester.pumpAndSettle();
}

EegRecording _testRecording() {
  return EegRecording(
    source: 'Test dataset',
    doi: '10.0000/test',
    subject: 'S001',
    run: 'R04',
    license: 'ODC-BY 1.0',
    units: 'uV',
    samplingRate: 160,
    channels: const ['C3', 'Cz'],
    events: const [
      EegEvent(onset: 0, duration: 4.1, label: 'T1'),
      EegEvent(onset: 6, duration: 4.1, label: 'T2'),
    ],
    samples: List.generate(2, (_) => List<double>.filled(12 * 160, 0)),
    duration: 12,
  );
}

EegDecoder _testDecoder() {
  return const EegDecoder(
    EegDecoderModel(
      name: 'Test decoder',
      type: 'logistic_regression',
      classes: ['left_fist', 'right_fist'],
      channels: ['C3', 'Cz'],
      muLow: 8,
      muHigh: 13,
      betaLow: 13,
      betaHigh: 30,
      frequencyStep: 0.5,
      samplingRate: 160,
      windowSeconds: 4.1,
      featureOrder: 'channel-major, mu then beta',
      mean: [0, 0, 0, 0],
      std: [1, 1, 1, 1],
      weights: [0, 0, 0, 0],
      bias: 0,
      training: EegDecoderTraining(
        dataset: 'Test dataset',
        subject: 'S001',
        trainRuns: ['R08', 'R12'],
        testRun: 'R04',
        trainEpochs: 4000,
        heldOutAccuracy: 0.667,
        leaveOneRunOutAccuracy: 0.6,
        chanceAccuracy: 0.5,
        heldOutConfusion: [
          [5, 3],
          [2, 5],
        ],
      ),
      preprocessing: 'Test preprocessing',
      limitations: 'Test limitations',
    ),
  );
}

Map<double, EegPrediction> _testPredictions() {
  return {
    0.0: const EegPrediction(rightProbability: 0.72),
    6.0: const EegPrediction(rightProbability: 0.36),
  };
}

/// Same as [_testDecoder] but with no held-out run: the accuracy line
/// must fall back to the leave-one-run-out value and say so.
EegDecoder _testDecoderNoTestRun() {
  return const EegDecoder(
    EegDecoderModel(
      name: 'Test decoder',
      type: 'logistic_regression',
      classes: ['left_fist', 'right_fist'],
      channels: ['C3', 'Cz'],
      muLow: 8,
      muHigh: 13,
      betaLow: 13,
      betaHigh: 30,
      frequencyStep: 0.5,
      samplingRate: 160,
      windowSeconds: 4.1,
      featureOrder: 'channel-major, mu then beta',
      mean: [0, 0, 0, 0],
      std: [1, 1, 1, 1],
      weights: [0, 0, 0, 0],
      bias: 0,
      training: EegDecoderTraining(
        dataset: 'Test dataset',
        subject: 'S001',
        trainRuns: ['R08', 'R12'],
        testRun: '',
        trainEpochs: 4000,
        heldOutAccuracy: 0.667,
        leaveOneRunOutAccuracy: 0.6,
        chanceAccuracy: 0.5,
        heldOutConfusion: [
          [5, 3],
          [2, 5],
        ],
      ),
      preprocessing: 'Test preprocessing',
      limitations: 'Test limitations',
    ),
  );
}

class _FakeLiveCameraGateway implements LiveCameraGateway {
  _FakeLiveCameraSession? session;
  LiveCameraException? failure;
  CameraLensDirection? lastLensDirection;
  int starts = 0;

  @override
  Future<LiveCameraSession> start({
    CameraLensDirection lensDirection = CameraLensDirection.front,
  }) async {
    starts++;
    lastLensDirection = lensDirection;
    final error = failure;
    if (error != null) throw error;
    final next = _FakeLiveCameraSession();
    session = next;
    return next;
  }
}

class _FakeSystemSettingsOpener implements SystemSettingsOpener {
  int calls = 0;

  @override
  Future<void> openAppSettings() async {
    calls++;
  }
}

class _FakeLiveCameraSession implements LiveCameraSession {
  final StreamController<LumaFrame> _controller =
      StreamController<LumaFrame>.broadcast();
  bool disposed = false;

  @override
  Stream<LumaFrame> get frames => _controller.stream;

  @override
  double get aspectRatio => 4 / 3;

  @override
  Widget buildPreview() =>
      Container(key: const ValueKey('fake-live-preview'), color: Colors.black);

  void addFrame(LumaFrame frame) {
    if (!_controller.isClosed) _controller.add(frame);
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await _controller.close();
  }
}

LumaFrame _liveCheckerboard({int size = 16}) {
  final pixels = Float32List(size * size);
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      pixels[y * size + x] = (x + y).isEven ? 0.85 : 0.15;
    }
  }
  return LumaFrame(width: size, height: size, pixels: pixels);
}

LumaFrame _liveBlank({int size = 16}) {
  final pixels = Float32List(size * size);
  for (var i = 0; i < pixels.length; i++) {
    pixels[i] = 0.5;
  }
  return LumaFrame(width: size, height: size, pixels: pixels);
}

/// Low-contrast checkerboard: same mean as blank, but a central contrast
/// of 0.05, so it scores in the middle band instead of near zero.
LumaFrame _liveSoftCheckerboard({int size = 16}) {
  final pixels = Float32List(size * size);
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      pixels[y * size + x] = (x + y).isEven ? 0.55 : 0.45;
    }
  }
  return LumaFrame(width: size, height: size, pixels: pixels);
}

void main() {
  testWidgets('first launch shows the onboarding screen', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Nemro'), findsWidgets);
    expect(find.text('Đồng ý và tiếp tục'), findsOneWidget);
    expect(find.text('Tôi đã hiểu và đồng ý'), findsOneWidget);
  });

  testWidgets('language can be switched during onboarding', (tester) async {
    await _pumpApp(tester);

    final english = find.text('English');
    await tester.ensureVisible(english);
    await tester.tap(english);
    await tester.pumpAndSettle();

    expect(find.text('Agree and continue'), findsOneWidget);
    expect(find.text('Choose your language'), findsOneWidget);
  });

  testWidgets('onboarding completion opens home', (tester) async {
    await _pumpApp(tester);

    final checkbox = find.byType(Checkbox);
    await tester.ensureVisible(checkbox);
    await tester.tap(checkbox);
    await tester.pump();

    final continueButton = find.text('Đồng ý và tiếp tục');
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.text('Vòng lặp AI–não, trong tầm tay.'), findsOneWidget);
    expect(find.text('Trang chủ'), findsOneWidget);
  });

  testWidgets('Lab replays the bundled EEG sample', (tester) async {
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      labRecording: _testRecording(),
      labDecoder: _testDecoder(),
      labPredictions: _testPredictions(),
    );

    final openLab = find.text('Open Lab');
    await tester.ensureVisible(openLab);
    await tester.tap(openLab);
    await tester.pumpAndSettle();

    expect(find.text('EEG replay'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);

    // The recording selector above the list pushes Play below the fold;
    // scrollUntilVisible stops early because the list's cache extent
    // already built it, so bring it on screen explicitly.
    await tester.ensureVisible(find.text('Play'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Pause'), findsOneWidget);

    await tester.tap(find.text('Pause'));
    await tester.pumpAndSettle();
    expect(find.text('Play'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('AI decoder'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('AI decoder'), findsOneWidget);
    expect(find.text('Prediction'), findsOneWidget);
    final predictionLabel = tester.widget<Text>(
      find.byKey(const ValueKey('decoder-prediction-label')),
    );
    expect(predictionLabel.data, 'Right fist imagery');
    expect(find.textContaining('Held-out accuracy: 67%'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Lab renders in Vietnamese on a narrow screen', (tester) async {
    await _pumpApp(
      tester,
      values: {'locale': 'vi', 'onboarding_complete': true},
      labRecording: _testRecording(),
      labDecoder: _testDecoder(),
      labPredictions: _testPredictions(),
    );

    final openLab = find.text('Mở Lab');
    await tester.ensureVisible(openLab);
    await tester.tap(openLab);
    await tester.pumpAndSettle();

    expect(find.text('Phát lại EEG'), findsOneWidget);
    expect(find.text('Phát'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Bộ giải mã AI'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Bộ giải mã AI'), findsOneWidget);
    expect(find.text('Dự đoán'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('main tabs render on a phone-sized screen', (tester) async {
    await _pumpApp(
      tester,
      values: {'locale': 'vi', 'onboarding_complete': true},
    );

    expect(find.text('Vòng lặp AI–não, trong tầm tay.'), findsOneWidget);

    await tester.tap(find.text('Lịch sử'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có dữ liệu'), findsWidgets);

    await tester.tap(find.text('Học'));
    await tester.pumpAndSettle();
    expect(find.text('Neuron và EEG'), findsOneWidget);
    expect(find.text('Nội dung song ngữ sẽ có ở S3.'), findsNothing);

    await tester.tap(find.text('Cài đặt'));
    await tester.pumpAndSettle();
    expect(find.text('Ngôn ngữ'), findsOneWidget);

    await tester.tap(find.text('Trang chủ'));
    await tester.pumpAndSettle();
    expect(find.text('Vòng lặp AI–não, trong tầm tay.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Lab shows a load error and recovers on retry', (tester) async {
    final failLoad = ValueNotifier<bool>(true);
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      labDecoder: _testDecoder(),
      labPredictions: _testPredictions(),
      failLabLoad: failLoad,
    );

    final openLab = find.text('Open Lab');
    await tester.ensureVisible(openLab);
    await tester.tap(openLab);
    await tester.pumpAndSettle();

    expect(find.text('Could not load the EEG sample.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    failLoad.value = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('EEG replay'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Lab seek and speed controls move playback', (tester) async {
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      labRecording: _testRecording(),
      labDecoder: _testDecoder(),
      labPredictions: _testPredictions(),
    );

    final openLab = find.text('Open Lab');
    await tester.ensureVisible(openLab);
    await tester.tap(openLab);
    await tester.pumpAndSettle();

    final speed2x = find.text('2×');
    await tester.ensureVisible(speed2x);
    await tester.tap(speed2x);
    await tester.pump();

    await tester.tap(find.text('Play'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('00:00.4 / 00:12.0'), findsOneWidget);

    tester.widget<Slider>(find.byType(Slider)).onChanged!(6.0);
    await tester.pump();
    expect(find.text('00:06.0 / 00:12.0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Settings delete clears data and returns to onboarding', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
    );

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    final deleteTile = find.text('Delete all local data');
    // scrollUntilVisible, not ensureVisible: the Data section is built
    // lazily and sits below the initial viewport once the Privacy
    // section grew a tile, so the tile may not exist until scrolled to.
    await tester.scrollUntilVisible(
      deleteTile,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(deleteTile);
    await tester.pumpAndSettle();

    expect(find.text('Delete all local data?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Local data cleared.'), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.text('Agree and continue'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Live explains the on-device proxy before starting', (
    tester,
  ) async {
    final gateway = _FakeLiveCameraGateway();
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      liveCameraGateway: gateway,
    );

    final openLive = find.text('Open Live');
    await tester.scrollUntilVisible(
      openLive,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(openLive);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Camera attention proxy'), findsOneWidget);
    expect(find.byKey(const ValueKey('live-start-button')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('No video is recorded'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('No video is recorded'), findsOneWidget);
    expect(gateway.starts, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Live session shows a score and a local summary', (tester) async {
    final gateway = _FakeLiveCameraGateway();
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      liveCameraGateway: gateway,
      // This test is about score display, not throttling: analyze every
      // frame so all six rapid test frames reach the UI.
      frameThrottler: FrameThrottler(minInterval: Duration.zero),
    );

    final openLive = find.text('Open Live');
    await tester.scrollUntilVisible(
      openLive,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(openLive);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('live-start-button')));
    await tester.pump();
    await tester.pump();

    expect(gateway.starts, 1);
    expect(gateway.session, isNotNull);
    expect(find.byKey(const ValueKey('fake-live-preview')), findsOneWidget);

    final session = gateway.session!;
    for (var i = 0; i < 6; i++) {
      session.addFrame(_liveCheckerboard());
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('live-score')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    final score = tester.widget<Text>(find.byKey(const ValueKey('live-score')));
    expect(int.parse(score.data!), greaterThan(90));

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('live-stop-button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('live-stop-button')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Session summary'), findsOneWidget);
    expect(session.disposed, isTrue);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 800));
    await tester.pumpAndSettle();
    expect(find.text('Session summary'), findsOneWidget);
    expect(find.text('Average score'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Live permission failure shows retry guidance', (tester) async {
    final gateway = _FakeLiveCameraGateway()
      ..failure = const LiveCameraException(LiveCameraFailure.permissionDenied);
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      liveCameraGateway: gateway,
    );

    final openLive = find.text('Open Live');
    await tester.scrollUntilVisible(
      openLive,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(openLive);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('live-start-button')));
    await tester.pump();
    await tester.pump();

    expect(find.text('Camera unavailable'), findsOneWidget);
    expect(find.textContaining('Camera permission was denied'), findsOneWidget);
    expect(find.textContaining('If you permanently denied'), findsNothing);
    expect(find.byKey(const ValueKey('live-retry-button')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Live permanently denied failure shows settings guidance',
      (tester) async {
    final gateway = _FakeLiveCameraGateway()
      ..failure = const LiveCameraException(
        LiveCameraFailure.permissionPermanentlyDenied,
      );
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      liveCameraGateway: gateway,
    );

    final openLive = find.text('Open Live');
    await tester.scrollUntilVisible(
      openLive,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(openLive);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('live-start-button')));
    await tester.pump();
    await tester.pump();

    expect(find.text('Camera unavailable'), findsOneWidget);
    expect(find.textContaining('Camera access is blocked'), findsOneWidget);
    expect(find.textContaining('If you permanently denied'), findsOneWidget);
    expect(find.byKey(const ValueKey('live-retry-button')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Live session can restart after stop', (tester) async {
    final gateway = _FakeLiveCameraGateway();
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      liveCameraGateway: gateway,
    );

    final openLive = find.text('Open Live');
    await tester.scrollUntilVisible(
      openLive,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(openLive);
    await tester.pumpAndSettle();

    Future<void> runSession() async {
      await tester.tap(find.byKey(const ValueKey('live-start-button')));
      await tester.pump();
      await tester.pump();
      final session = gateway.session!;
      for (var i = 0; i < 6; i++) {
        session.addFrame(_liveCheckerboard());
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pump();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('live-stop-button')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('live-stop-button')));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Session summary'), findsOneWidget);
    }

    await runSession();
    final firstSession = gateway.session!;
    expect(firstSession.disposed, isTrue);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('live-start-button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await runSession();
    expect(gateway.starts, 2);
    expect(gateway.session, isNot(firstSession));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Live session stops when the app leaves the foreground',
      (tester) async {
    final gateway = _FakeLiveCameraGateway();
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      liveCameraGateway: gateway,
    );

    final openLive = find.text('Open Live');
    await tester.scrollUntilVisible(
      openLive,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(openLive);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('live-start-button')));
    await tester.pump();
    await tester.pump();

    final session = gateway.session!;
    for (var i = 0; i < 6; i++) {
      session.addFrame(_liveCheckerboard());
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump();
    expect(find.byKey(const ValueKey('fake-live-preview')), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(session.disposed, isTrue);

    // While backgrounded the framework delivers no frame, so the summary
    // state only becomes visible once the app returns to the foreground —
    // exactly as on a real device.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Session summary'), findsOneWidget);
    expect(
      find.text('The session stopped when the app left the foreground.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Live permanently denied shows an Open Settings button',
      (tester) async {
    final gateway = _FakeLiveCameraGateway()
      ..failure = const LiveCameraException(
        LiveCameraFailure.permissionPermanentlyDenied,
      );
    final opener = _FakeSystemSettingsOpener();
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      liveCameraGateway: gateway,
      systemSettingsOpener: opener,
    );

    final openLive = find.text('Open Live');
    await tester.scrollUntilVisible(
      openLive,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(openLive);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('live-start-button')));
    await tester.pump();
    await tester.pump();

    final settingsButton = find.byKey(
      const ValueKey('live-open-settings-button'),
    );
    expect(settingsButton, findsOneWidget);
    await tester.tap(settingsButton);
    await tester.pump();
    expect(opener.calls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Live plain denied shows no Open Settings button',
      (tester) async {
    final gateway = _FakeLiveCameraGateway()
      ..failure = const LiveCameraException(LiveCameraFailure.permissionDenied);
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      liveCameraGateway: gateway,
    );

    final openLive = find.text('Open Live');
    await tester.scrollUntilVisible(
      openLive,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(openLive);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('live-start-button')));
    await tester.pump();
    await tester.pump();

    expect(
      find.byKey(const ValueKey('live-open-settings-button')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Settings save toggle defaults to off and flips',
      (tester) async {
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
    );

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    final toggle = find.byType(SwitchListTile);
    expect(toggle, findsOneWidget);
    expect(tester.widget<SwitchListTile>(toggle).value, isFalse);

    await tester.tap(find.text('Save Live session summaries'));
    await tester.pump();
    expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Insights lists saved Live sessions', (tester) async {
    await _pumpApp(
      tester,
      values: {
        'locale': 'en',
        'onboarding_complete': true,
        'live_session_summaries':
            '[{"averageScore":80,"durationMs":60000,"frames":120,"endedAt":"2026-10-28T09:30:00.000"}]',
      },
    );

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();

    expect(find.text('Saved Live sessions'), findsOneWidget);
    expect(find.text('80'), findsOneWidget);
    expect(find.text('28/10/2026 09:30'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Insights empty state prompts to turn saving on',
      (tester) async {
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
    );

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();

    expect(find.text('No data yet'), findsOneWidget);
    expect(
      find.text(
        'Turn on saving Live session summaries in Settings to keep them here.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Live session is saved to Insights when saving is on',
      (tester) async {
    final gateway = _FakeLiveCameraGateway();
    await _pumpApp(
      tester,
      values: {
        'locale': 'en',
        'onboarding_complete': true,
        'save_live_summaries': true,
      },
      liveCameraGateway: gateway,
    );

    final openLive = find.text('Open Live');
    await tester.scrollUntilVisible(
      openLive,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(openLive);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('live-start-button')));
    await tester.pump();
    await tester.pump();

    final session = gateway.session!;
    for (var i = 0; i < 6; i++) {
      session.addFrame(_liveCheckerboard());
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('live-stop-button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('live-stop-button')));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Session summary'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();

    expect(find.text('Saved Live sessions'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Live camera selector switches cameras cleanly',
      (tester) async {
    final gateway = _FakeLiveCameraGateway();
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      liveCameraGateway: gateway,
    );

    final openLive = find.text('Open Live');
    await tester.scrollUntilVisible(
      openLive,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(openLive);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('live-start-button')));
    await tester.pump();
    await tester.pump();

    expect(gateway.starts, 1);
    expect(gateway.lastLensDirection, CameraLensDirection.front);
    final firstSession = gateway.session!;

    await tester.scrollUntilVisible(
      find.text('Back'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(gateway.starts, 2);
    expect(gateway.lastLensDirection, CameraLensDirection.back);
    expect(firstSession.disposed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Live camera selector picks the back camera before start',
      (tester) async {
    final gateway = _FakeLiveCameraGateway();
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      liveCameraGateway: gateway,
    );

    final openLive = find.text('Open Live');
    await tester.scrollUntilVisible(
      openLive,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(openLive);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Back'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('live-start-button')));
    await tester.pump();
    await tester.pump();

    expect(gateway.starts, 1);
    expect(gateway.lastLensDirection, CameraLensDirection.back);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Live analysis throttles rapid frames', (tester) async {
    final gateway = _FakeLiveCameraGateway();
    // A controllable clock: widget tests fake timers but not
    // DateTime.now, so the throttle window is advanced explicitly.
    var now = DateTime(2026, 10, 28, 10, 0, 0);
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      liveCameraGateway: gateway,
      frameThrottler: FrameThrottler(clock: () => now),
    );

    final openLive = find.text('Open Live');
    await tester.scrollUntilVisible(
      openLive,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(openLive);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('live-start-button')));
    await tester.pump();
    await tester.pump();

    final session = gateway.session!;
    for (var i = 0; i < 10; i++) {
      session.addFrame(_liveCheckerboard());
    }
    await tester.pump();
    // Advance the throttle window explicitly, then send one more frame.
    now = now.add(const Duration(milliseconds: 120));
    session.addFrame(_liveCheckerboard());
    await tester.pump();
    await tester.pump();

    // 11 frames were sent but only 2 were analyzed: the burst collapsed
    // to one, and the delayed frame opened the next throttle window.
    await tester.scrollUntilVisible(
      find.text('Frames analyzed: 2'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Frames analyzed: 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Live spoken score only moves when the band changes',
      (tester) async {
    final semanticsHandle = tester.ensureSemantics();
    final gateway = _FakeLiveCameraGateway();
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      liveCameraGateway: gateway,
      frameThrottler: FrameThrottler(minInterval: Duration.zero),
    );

    final openLive = find.text('Open Live');
    await tester.scrollUntilVisible(
      openLive,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(openLive);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('live-start-button')));
    await tester.pump();
    await tester.pump();

    final session = gateway.session!;
    String spokenScore() {
      final node = tester.getSemantics(
        find.byKey(const ValueKey('live-score-semantics')),
      );
      return node.getSemanticsData().label;
    }

    Future<void> pumpFrames(LumaFrame frame, int count) async {
      for (var i = 0; i < count; i++) {
        session.addFrame(frame);
        await tester.pump();
      }
      await tester.pump();
    }

    await pumpFrames(_liveCheckerboard(), 2);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('live-score')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(spokenScore(), 'Attention proxy score: 100 out of 100');

    await pumpFrames(_liveBlank(), 2);
    expect(spokenScore(), 'Attention proxy score: 56 out of 100');

    // Two soft frames land in the same Medium band: the visual score
    // moves but the spoken score must not.
    await pumpFrames(_liveSoftCheckerboard(), 2);
    final visual = tester.widget<Text>(
      find.byKey(const ValueKey('live-score')),
    );
    expect(visual.data, '51');
    expect(spokenScore(), 'Attention proxy score: 56 out of 100');

    await pumpFrames(_liveBlank(), 2);
    expect(spokenScore(), 'Attention proxy score: 29 out of 100');
    // Dispose explicitly here, not via addTearDown: the framework
    // verifies handles before tearDown callbacks run.
    semanticsHandle.dispose();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home latest session shows the newest saved session',
      (tester) async {
    await _pumpApp(
      tester,
      values: {
        'locale': 'en',
        'onboarding_complete': true,
        'live_session_summaries':
            '[{"averageScore":80,"durationMs":60000,"frames":120,"endedAt":"2026-10-28T09:30:00.000"}]',
      },
    );

    // The Latest session card sits below the fold on a phone screen, so
    // the sliver list only builds it once scrolled into view.
    await tester.scrollUntilVisible(
      find.text('Latest session'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Saved Live sessions'), findsOneWidget);
    expect(find.text('Average score: 80 · Frames: 120'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Insights'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Insights'));
    await tester.pumpAndSettle();

    expect(find.text('28/10/2026 09:30'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Back navigation mid-session saves the summary when on',
      (tester) async {
    final gateway = _FakeLiveCameraGateway();
    await _pumpApp(
      tester,
      values: {
        'locale': 'en',
        'onboarding_complete': true,
        'save_live_summaries': true,
      },
      liveCameraGateway: gateway,
    );

    final openLive = find.text('Open Live');
    await tester.scrollUntilVisible(
      openLive,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(openLive);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('live-start-button')));
    await tester.pump();
    await tester.pump();

    final session = gateway.session!;
    for (var i = 0; i < 6; i++) {
      session.addFrame(_liveCheckerboard());
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump();
    expect(find.byKey(const ValueKey('fake-live-preview')), findsOneWidget);

    // Leaving with the system back button must end the session like
    // Stop does, not discard it silently.
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(session.disposed, isTrue);
    expect(find.text('Open Live'), findsOneWidget);

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();
    expect(find.text('Saved Live sessions'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Back navigation mid-session saves nothing when off',
      (tester) async {
    final gateway = _FakeLiveCameraGateway();
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      liveCameraGateway: gateway,
    );

    final openLive = find.text('Open Live');
    await tester.scrollUntilVisible(
      openLive,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(openLive);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('live-start-button')));
    await tester.pump();
    await tester.pump();

    final session = gateway.session!;
    for (var i = 0; i < 6; i++) {
      session.addFrame(_liveCheckerboard());
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(session.disposed, isTrue);
    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();
    expect(find.text('No data yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Live close button ends the session before leaving',
      (tester) async {
    final gateway = _FakeLiveCameraGateway();
    // Live as the initial route is the only way to reach the close
    // button: with nothing below it, the AppBar shows close instead of
    // the back arrow.
    final router = GoRouter(
      initialLocation: '/live',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/live',
          builder: (context, state) => const LiveScreen(),
        ),
        GoRoute(
          path: '/insights',
          builder: (context, state) => const InsightsScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await _pumpApp(
      tester,
      values: {
        'locale': 'en',
        'onboarding_complete': true,
        'save_live_summaries': true,
      },
      liveCameraGateway: gateway,
      routerOverride: router,
    );

    await tester.tap(find.byKey(const ValueKey('live-start-button')));
    await tester.pump();
    await tester.pump();

    final session = gateway.session!;
    for (var i = 0; i < 6; i++) {
      session.addFrame(_liveCheckerboard());
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump();

    // The close button navigates with go(), not pop(), so it must stop
    // the session first instead of relying on the PopScope.
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(session.disposed, isTrue);
    expect(find.text('Open Live'), findsOneWidget);

    // The latest-session card sits below the fold, so scroll it into
    // view before tapping its Insights action.
    await tester.scrollUntilVisible(
      find.text('Latest session'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Insights'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Insights'));
    await tester.pumpAndSettle();
    expect(find.text('Saved Live sessions'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Lab accuracy line wears the LORO label without a held-out run',
      (tester) async {
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      labRecording: _testRecording(),
      labDecoder: _testDecoderNoTestRun(),
      labPredictions: _testPredictions(),
    );

    final openLab = find.text('Open Lab');
    await tester.ensureVisible(openLab);
    await tester.tap(openLab);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('AI decoder'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Leave-one-run-out accuracy: 60%'),
      findsOneWidget,
    );
    expect(
      find.textContaining('leave-one-run-out evaluation'),
      findsOneWidget,
    );
    expect(find.textContaining('Held-out accuracy'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Lab card shows the model preprocessing and limitations text',
      (tester) async {
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      labRecording: _testRecording(),
      labDecoder: _testDecoder(),
      labPredictions: _testPredictions(),
    );

    final openLab = find.text('Open Lab');
    await tester.ensureVisible(openLab);
    await tester.tap(openLab);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('AI decoder'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Test preprocessing'), findsOneWidget);
    expect(find.textContaining('Test limitations'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Lab card shows the held-out confusion matrix', (tester) async {
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      labRecording: _testRecording(),
      labDecoder: _testDecoder(),
      labPredictions: _testPredictions(),
    );

    final openLab = find.text('Open Lab');
    await tester.ensureVisible(openLab);
    await tester.tap(openLab);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('AI decoder'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Confusion matrix (rows = actual, columns = predicted)'),
      findsOneWidget,
    );
    // The test matrix is [[5, 3], [2, 5]]; the off-diagonal 3 is the
    // only bare '3' cell in the card.
    expect(find.text('3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Lab card hides the confusion matrix for a LORO fallback',
      (tester) async {
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      labRecording: _testRecording(),
      labDecoder: _testDecoderNoTestRun(),
      labPredictions: _testPredictions(),
    );

    final openLab = find.text('Open Lab');
    await tester.ensureVisible(openLab);
    await tester.tap(openLab);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('AI decoder'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // The no-test-run double still carries a matrix, but without a
    // held-out run there is no held-out matrix to show.
    expect(
      find.text('Confusion matrix (rows = actual, columns = predicted)'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Insights deletes exactly one session and Home follows',
      (tester) async {
    await _pumpApp(
      tester,
      values: {
        'locale': 'en',
        'onboarding_complete': true,
        'live_session_summaries':
            '[{"averageScore":80,"durationMs":60000,"frames":120,"endedAt":"2026-10-28T09:30:00.000"},'
            '{"averageScore":90,"durationMs":90000,"frames":130,"endedAt":"2026-10-28T10:30:00.000"},'
            '{"averageScore":70,"durationMs":45000,"frames":140,"endedAt":"2026-10-28T11:30:00.000"}]',
      },
    );

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();
    expect(find.text('Saved Live sessions'), findsOneWidget);

    // Stored order is oldest first; the middle session (90) is stored
    // at index 1 and shown between the other two.
    final deleteMiddle = find.byKey(const ValueKey('insights-delete-1'));
    await tester.scrollUntilVisible(
      deleteMiddle,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(deleteMiddle);
    await tester.pumpAndSettle();

    expect(find.text('90'), findsNothing);
    expect(find.text('80'), findsOneWidget);
    expect(find.text('70'), findsOneWidget);

    // Home's latest-session card now follows the deletion: the newest
    // remaining session is the 70, not the deleted 90.
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Latest session'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Average score: 70 · Frames: 140'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Learn lessons expand with real content', (tester) async {
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
    );

    await tester.tap(find.text('Learn'));
    await tester.pumpAndSettle();

    expect(find.text('Neurons and EEG'), findsOneWidget);
    expect(find.text('Bilingual lessons arrive in S3.'), findsNothing);
    expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);

    await tester.tap(find.text('Neurons and EEG'));
    await tester.pumpAndSettle();
    expect(find.textContaining('blurry, noisy window'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Can Wi-Fi read the brain?'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Can Wi-Fi read the brain?'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('never touches brain activity'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Live baseline calibration saves a range and shows relative scores',
      (tester) async {
    final gateway = _FakeLiveCameraGateway();
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      liveCameraGateway: gateway,
      frameThrottler: FrameThrottler(minInterval: Duration.zero),
    );

    await tester.scrollUntilVisible(
      find.text('Open Live'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Live'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('live-baseline-calibrate-button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('live-baseline-calibrate-button')));
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('fake-live-preview')), findsOneWidget);
    final session = gateway.session!;
    // Mixed frames give the calibration a real spread: blank frames score
    // near zero, checkerboard frames ramp toward 100.
    for (var i = 0; i < 15; i++) {
      session.addFrame(_liveBlank());
      await tester.pump(const Duration(milliseconds: 16));
    }
    for (var i = 0; i < 15; i++) {
      session.addFrame(_liveCheckerboard());
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('live-baseline-stop-button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('live-baseline-stop-button')));
    await tester.pump();
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final low = prefs.getDouble('live_proxy_baseline_low');
    final high = prefs.getDouble('live_proxy_baseline_high');
    expect(low, isNotNull);
    expect(high, isNotNull);
    expect(low!, lessThan(high!));
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('live-baseline-calibrate-button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Baseline saved.'), findsOneWidget);
    expect(find.textContaining('Usual range:'), findsOneWidget);

    // A fresh session now shows the score relative to the baseline, with
    // the absolute proxy score still visible underneath.
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('live-start-button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('live-start-button')));
    await tester.pump();
    await tester.pump();
    final session2 = gateway.session!;
    for (var i = 0; i < 6; i++) {
      session2.addFrame(_liveSoftCheckerboard());
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('live-score')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.textContaining('Relative to your usual range.'),
      findsOneWidget,
    );
    expect(find.textContaining('Absolute proxy score:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Live baseline calibration with too few frames saves nothing',
      (tester) async {
    final gateway = _FakeLiveCameraGateway();
    await _pumpApp(
      tester,
      values: {'locale': 'en', 'onboarding_complete': true},
      liveCameraGateway: gateway,
      frameThrottler: FrameThrottler(minInterval: Duration.zero),
    );

    await tester.scrollUntilVisible(
      find.text('Open Live'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Live'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('live-baseline-calibrate-button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('live-baseline-calibrate-button')));
    await tester.pump();
    await tester.pump();

    final session = gateway.session!;
    for (var i = 0; i < 3; i++) {
      session.addFrame(_liveCheckerboard());
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('live-baseline-stop-button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('live-baseline-stop-button')));
    await tester.pump();
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('live_proxy_baseline_low'), isNull);
    expect(prefs.getDouble('live_proxy_baseline_high'), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('live-baseline-calibrate-button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Not enough frames to set a baseline.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Insights export writes a CSV and hands it to the share sheet',
      (tester) async {
    // The real exporter writes a file, which is real async work that
    // cannot complete inside a widget test's fake async zone, so the
    // widget test uses a capturing fake for the UI wiring and the real
    // file write is covered by test/session_exporter_test.dart instead.
    final captured = <LiveSessionSummary>[];
    final exporter = _CapturingExporter(captured);
    final seeded = jsonEncode([
      LiveSessionSummary(
        averageScore: 64,
        duration: const Duration(minutes: 2, seconds: 30),
        frames: 1234,
        endedAt: DateTime.utc(2026, 10, 28, 9, 30),
      ).toJson(),
      LiveSessionSummary(
        averageScore: 87,
        duration: const Duration(seconds: 90),
        frames: 42,
        endedAt: DateTime.utc(2026, 10, 27, 18, 5),
      ).toJson(),
    ]);
    await _pumpApp(
      tester,
      values: {
        'locale': 'en',
        'onboarding_complete': true,
        'live_session_summaries': seeded,
      },
      sessionExporter: exporter,
    );

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('insights-export-button')));
    await tester.pumpAndSettle();

    expect(captured, hasLength(2));
    expect(captured[0].averageScore, 64);
    expect(captured[0].frames, 1234);
    expect(captured[1].averageScore, 87);
    expect(captured[1].frames, 42);
    expect(find.text('Session history exported.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
