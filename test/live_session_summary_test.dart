import 'package:flutter_test/flutter_test.dart';

import 'package:nemro/features/live/data/live_session_summary.dart';

LiveSessionSummary _summary({
  int averageScore = 80,
  int durationMs = 60000,
  int frames = 120,
  String endedAt = '2026-10-28T09:30:00.000',
}) => LiveSessionSummary(
  averageScore: averageScore,
  duration: Duration(milliseconds: durationMs),
  frames: frames,
  endedAt: DateTime.parse(endedAt),
);

void main() {
  test('toJson round-trips through tryFromJson', () {
    final summary = _summary();
    final parsed = LiveSessionSummary.tryFromJson(summary.toJson());

    expect(parsed, isNotNull);
    expect(parsed!.averageScore, 80);
    expect(parsed.duration, const Duration(seconds: 60));
    expect(parsed.frames, 120);
    expect(parsed.endedAt, DateTime(2026, 10, 28, 9, 30));
  });

  test('out-of-range and negative values are rejected as corrupt', () {
    expect(
      LiveSessionSummary.tryFromJson(_summary(averageScore: 101).toJson()),
      isNull,
    );
    expect(
      LiveSessionSummary.tryFromJson(_summary(averageScore: -1).toJson()),
      isNull,
    );
    expect(
      LiveSessionSummary.tryFromJson(_summary(durationMs: -1).toJson()),
      isNull,
    );
    expect(
      LiveSessionSummary.tryFromJson(_summary(frames: -1).toJson()),
      isNull,
    );
  });

  test('wrong types and bad dates are rejected', () {
    final wrongTypes = _summary().toJson()..['frames'] = '120';
    expect(LiveSessionSummary.tryFromJson(wrongTypes), isNull);

    final badDate = _summary().toJson()..['endedAt'] = 'not-a-date';
    expect(LiveSessionSummary.tryFromJson(badDate), isNull);
  });
}
