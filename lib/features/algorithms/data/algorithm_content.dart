import 'package:nemro/core/l10n/generated/app_localizations.dart';

/// One algorithm that builds AI, told honestly: what it does, what it
/// does not do, and where to read it. Every card must carry a limit and
/// a source; a card without either is a bug, and the content test
/// enforces it — the same rule as the Research milestones.
class AlgorithmCard {
  const AlgorithmCard({
    required this.title,
    required this.body,
    required this.limit,
    required this.source,
  });

  final String title;
  final String body;
  final String limit;
  final String source;
}

/// The five algorithms shown, in chronological order: the optimizer, the
/// first learner, the teacher, the architecture behind modern models,
/// and the sequence predictor that treats a stream of numbers as a
/// language to continue.
List<AlgorithmCard> algorithmCards(AppLocalizations l10n) => [
  AlgorithmCard(
    title: l10n.algorithmsCard1Title,
    body: l10n.algorithmsCard1Body,
    limit: l10n.algorithmsCard1Limit,
    source: l10n.algorithmsCard1Source,
  ),
  AlgorithmCard(
    title: l10n.algorithmsCard2Title,
    body: l10n.algorithmsCard2Body,
    limit: l10n.algorithmsCard2Limit,
    source: l10n.algorithmsCard2Source,
  ),
  AlgorithmCard(
    title: l10n.algorithmsCard3Title,
    body: l10n.algorithmsCard3Body,
    limit: l10n.algorithmsCard3Limit,
    source: l10n.algorithmsCard3Source,
  ),
  AlgorithmCard(
    title: l10n.algorithmsCard4Title,
    body: l10n.algorithmsCard4Body,
    limit: l10n.algorithmsCard4Limit,
    source: l10n.algorithmsCard4Source,
  ),
  AlgorithmCard(
    title: l10n.algorithmsCard5Title,
    body: l10n.algorithmsCard5Body,
    limit: l10n.algorithmsCard5Limit,
    source: l10n.algorithmsCard5Source,
  ),
];
