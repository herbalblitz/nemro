import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nemro/core/preferences/preferences_providers.dart';
import 'package:nemro/features/live/data/live_session_summary.dart';

/// Persists completed Live session summaries on this device only.
///
/// Storage is opt-in (see [saveLiveSummariesProvider]): nothing is
/// written unless the user turns saving on in Settings. History is capped
/// so it cannot grow without bound, and deleting all local data in
/// Settings wipes these summaries together with every other preference.
class LiveSessionStore {
  LiveSessionStore(this._prefs);

  static const storageKey = 'live_session_summaries';
  static const maxSaved = 50;

  final SharedPreferences _prefs;

  List<LiveSessionSummary> loadSync() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final summaries = <LiveSessionSummary>[];
      for (final entry in decoded) {
        if (entry is Map<String, dynamic>) {
          final summary = LiveSessionSummary.tryFromJson(entry);
          if (summary != null) summaries.add(summary);
        }
      }
      return summaries;
    } catch (error) {
      debugPrint('Could not parse saved Live sessions: $error');
      return const [];
    }
  }

  Future<void> save(LiveSessionSummary summary) async {
    final summaries = [...loadSync(), summary];
    final trimmed = summaries.length > maxSaved
        ? summaries.sublist(summaries.length - maxSaved)
        : summaries;
    await _prefs.setString(
      storageKey,
      jsonEncode(trimmed.map((entry) => entry.toJson()).toList()),
    );
  }

  /// Removes exactly one session by its position in storage order
  /// (oldest first). Index-based, not value-based, so two sessions
  /// with identical scores and timestamps cannot be confused.
  Future<void> deleteAt(int index) async {
    final summaries = loadSync();
    if (index < 0 || index >= summaries.length) return;
    summaries.removeAt(index);
    await _prefs.setString(
      storageKey,
      jsonEncode(summaries.map((entry) => entry.toJson()).toList()),
    );
  }

  Future<void> clear() async {
    await _prefs.remove(storageKey);
  }
}

final liveSessionStoreProvider = Provider<LiveSessionStore>(
  (ref) => LiveSessionStore(ref.watch(sharedPreferencesProvider)),
);
