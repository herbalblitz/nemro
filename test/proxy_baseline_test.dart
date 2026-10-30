import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nemro/core/preferences/preferences_providers.dart';
import 'package:nemro/features/live/data/proxy_baseline.dart';

void main() {
  test('capture uses the 10th and 90th percentiles', () {
    final scores = List<double>.generate(100, (i) => i.toDouble());
    final baseline = ProxyBaseline.capture(scores);
    expect(baseline, isNotNull);
    // p10 of 0..99 lands near 10, p90 near 89 (nearest-rank rounding).
    expect(baseline!.low, 10);
    expect(baseline.high, 89);
  });

  test('capture returns null below the minimum frame count', () {
    expect(
      ProxyBaseline.capture(List.filled(ProxyBaseline.minFrames - 1, 50.0)),
      isNull,
    );
    expect(
      ProxyBaseline.capture(List.filled(ProxyBaseline.minFrames, 50.0)),
      isNotNull,
    );
  });

  test('relative score maps the usual range onto 0..100', () {
    const baseline = ProxyBaseline(low: 20, high: 80);
    expect(baseline.relativeScore(20), 0);
    expect(baseline.relativeScore(50), 50);
    expect(baseline.relativeScore(80), 100);
    expect(baseline.relativeScore(0), 0);
    expect(baseline.relativeScore(100), 100);
  });

  test('flat baseline falls back to the absolute score', () {
    const baseline = ProxyBaseline(low: 50, high: 50);
    expect(baseline.relativeScore(30), 30);
    expect(baseline.relativeScore(90), 90);
  });

  test('invalidating after prefs.clear drops the in-memory baseline', () async {
    SharedPreferences.setMockInitialValues({
      'live_proxy_baseline_low': 20.0,
      'live_proxy_baseline_high': 80.0,
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(proxyBaselineProvider), isNotNull);
    await prefs.clear();
    container.invalidate(proxyBaselineProvider);
    expect(container.read(proxyBaselineProvider), isNull);
  });

  test('stored values are validated', () {
    expect(ProxyBaseline.tryFromValues(20, 80), isNotNull);
    expect(ProxyBaseline.tryFromValues(null, 80), isNull);
    expect(ProxyBaseline.tryFromValues(20, null), isNull);
    expect(ProxyBaseline.tryFromValues(-1, 80), isNull);
    expect(ProxyBaseline.tryFromValues(20, 101), isNull);
    expect(ProxyBaseline.tryFromValues(80, 20), isNull);
    expect(ProxyBaseline.tryFromValues(double.nan, 80), isNull);
    expect(ProxyBaseline.tryFromValues(20, double.infinity), isNull);
  });
}
