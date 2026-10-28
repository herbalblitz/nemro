import 'package:flutter_test/flutter_test.dart';

import 'package:nemro/features/insights/session_csv.dart';
import 'package:nemro/features/live/data/live_session_summary.dart';

void main() {
  test('empty history exports only the header', () {
    expect(
      sessionsToCsv(const []),
      'ended_at,average_score,duration_seconds,frames',
    );
  });

  test('rows carry ISO timestamps, scores, whole seconds, and frames', () {
    final csv = sessionsToCsv([
      LiveSessionSummary(
        averageScore: 64,
        duration: const Duration(minutes: 2, seconds: 30),
        frames: 1234,
        endedAt: DateTime.utc(2026, 10, 28, 9, 30),
      ),
      LiveSessionSummary(
        averageScore: 87,
        duration: const Duration(seconds: 90, milliseconds: 900),
        frames: 42,
        endedAt: DateTime.utc(2026, 10, 27, 18, 5),
      ),
    ]);
    final lines = csv.split('\n');
    expect(lines, hasLength(3));
    expect(lines[0], 'ended_at,average_score,duration_seconds,frames');
    expect(lines[1], '2026-10-28T09:30:00.000Z,64,150,1234');
    // Duration truncates like the m:ss display: 90.9s stays 90.
    expect(lines[2], '2026-10-27T18:05:00.000Z,87,90,42');
  });
}
