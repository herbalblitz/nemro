import 'package:nemro/features/live/data/live_session_summary.dart';

/// Session history as CSV, for local export only.
///
/// Columns are plain numbers and ISO 8601 timestamps, so no field ever
/// contains a comma and no quoting is needed. Duration is whole seconds,
/// matching the m:ss display elsewhere (both truncate, never round up).
String sessionsToCsv(List<LiveSessionSummary> summaries) {
  final buffer = StringBuffer(
    'ended_at,average_score,duration_seconds,frames',
  );
  for (final summary in summaries) {
    buffer.write(
      '\n${summary.endedAt.toIso8601String()}'
      ',${summary.averageScore}'
      ',${summary.duration.inSeconds}'
      ',${summary.frames}',
    );
  }
  return buffer.toString();
}
