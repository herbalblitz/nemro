import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:nemro/features/insights/session_exporter.dart';
import 'package:nemro/features/live/data/live_session_summary.dart';

void main() {
  test('export writes the CSV file and hands its path to the share sheet',
      () async {
    final tempDir = await Directory.systemTemp.createTemp('nemro-export');
    try {
      String? sharedPath;
      final exporter = SessionExporter(
        tempDirectory: () async => tempDir,
        shareFile: (path) async {
          sharedPath = path;
        },
      );

      final summaries = [
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
      ];
      final writtenPath = await exporter.export(summaries);

      expect(sharedPath, writtenPath);
      expect(sharedPath, endsWith('nemro-sessions.csv'));
      final csv = await File(sharedPath!).readAsString();
      expect(
        csv,
        'ended_at,average_score,duration_seconds,frames\n'
        '2026-10-28T09:30:00.000Z,64,150,1234\n'
        '2026-10-27T18:05:00.000Z,87,90,42',
      );
    } finally {
      await tempDir.delete(recursive: true);
    }
  });
}
