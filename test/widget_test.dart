import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nemro/app.dart';
import 'package:nemro/core/preferences/preferences_providers.dart';
import 'package:nemro/features/lab/data/eeg_decoder.dart';
import 'package:nemro/features/lab/data/eeg_decoder_repository.dart';
import 'package:nemro/features/lab/data/eeg_recording.dart';
import 'package:nemro/features/lab/data/eeg_repository.dart';
import 'package:nemro/features/live/data/attention_analyzer.dart';
import 'package:nemro/features/live/data/frame_throttler.dart';
import 'package:nemro/features/live/data/live_camera_gateway.dart';
import 'package:nemro/features/live/data/system_settings_opener.dart';

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
    expect(find.text('Nội dung song ngữ sẽ có ở S3.'), findsOneWidget);

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
}
