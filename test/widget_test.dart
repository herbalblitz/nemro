import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nemro/app.dart';
import 'package:nemro/core/preferences/preferences_providers.dart';
import 'package:nemro/features/lab/data/eeg_recording.dart';
import 'package:nemro/features/lab/data/eeg_repository.dart';

Future<void> _pumpApp(
  WidgetTester tester, {
  Map<String, Object> values = const {'locale': 'vi'},
  EegRecording? labRecording,
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
          eegRecordingProvider.overrideWith((ref) => labRecording),
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
      EegEvent(onset: 2, duration: 4, label: 'T1'),
      EegEvent(onset: 7, duration: 4, label: 'T2'),
    ],
    samples: List.generate(2, (_) => List<double>.filled(12 * 160, 0)),
    duration: 12,
  );
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
    expect(tester.takeException(), isNull);
  });

  testWidgets('Lab renders in Vietnamese on a narrow screen', (tester) async {
    await _pumpApp(
      tester,
      values: {'locale': 'vi', 'onboarding_complete': true},
      labRecording: _testRecording(),
    );

    final openLab = find.text('Mở Lab');
    await tester.ensureVisible(openLab);
    await tester.tap(openLab);
    await tester.pumpAndSettle();

    expect(find.text('Phát lại EEG'), findsOneWidget);
    expect(find.text('Phát'), findsOneWidget);
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
}
