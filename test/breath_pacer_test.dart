import 'package:flutter_test/flutter_test.dart';

import 'package:nemro/features/practice/data/breath_pacer.dart';

void main() {
  test('exhale length maps the score range onto 4..8 seconds', () {
    expect(AdaptiveBreathPacer.exhaleForScore(0), const Duration(seconds: 4));
    expect(AdaptiveBreathPacer.exhaleForScore(50), const Duration(seconds: 6));
    expect(AdaptiveBreathPacer.exhaleForScore(100), const Duration(seconds: 8));
  });

  test('exhale length clamps out-of-range scores and treats NaN as 50', () {
    expect(AdaptiveBreathPacer.exhaleForScore(-20), const Duration(seconds: 4));
    expect(AdaptiveBreathPacer.exhaleForScore(140), const Duration(seconds: 8));
    expect(
      AdaptiveBreathPacer.exhaleForScore(double.nan),
      const Duration(seconds: 6),
    );
  });

  test('phases run inhale, hold, exhale, hold order with a scored exhale', () {
    var now = DateTime(2026, 10, 30, 9, 0, 0);
    final pacer = AdaptiveBreathPacer(clock: () => now);
    pacer.start();

    // Inhale is 4s.
    var state = pacer.update(80);
    expect(state.phase, BreathPhase.inhale);
    expect(state.phaseDuration, const Duration(seconds: 4));

    // Hold after inhale is 1s.
    now = now.add(const Duration(seconds: 4));
    state = pacer.update(80);
    expect(state.phase, BreathPhase.holdAfterInhale);
    expect(state.phaseDuration, const Duration(seconds: 1));

    // Exhale sampled at 80 scores 7.2s (4 + 0.8 * 4).
    now = now.add(const Duration(seconds: 1));
    state = pacer.update(80);
    expect(state.phase, BreathPhase.exhale);
    expect(state.phaseDuration, const Duration(milliseconds: 7200));

    // Hold after exhale is 1s, then a new cycle starts.
    now = now.add(const Duration(milliseconds: 7200));
    state = pacer.update(80);
    expect(state.phase, BreathPhase.holdAfterExhale);
    now = now.add(const Duration(seconds: 1));
    state = pacer.update(80);
    expect(state.phase, BreathPhase.inhale);
    expect(pacer.completedCycles, 1);
  });

  test('progress moves 0..1 within a phase', () {
    var now = DateTime(2026, 10, 30, 9, 0, 0);
    final pacer = AdaptiveBreathPacer(clock: () => now);
    pacer.start();

    expect(pacer.update(50).progress, 0);
    now = now.add(const Duration(seconds: 2));
    expect(pacer.update(50).progress, 0.5);
  });

  test('a backwards clock jump restarts the current phase', () {
    var now = DateTime(2026, 10, 30, 9, 0, 0);
    final pacer = AdaptiveBreathPacer(clock: () => now);
    pacer.start();

    now = now.add(const Duration(seconds: 2));
    expect(pacer.update(50).progress, 0.5);
    now = now.subtract(const Duration(seconds: 5));
    final state = pacer.update(50);
    expect(state.phase, BreathPhase.inhale);
    expect(state.progress, 0);
  });

  test('update before start reports the idle inhale state', () {
    final pacer = AdaptiveBreathPacer();
    final state = pacer.update(50);
    expect(state.phase, BreathPhase.inhale);
    expect(state.progress, 0);
    expect(pacer.isStarted, isFalse);
  });
}
