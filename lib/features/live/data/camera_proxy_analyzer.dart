import 'dart:math' as math;
import 'dart:typed_data';

/// A downsampled luminance frame with values normalized to 0..1.
class LumaFrame {
  LumaFrame({required this.width, required this.height, required this.pixels})
    : assert(width > 0),
      assert(height > 0),
      assert(pixels.length == width * height);

  final int width;
  final int height;
  final Float32List pixels;
}

/// One frame's heuristic proxy values.
///
/// This is not a measurement of attention, fatigue, or any medical state.
class CameraProxySample {
  const CameraProxySample({
    required this.score,
    required this.brightness,
    required this.motion,
    required this.contrast,
    required this.lighting,
    required this.stability,
    required this.presence,
    required this.frames,
  });

  /// Smoothed heuristic score from 0 to 100.
  final double score;

  /// Mean luminance from 0 to 1.
  final double brightness;

  /// Mean absolute frame-to-frame luminance change, from 0 to 1.
  final double motion;

  /// Standard deviation of the central region, from 0 upward.
  final double contrast;

  /// Lighting component of the score, from 0 to 1.
  final double lighting;

  /// Stability component of the score, from 0 to 1.
  final double stability;

  /// Central-contrast presence component, from 0 to 1.
  final double presence;

  /// Number of frames analyzed since the last reset.
  final int frames;

  int get roundedScore => score.round().clamp(0, 100).toInt();

  bool get isWarmingUp => frames < CameraProxyAnalyzer.warmupFrames;
}

/// A transparent, lightweight camera-frame heuristic.
///
/// The score is built from three signals:
/// - central contrast, which gates the score so a blank wall stays low;
/// - lighting, which prefers a mid-range exposure;
/// - stability, which falls as frame-to-frame motion rises.
///
/// It is deliberately simple and explainable. It does not detect faces, eyes,
/// blinks, or attention, and it must never be presented as mind reading.
class CameraProxyAnalyzer {
  static const int warmupFrames = 3;
  static const double _contrastTarget = 0.10;
  static const double _motionTarget = 0.12;
  static const double _smoothing = 0.25;

  Float32List? _previous;
  int _previousWidth = 0;
  int _previousHeight = 0;
  int _frames = 0;
  double? _smoothedScore;

  void reset() {
    _previous = null;
    _previousWidth = 0;
    _previousHeight = 0;
    _frames = 0;
    _smoothedScore = null;
  }

  CameraProxySample addFrame(LumaFrame frame) {
    _frames++;
    final stats = _FrameStats.from(frame);
    final motion = _motion(frame);
    final lighting = (1 - (stats.mean - 0.5).abs() * 2)
        .clamp(0.0, 1.0)
        .toDouble();
    final presence = (stats.centralContrast / _contrastTarget)
        .clamp(0.0, 1.0)
        .toDouble();
    final stability = (1 - motion / _motionTarget).clamp(0.0, 1.0).toDouble();
    final raw = 100 * presence * (0.6 * stability + 0.4 * lighting);
    final smoothed = _smoothedScore == null
        ? raw
        : (_smoothedScore! + _smoothing * (raw - _smoothedScore!))
              .clamp(0.0, 100.0)
              .toDouble();

    _smoothedScore = smoothed;
    _previous = Float32List.fromList(frame.pixels);
    _previousWidth = frame.width;
    _previousHeight = frame.height;

    return CameraProxySample(
      score: smoothed,
      brightness: stats.mean,
      motion: motion,
      contrast: stats.centralContrast,
      lighting: lighting,
      stability: stability,
      presence: presence,
      frames: _frames,
    );
  }

  double _motion(LumaFrame frame) {
    final previous = _previous;
    if (previous == null ||
        _previousWidth != frame.width ||
        _previousHeight != frame.height) {
      return 0;
    }

    var total = 0.0;
    for (var i = 0; i < frame.pixels.length; i++) {
      total += (frame.pixels[i] - previous[i]).abs();
    }
    return (total / frame.pixels.length).clamp(0.0, 1.0).toDouble();
  }
}

class _FrameStats {
  const _FrameStats({required this.mean, required this.centralContrast});

  factory _FrameStats.from(LumaFrame frame) {
    final pixels = frame.pixels;
    var total = 0.0;
    for (final value in pixels) {
      total += value;
    }
    final mean = total / pixels.length;

    final left = frame.width ~/ 4;
    final right = math.max(left + 1, frame.width - left);
    final top = frame.height ~/ 4;
    final bottom = math.max(top + 1, frame.height - top);

    var centralTotal = 0.0;
    var centralCount = 0;
    for (var y = top; y < bottom; y++) {
      final row = y * frame.width;
      for (var x = left; x < right; x++) {
        centralTotal += pixels[row + x];
        centralCount++;
      }
    }

    if (centralCount == 0) {
      return _FrameStats(mean: mean, centralContrast: 0);
    }

    final centralMean = centralTotal / centralCount;
    var variance = 0.0;
    for (var y = top; y < bottom; y++) {
      final row = y * frame.width;
      for (var x = left; x < right; x++) {
        final difference = pixels[row + x] - centralMean;
        variance += difference * difference;
      }
    }

    return _FrameStats(
      mean: mean,
      centralContrast: math.sqrt(variance / centralCount),
    );
  }

  final double mean;
  final double centralContrast;
}
