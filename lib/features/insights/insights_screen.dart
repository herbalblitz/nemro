import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nemro/core/l10n/generated/app_localizations.dart';
import 'package:nemro/core/widgets/empty_state_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              EmptyStateCard(
                icon: Icons.insights_rounded,
                title: l10n.insightsEmptyTitle,
                body: l10n.insightsEmptyBody,
                actionLabel: l10n.insightsStart,
                onAction: () => context.push('/live'),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
