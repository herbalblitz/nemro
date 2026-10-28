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
}
