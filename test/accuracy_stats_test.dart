import 'package:flutter_test/flutter_test.dart';

import 'package:nemro/features/lab/data/accuracy_stats.dart';

void main() {
  test('Wilson interval for the held-out 10/15 result is 41.7%–84.8%', () {
    final interval = wilson95Interval(10, 15);
    expect((interval.low * 100).toStringAsFixed(1), '41.7');
    expect((interval.high * 100).toStringAsFixed(1), '84.8');
  });

  test('Wilson interval stays inside 0..1 at the extremes', () {
    final none = wilson95Interval(0, 10);
    expect(none.low, 0);
    expect(none.high, lessThan(0.35));

    final all = wilson95Interval(10, 10);
    expect(all.low, greaterThan(0.65));
    expect(all.high, closeTo(1, 1e-9));
  });

  test('an empty sample yields the whole range', () {
    final interval = wilson95Interval(0, 0);
    expect(interval.low, 0);
    expect(interval.high, 1);
  });
}
