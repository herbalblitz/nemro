import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Caps how often camera frames are analyzed.
///
/// The camera stream delivers frames much faster than the heuristic needs,
/// so analysis runs at most once per [minInterval] (about 10 times a
/// second by default). Frames that arrive sooner are dropped, which keeps
/// weak devices responsive. The clock is injectable so tests can drive
/// time deterministically.
class FrameThrottler {
  FrameThrottler({
    this.minInterval = const Duration(milliseconds: 100),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final Duration minInterval;
  final DateTime Function() _clock;
  DateTime? _lastAccepted;

  bool shouldAnalyze() {
    final now = _clock();
    final last = _lastAccepted;
    if (last == null || now.difference(last) >= minInterval) {
      _lastAccepted = now;
      return true;
    }
    return false;
  }

  void reset() {
    _lastAccepted = null;
  }
}

final frameThrottlerProvider = Provider<FrameThrottler>(
  (ref) => FrameThrottler(),
);
