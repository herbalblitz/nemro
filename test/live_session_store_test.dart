import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nemro/core/preferences/preferences_providers.dart';
import 'package:nemro/features/live/data/live_session_store.dart';
import 'package:nemro/features/live/data/live_session_summary.dart';

LiveSessionSummary _summary(int score) => LiveSessionSummary(
  averageScore: score,
  duration: const Duration(seconds: 60),
  frames: 120,
  endedAt: DateTime(2026, 10, 28, 9, 30),
);

void main() {
  test('store round-trips summaries', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = LiveSessionStore(prefs);
    expect(store.loadSync(), isEmpty);

    await store.save(_summary(80));
    await store.save(_summary(42));

    final loaded = store.loadSync();
    expect(loaded.map((entry) => entry.averageScore), [80, 42]);
    expect(loaded.first.duration, const Duration(seconds: 60));
    expect(loaded.first.frames, 120);
    expect(loaded.first.endedAt, DateTime(2026, 10, 28, 9, 30));
  });

  test('corrupt stored data loads as empty instead of crashing', () async {
    SharedPreferences.setMockInitialValues({
      LiveSessionStore.storageKey: 'not-json{{{',
    });
    final prefs = await SharedPreferences.getInstance();
    expect(LiveSessionStore(prefs).loadSync(), isEmpty);
  });

  test('history is capped at the newest entries', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = LiveSessionStore(prefs);
    for (var i = 0; i < LiveSessionStore.maxSaved + 5; i++) {
      await store.save(_summary(i));
    }
    final loaded = store.loadSync();
    expect(loaded.length, LiveSessionStore.maxSaved);
    expect(loaded.first.averageScore, 5);
    expect(loaded.last.averageScore, LiveSessionStore.maxSaved + 4);
  });

  test('deleteAt removes exactly one session by position', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = LiveSessionStore(prefs);
    await store.save(_summary(80));
    await store.save(_summary(90));
    await store.save(_summary(70));

    await store.deleteAt(1);
    expect(store.loadSync().map((entry) => entry.averageScore), [80, 70]);

    // Out-of-range deletes are no-ops, never crashes.
    await store.deleteAt(-1);
    await store.deleteAt(5);
    expect(store.loadSync().map((entry) => entry.averageScore), [80, 70]);
  });

  test('save toggle defaults to off and persists', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(saveLiveSummariesProvider), isFalse);
    await container.read(saveLiveSummariesProvider.notifier).setValue(true);
    expect(container.read(saveLiveSummariesProvider), isTrue);
    expect(prefs.getBool('save_live_summaries'), isTrue);
  });
}
