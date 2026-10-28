import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:nemro/features/insights/session_csv.dart';
import 'package:nemro/features/live/data/live_session_summary.dart';

/// Writes session history to a local CSV file and hands it to the
/// system share sheet. The file lives in the app's temporary directory
/// and is never uploaded anywhere by this app; what the user does with
/// the share sheet afterwards is their choice.
class SessionExporter {
  const SessionExporter({
    required this.tempDirectory,
    required this.shareFile,
  });

  /// Returns the app's temporary directory.
  final Future<Directory> Function() tempDirectory;

  /// Opens the system share sheet for the file at [path].
  final Future<void> Function(String path) shareFile;

  /// Returns the path of the written CSV file.
  Future<String> export(List<LiveSessionSummary> summaries) async {
    final directory = await tempDirectory();
    final file = File('${directory.path}/nemro-sessions.csv');
    await file.writeAsString(sessionsToCsv(summaries));
    await shareFile(file.path);
    return file.path;
  }
}

final sessionExporterProvider = Provider<SessionExporter>(
  (ref) => SessionExporter(
    tempDirectory: getTemporaryDirectory,
    shareFile: (path) async {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(path)]),
      );
    },
  ),
);
