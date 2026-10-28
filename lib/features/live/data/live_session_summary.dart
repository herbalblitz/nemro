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
        durationMs is! int ||
        frames is! int ||
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
