import 'package:flutter_test/flutter_test.dart';

import 'package:nemro/features/live/data/frame_throttler.dart';

void main() {
  test('first frame is always analyzed', () {
    final throttler = FrameThrottler();
    expect(throttler.shouldAnalyze(), isTrue);
  });

  test('rapid frames are throttled to one per interval', () {
    var now = DateTime(2026, 10, 28, 10, 0, 0);
    final throttler = FrameThrottler(clock: () => now);
    expect(throttler.shouldAnalyze(), isTrue);
    now = now.add(const Duration(milliseconds: 50));
    expect(throttler.shouldAnalyze(), isFalse);
    now = now.add(const Duration(milliseconds: 49));
    expect(throttler.shouldAnalyze(), isFalse);
    now = now.add(const Duration(milliseconds: 1));
    expect(throttler.shouldAnalyze(), isTrue);
    now = now.add(const Duration(milliseconds: 10));
    expect(throttler.shouldAnalyze(), isFalse);
  });

  test('reset allows immediate analysis again', () {
    final throttler = FrameThrottler();
    expect(throttler.shouldAnalyze(), isTrue);
    expect(throttler.shouldAnalyze(), isFalse);
    throttler.reset();
    expect(throttler.shouldAnalyze(), isTrue);
  });
}
