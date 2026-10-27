import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nemro/app.dart';
import 'package:nemro/core/preferences/preferences_providers.dart';

Future<void> _pumpApp(
  WidgetTester tester, {
  Map<String, Object> values = const {'locale': 'vi'},
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const NemroApp(),
    ),
  );
  await tester.pumpAndSettle();
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
