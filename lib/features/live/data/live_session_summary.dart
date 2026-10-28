class LiveSessionSummary {
  const LiveSessionSummary({
    required this.averageScore,
    required this.duration,
    required this.frames,
    required this.endedAt,
  });

  final int averageScore;
  final Duration duration;
  final int frames;
  final DateTime endedAt;

  Map<String, dynamic> toJson() => {
    'averageScore': averageScore,
    'durationMs': duration.inMilliseconds,
    'frames': frames,
    'endedAt': endedAt.toIso8601String(),
  };

  static LiveSessionSummary? tryFromJson(Map<String, dynamic> json) {
    final averageScore = json['averageScore'];
    final durationMs = json['durationMs'];
    final frames = json['frames'];
    final endedAt = json['endedAt'];
    if (averageScore is! int ||
        averageScore < 0 ||
        averageScore > 100 ||
        durationMs is! int ||
        durationMs < 0 ||
        frames is! int ||
        frames < 0 ||
        endedAt is! String) {
      return null;
    }
    final parsedEndedAt = DateTime.tryParse(endedAt);
    if (parsedEndedAt == null) return null;
    return LiveSessionSummary(
      averageScore: averageScore,
      duration: Duration(milliseconds: durationMs),
      frames: frames,
      endedAt: parsedEndedAt,
    );
  }
}
