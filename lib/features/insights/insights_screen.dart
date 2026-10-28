import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nemro/core/l10n/generated/app_localizations.dart';
import 'package:nemro/core/preferences/preferences_providers.dart';
import 'package:nemro/core/widgets/empty_state_card.dart';
import 'package:nemro/features/live/data/live_session_store.dart';
import 'package:nemro/features/live/data/live_session_summary.dart';

/// Saved Live session history.
///
/// Summaries only exist here when the user turns saving on in Settings;
/// with saving off, Live sessions stay memory-only and this screen keeps
/// its empty state. Deleting all local data in Settings wipes this list.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final summaries = ref.watch(liveSessionStoreProvider).loadSync();
    final savingOn = ref.watch(saveLiveSummariesProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: Text(
            l10n.insightsTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          sliver: summaries.isEmpty
              ? SliverList(
                  delegate: SliverChildListDelegate([
                    EmptyStateCard(
                      icon: Icons.insights_rounded,
                      title: l10n.insightsEmptyTitle,
                      body: savingOn
                          ? l10n.insightsEmptySavedOn
                          : l10n.insightsEmptySavedOff,
                      actionLabel: l10n.insightsStart,
                      onAction: () => context.push('/live'),
                    ),
                  ]),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            l10n.insightsSavedTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      }
                      final summary = summaries[summaries.length - index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SavedSessionCard(
                          summary: summary,
                          l10n: l10n,
                        ),
                      );
                    },
                    childCount: summaries.length + 1,
                  ),
                ),
        ),
      ],
    );
  }
}

class _SavedSessionCard extends StatelessWidget {
  const _SavedSessionCard({required this.summary, required this.l10n});

  final LiveSessionSummary summary;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            '${summary.averageScore}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        title: Text(_formatDateTime(summary.endedAt)),
        subtitle: Text(
          '${l10n.liveSummaryDuration}: ${_formatDuration(summary.duration)}'
          ' · ${l10n.liveSummaryFrames}: ${summary.frames}',
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.day}/${value.month}/${value.year} $hour:$minute';
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
