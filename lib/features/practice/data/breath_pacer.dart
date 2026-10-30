/// Adaptive breathing pace driven by the camera signal proxy.
///
/// One cycle is: inhale 4s, hold 1s, exhale 4–8s, hold 1s. The exhale
/// length follows the camera proxy score sampled when the exhale starts:
/// a steadier, better-lit signal stretches the exhale toward 8s, a
/// weaker one shortens it toward 4s.
///
/// The score is a camera-signal heuristic (central contrast, lighting,
/// frame-to-frame stability). It is not a measure of calm, focus, or any
/// medical state, and any copy around this pacer must say so.
enum BreathPhase { inhale, holdAfterInhale, exhale, holdAfterExhale }

/// The pacer's state at one moment: which phase, how far through it.
class BreathPhaseState {
  const BreathPhaseState({
    required this.phase,
    required this.progress,
    required this.phaseDuration,
  });

  final BreathPhase phase;

  /// Progress through the phase, 0..1.
  final double progress;

  final Duration phaseDuration;
}

/// A small phase state machine with an injectable clock, so tests can
/// drive time deterministically.
class AdaptiveBreathPacer {
  AdaptiveBreathPacer({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const inhaleDuration = Duration(seconds: 4);
  static const holdDuration = Duration(seconds: 1);
  static const minExhaleDuration = Duration(seconds: 4);
  static const maxExhaleDuration = Duration(seconds: 8);

  /// Exhale length for [score]: 4s at 0, 8s at 100, linear between.
  /// Out-of-range values clamp; NaN counts as the midpoint (50).
  static Duration exhaleForScore(double score) {
    final clean = score.isNaN ? 50.0 : score.clamp(0.0, 100.0).toDouble();
    final seconds = 4.0 + (clean / 100.0) * 4.0;
    return Duration(milliseconds: (seconds * 1000).round());
  }

  final DateTime Function() _clock;
  DateTime? _phaseStart;
  BreathPhase _phase = BreathPhase.inhale;
  Duration _exhaleDuration = const Duration(seconds: 6);
  int _completedCycles = 0;
  bool _started = false;

  bool get isStarted => _started;

  /// Full cycles completed (an exhale plus both holds since start).
  int get completedCycles => _completedCycles;

  void start() {
    _started = true;
    _phase = BreathPhase.inhale;
    _phaseStart = _clock();
    _completedCycles = 0;
  }

  void reset() {
    _started = false;
    _phaseStart = null;
    _completedCycles = 0;
  }

  /// Advance to the current phase, sampling [scoreNow] for any exhale
  /// that starts during this advance, and return the current state.
  BreathPhaseState update(double scoreNow) {
    if (!_started || _phaseStart == null) {
      return const BreathPhaseState(
        phase: BreathPhase.inhale,
        progress: 0,
        phaseDuration: inhaleDuration,
      );
    }
    var now = _clock();
    var start = _phaseStart!;
    // A backwards clock jump (e.g. an NTP correction) restarts the
    // current phase instead of reporting negative progress.
    if (now.isBefore(start)) {
      _phaseStart = now;
      start = now;
    }
    var guard = 0;
    while (guard++ < 10000) {
      final duration = _durationFor(_phase);
      final elapsed = now.difference(start);
      if (elapsed < duration) {
        return BreathPhaseState(
          phase: _phase,
          progress: elapsed.inMilliseconds / duration.inMilliseconds,
          phaseDuration: duration,
        );
      }
      // Carry leftover time into the next phase.
      start = start.add(duration);
      _phase = _next(_phase);
      if (_phase == BreathPhase.exhale) {
        _exhaleDuration = exhaleForScore(scoreNow);
      }
      if (_phase == BreathPhase.inhale) _completedCycles++;
      _phaseStart = start;
    }
    // An extremely long gap (device asleep for hours) falls back to the
    // start of the current phase rather than looping forever.
    _phaseStart = now;
    return BreathPhaseState(
      phase: _phase,
      progress: 0,
      phaseDuration: _durationFor(_phase),
    );
  }

  Duration _durationFor(BreathPhase phase) => switch (phase) {
    BreathPhase.inhale => inhaleDuration,
    BreathPhase.holdAfterInhale => holdDuration,
    BreathPhase.exhale => _exhaleDuration,
    BreathPhase.holdAfterExhale => holdDuration,
  };

  BreathPhase _next(BreathPhase phase) => switch (phase) {
    BreathPhase.inhale => BreathPhase.holdAfterInhale,
    BreathPhase.holdAfterInhale => BreathPhase.exhale,
    BreathPhase.exhale => BreathPhase.holdAfterExhale,
    BreathPhase.holdAfterExhale => BreathPhase.inhale,
  };
}
