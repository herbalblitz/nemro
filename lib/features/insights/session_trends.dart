import 'package:nemro/features/live/data/live_session_summary.dart';

/// One calendar week's roll-up, keyed by its Monday (date-only).
class WeeklyAverage {
  const WeeklyAverage({
    required this.weekStart,
    required this.averageScore,
    required this.sessions,
  });

  final DateTime weekStart;

  /// Mean of the week's session average scores.
  final double averageScore;
  final int sessions;
}

/// Trends computed on-device from already-stored session history.
///
/// Nothing here leaves the device: the input is the local summary list
/// and every figure is derived from it. Scores are the stored absolute
/// proxy averages; a personal baseline (if calibrated) only changes the
/// live display, never these stored figures.
class SessionTrends {
  const SessionTrends({
    required this.weeklyAverages,
    required this.best,
    required this.worst,
    required this.currentStreakDays,
    required this.longestStreakDays,
  });

  /// Newest week first.
  final List<WeeklyAverage> weeklyAverages;

  /// Highest-scoring session; on a tie the latest session wins.
  final LiveSessionSummary? best;

  /// Lowest-scoring session; on a tie the latest session wins.
  final LiveSessionSummary? worst;

  /// Consecutive days with at least one session, counted back from
  /// today — or from yesterday when today has no session yet, so a
  /// streak is not broken merely because today is still young.
  final int currentStreakDays;

  /// Longest run of consecutive session days ever.
  final int longestStreakDays;

  bool get isEmpty => best == null;
}

SessionTrends computeSessionTrends(List<LiveSessionSummary> summaries) {
  if (summaries.isEmpty) {
    return const SessionTrends(
      weeklyAverages: [],
      best: null,
      worst: null,
      currentStreakDays: 0,
      longestStreakDays: 0,
    );
  }

  LiveSessionSummary best = summaries.first;
  LiveSessionSummary worst = summaries.first;
  final weeklyTotals = <DateTime, _WeekAccumulator>{};
  final days = <DateTime>{};
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  for (final summary in summaries) {
    if (summary.averageScore >= best.averageScore) best = summary;
    if (summary.averageScore <= worst.averageScore) worst = summary;

    final ended = summary.endedAt;
    final day = DateTime(ended.year, ended.month, ended.day);
    final weekStart = day.subtract(Duration(days: day.weekday - 1));
    final accumulator = weeklyTotals.putIfAbsent(
      weekStart,
      () => _WeekAccumulator(),
    );
    accumulator.add(summary.averageScore);
    // Days after today are clock artifacts, not completed streak days.
    if (!day.isAfter(today)) days.add(day);
  }

  final weeklyAverages = weeklyTotals.entries
      .map(
        (entry) => WeeklyAverage(
          weekStart: entry.key,
          averageScore: entry.value.mean,
          sessions: entry.value.count,
        ),
      )
      .toList()
    ..sort((a, b) => b.weekStart.compareTo(a.weekStart));

  final sortedDays = days.toList()..sort();
  var longest = 0;
  var run = 0;
  DateTime? previous;
  for (final day in sortedDays) {
    if (previous != null && day.difference(previous).inDays == 1) {
      run++;
    } else {
      run = 1;
    }
    if (run > longest) longest = run;
    previous = day;
  }

  var current = 0;
  var cursor = days.contains(today)
      ? today
      : today.subtract(const Duration(days: 1));
  while (days.contains(cursor)) {
    current++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  return SessionTrends(
    weeklyAverages: weeklyAverages,
    best: best,
    worst: worst,
    currentStreakDays: current,
    longestStreakDays: longest,
  );
}

class _WeekAccumulator {
  var _sum = 0;
  var count = 0;

  void add(int score) {
    _sum += score;
    count++;
  }

  double get mean => count == 0 ? 0 : _sum / count;
}
