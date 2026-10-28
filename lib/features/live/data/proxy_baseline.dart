/// A personal baseline for the Live camera proxy.
///
/// The proxy score depends on the room and the lighting, so the same
/// absolute number means different things in different environments. A
/// short calibration session captures the user's own usual range, and
/// later scores are shown relative to that range instead of as absolute
/// numbers.
///
/// This changes presentation only. It is still the same camera proxy —
/// a lighting/stability/presence heuristic, never a brain measurement —
/// and the stored session history keeps absolute scores.
class ProxyBaseline {
  const ProxyBaseline({required this.low, required this.high});

  /// 10th percentile of the calibration scores.
  final double low;

  /// 90th percentile of the calibration scores.
  final double high;

  /// Minimum analyzed frames a calibration must collect to count.
  static const int minFrames = 20;

  bool get isFlat => high <= low;

  /// Where [raw] falls inside the user's usual range, 0..100.
  ///
  /// Below the usual range reads 0, above it reads 100. A flat baseline
  /// (every calibration frame scored the same) cannot define a range,
  /// so it falls back to the absolute score.
  int relativeScore(double raw) {
    if (isFlat) return raw.round().clamp(0, 100).toInt();
    return ((raw - low) / (high - low) * 100).round().clamp(0, 100).toInt();
  }

  /// Builds a baseline from calibration scores, or null when too few
  /// frames were captured to define a range.
  static ProxyBaseline? capture(List<double> scores) {
    if (scores.length < minFrames) return null;
    final sorted = [...scores]..sort();
    double percentile(double p) {
      final index = (p * (sorted.length - 1)).round().clamp(
        0,
        sorted.length - 1,
      );
      return sorted[index];
    }

    return ProxyBaseline(low: percentile(0.1), high: percentile(0.9));
  }

  /// Validates stored values: finite, within 0..100, low not above high.
  static ProxyBaseline? tryFromValues(double? low, double? high) {
    if (low == null ||
        high == null ||
        low.isNaN ||
        high.isNaN ||
        low.isInfinite ||
        high.isInfinite ||
        low < 0 ||
        high > 100 ||
        low > high) {
      return null;
    }
    return ProxyBaseline(low: low, high: high);
  }
}
