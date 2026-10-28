import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nemro/core/l10n/generated/app_localizations.dart';
import 'package:nemro/core/preferences/preferences_providers.dart';
import 'package:nemro/core/widgets/empty_state_card.dart';
import 'package:nemro/features/insights/session_exporter.dart';
import 'package:nemro/features/insights/session_trends.dart';
import 'package:nemro/features/live/data/live_session_store.dart';
import 'package:nemro/features/live/data/live_session_summary.dart';

/// Saved Live session history.
///
/// Summaries only exist here when the user turns saving on in Settings;
/// with saving off, Live sessions stay memory-only and this screen keeps
/// its empty state. Deleting all local data in Settings wipes this list.
/// Stateful so a per-session delete rebuilds this screen from storage
/// right away; Home's latest-session card picks the change up when the
/// user navigates back to it.
class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  Future<void> _export(List<LiveSessionSummary> summaries) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(sessionExporterProvider).export(summaries);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.insightsExportDone)));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.insightsExportFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final summaries = ref.watch(liveSessionStoreProvider).loadSync();
    final savingOn = ref.watch(saveLiveSummariesProvider);
    final trends = computeSessionTrends(summaries);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: Text(
            l10n.insightsTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            if (summaries.isNotEmpty)
              IconButton(
                key: const ValueKey('insights-export-button'),
                onPressed: () => _export(summaries),
                tooltip: l10n.insightsExport,
                icon: const Icon(Icons.share_outlined),
              ),
          ],
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
                          child: _TrendsCard(trends: trends, l10n: l10n),
                        );
                      }
                      if (index == 1) {
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
                      // Displayed newest first; storage is oldest first.
                      final storedIndex = summaries.length - index + 1;
                      final summary = summaries[storedIndex];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SavedSessionCard(
                          summary: summary,
                          deleteKey: ValueKey(
                            'insights-delete-$storedIndex',
                          ),
                          onDelete: () async {
                            await ref
                                .read(liveSessionStoreProvider)
                                .deleteAt(storedIndex);
                            if (mounted) setState(() {});
                          },
                          l10n: l10n,
                        ),
                      );
                    },
                    childCount: summaries.length + 2,
                  ),
                ),
        ),
      ],
    );
  }
}

class _SavedSessionCard extends StatelessWidget {
  const _SavedSessionCard({
    required this.summary,
    required this.deleteKey,
    required this.onDelete,
    required this.l10n,
  });

  final LiveSessionSummary summary;
  final ValueKey<String> deleteKey;
  final VoidCallback onDelete;
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
        trailing: IconButton(
          key: deleteKey,
          onPressed: onDelete,
          tooltip: l10n.insightsDelete,
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ),
    );
  }
}

class _TrendsCard extends StatelessWidget {
  const _TrendsCard({required this.trends, required this.l10n});

  final SessionTrends trends;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final best = trends.best;
    final worst = trends.worst;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.insightsTrendsTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _TrendStat(
                    display: l10n.insightsTrendStreakDays(
                      trends.currentStreakDays,
                    ),
                    label: l10n.insightsTrendCurrentStreak,
                    theme: theme,
                  ),
                ),
                Expanded(
                  child: _TrendStat(
                    display: l10n.insightsTrendStreakDays(
                      trends.longestStreakDays,
                    ),
                    label: l10n.insightsTrendLongestStreak,
                    theme: theme,
                  ),
                ),
              ],
            ),
            if (best != null) ...[
              const Divider(height: 24),
              _TrendSessionRow(
                label: l10n.insightsTrendBest,
                summary: best,
                theme: theme,
              ),
            ],
            if (worst != null) ...[
              const SizedBox(height: 8),
              _TrendSessionRow(
                label: l10n.insightsTrendWorst,
                summary: worst,
                theme: theme,
              ),
            ],
            if (trends.weeklyAverages.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                l10n.insightsTrendWeeklyTitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              for (final week in trends.weeklyAverages)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatDate(week.weekStart),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        '${week.averageScore.round()}'
                        ' · ${l10n.insightsTrendSessions(week.sessions)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrendStat extends StatelessWidget {
  const _TrendStat({
    required this.display,
    required this.label,
    required this.theme,
  });

  final String display;
  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          display,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TrendSessionRow extends StatelessWidget {
  const _TrendSessionRow({
    required this.label,
    required this.summary,
    required this.theme,
  });

  final String label;
  final LiveSessionSummary summary;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Flexible(
          child: Text(
            '${summary.averageScore} · ${_formatDateTime(summary.endedAt)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime value) {
  return '${value.day}/${value.month}/${value.year}';
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
