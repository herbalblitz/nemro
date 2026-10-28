import 'dart:async';
import 'dart:typed_data';

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
import 'package:nemro/features/live/data/live_camera_gateway.dart';

Future<void> _pumpApp(
  WidgetTester tester, {
  Map<String, Object> values = const {'locale': 'vi'},
  EegRecording? labRecording,
  EegDecoder? labDecoder,
  Map<double, EegPrediction>? labPredictions,
  ValueNotifier<bool>? failLabLoad,
  LiveCameraGateway? liveCameraGateway,
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
  int starts = 0;

  @override
  Future<LiveCameraSession> start() async {
    starts++;
    final error = failure;
    if (error != null) throw error;
    final next = _FakeLiveCameraSession();
    session = next;
    return next;
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
    await tester.ensureVisible(deleteTile);
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
}
