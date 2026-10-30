import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nemro/core/l10n/generated/app_localizations.dart';
import 'package:nemro/core/theme/app_theme.dart';
import 'package:nemro/core/widgets/empty_state_card.dart';
import 'package:nemro/core/widgets/feature_card.dart';
import 'package:nemro/core/widgets/section_header.dart';
import 'package:nemro/features/live/data/live_session_store.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final summaries = ref.watch(liveSessionStoreProvider).loadSync();
    final latest = summaries.isEmpty ? null : summaries.last;

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text(
            l10n.appName,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              onPressed: () => context.go('/settings'),
              tooltip: l10n.navSettings,
              icon: const Icon(Icons.settings_outlined),
            ),
            const SizedBox(width: 8),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                l10n.homeHeadline,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.homeSubheadline,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              FeatureCard(
                title: l10n.homeLabTitle,
                subtitle: l10n.homeLabSubtitle,
                action: l10n.homeLabAction,
                badge: l10n.homeLabBadge,
                icon: Icons.psychology_alt_outlined,
                gradient: const [AppColors.teal, AppColors.tealDark],
                onTap: () => context.push('/lab'),
              ),
              const SizedBox(height: 16),
              FeatureCard(
                title: l10n.homeLiveTitle,
                subtitle: l10n.homeLiveSubtitle,
                action: l10n.homeLiveAction,
                badge: l10n.homeLiveBadge,
                icon: Icons.visibility_outlined,
                gradient: const [AppColors.indigo, AppColors.indigoDark],
                onTap: () => context.push('/live'),
              ),
              const SizedBox(height: 16),
              FeatureCard(
                title: l10n.homePracticeTitle,
                subtitle: l10n.homePracticeSubtitle,
                action: l10n.homePracticeAction,
                badge: l10n.homePracticeBadge,
                icon: Icons.self_improvement_outlined,
                gradient: const [AppColors.teal, AppColors.indigoDark],
                onTap: () => context.push('/practice'),
              ),
              const SizedBox(height: 16),
              FeatureCard(
                title: l10n.homeResearchTitle,
                subtitle: l10n.homeResearchSubtitle,
                action: l10n.homeResearchAction,
                badge: l10n.homeResearchBadge,
                icon: Icons.biotech_outlined,
                gradient: const [AppColors.indigoDark, AppColors.teal],
                onTap: () => context.push('/research'),
              ),
              const SizedBox(height: 28),
              SectionHeader(title: l10n.homeRecentTitle),
              const SizedBox(height: 12),
              if (latest == null)
                EmptyStateCard(
                  icon: Icons.history_rounded,
                  title: l10n.insightsEmptyTitle,
                  body: l10n.homeRecentEmpty,
                  actionLabel: l10n.homeRecentAction,
                  onAction: () => context.push('/lab'),
                )
              else
                // The latest saved Live session, so this card never claims
                // "no saved sessions" while Insights lists some.
                EmptyStateCard(
                  icon: Icons.history_rounded,
                  title: l10n.insightsSavedTitle,
                  body:
                      '${l10n.liveSummaryAverage}: ${latest.averageScore} · '
                      '${l10n.liveSummaryFrames}: ${latest.frames}',
                  actionLabel: l10n.navInsights,
                  onAction: () => context.go('/insights'),
                ),
              const SizedBox(height: 24),
              Text(
                l10n.homeFooter,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
