import 'package:flutter_test/flutter_test.dart';

import 'package:nemro/features/insights/session_trends.dart';
import 'package:nemro/features/live/data/live_session_summary.dart';

LiveSessionSummary _summary(int score, DateTime endedAt) {
  return LiveSessionSummary(
    averageScore: score,
    duration: const Duration(minutes: 2),
    frames: 100,
    endedAt: endedAt,
  );
}

void main() {
  test('empty history yields empty trends', () {
    final trends = computeSessionTrends(const []);
    expect(trends.isEmpty, isTrue);
    expect(trends.weeklyAverages, isEmpty);
    expect(trends.currentStreakDays, 0);
    expect(trends.longestStreakDays, 0);
  });

  test('weekly grouping splits on Monday boundaries', () {
    // 2026-10-26 is a Monday.
    final trends = computeSessionTrends([
      _summary(60, DateTime(2026, 10, 26, 9)),
      _summary(80, DateTime(2026, 10, 27, 9)),
      _summary(40, DateTime(2026, 10, 25, 9)),
    ]);
    expect(trends.weeklyAverages, hasLength(2));
    // Newest week first.
    expect(trends.weeklyAverages.first.weekStart, DateTime(2026, 10, 26));
    expect(trends.weeklyAverages.first.averageScore, 70);
    expect(trends.weeklyAverages.first.sessions, 2);
    expect(trends.weeklyAverages.last.weekStart, DateTime(2026, 10, 19));
    expect(trends.weeklyAverages.last.averageScore, 40);
  });

  test('best and worst prefer the latest session on ties', () {
    final trends = computeSessionTrends([
      _summary(90, DateTime(2026, 10, 20, 9)),
      _summary(90, DateTime(2026, 10, 21, 9)),
      _summary(10, DateTime(2026, 10, 20, 10)),
      _summary(10, DateTime(2026, 10, 22, 9)),
    ]);
    expect(trends.best?.endedAt, DateTime(2026, 10, 21, 9));
    expect(trends.worst?.endedAt, DateTime(2026, 10, 22, 9));
  });

  test('streaks count consecutive days and stop at gaps', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final trends = computeSessionTrends([
      _summary(50, today.subtract(const Duration(days: 6))),
      _summary(50, today.subtract(const Duration(days: 5))),
      _summary(50, today.subtract(const Duration(days: 3))),
      _summary(50, today.subtract(const Duration(days: 2))),
      _summary(50, today.subtract(const Duration(days: 1))),
    ]);
    expect(trends.longestStreakDays, 3);
    expect(trends.currentStreakDays, 3);
  });

  test('current streak includes today when a session exists today', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final trends = computeSessionTrends([
      _summary(50, today.subtract(const Duration(days: 1))),
      _summary(50, today),
    ]);
    expect(trends.currentStreakDays, 2);
  });

  test('current streak is zero when neither today nor yesterday has one', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final trends = computeSessionTrends([
      _summary(50, today.subtract(const Duration(days: 5))),
    ]);
    expect(trends.currentStreakDays, 0);
    expect(trends.longestStreakDays, 1);
  });

  test('multiple sessions on one day count once for streaks', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final trends = computeSessionTrends([
      _summary(50, DateTime(yesterday.year, yesterday.month, yesterday.day, 9)),
      _summary(
        60,
        DateTime(yesterday.year, yesterday.month, yesterday.day, 18),
      ),
      _summary(70, today),
    ]);
    expect(trends.currentStreakDays, 2);
    expect(trends.longestStreakDays, 2);
  });
}
