import 'package:nemro/core/constants/app_constants.dart';
import 'package:nemro/core/l10n/generated/app_localizations.dart';

/// One landmark study, told honestly: what was found, what it does not
/// prove, and where to read it. Every milestone must carry a limit and a
/// source; a milestone without either is a bug, and the content test
/// enforces it.
class ResearchMilestone {
  const ResearchMilestone({
    required this.title,
    required this.body,
    required this.limit,
    required this.source,
    this.url,
  });

  final String title;
  final String body;
  final String limit;
  final String source;

  /// Optional stable link (only the dataset milestone has one).
  final String? url;
}

/// The four milestones shown in Research, in chronological order.
List<ResearchMilestone> researchMilestones(AppLocalizations l10n) => [
  ResearchMilestone(
    title: l10n.researchMilestone1Title,
    body: l10n.researchMilestone1Body,
    limit: l10n.researchMilestone1Limit,
    source: l10n.researchMilestone1Source,
  ),
  ResearchMilestone(
    title: l10n.researchMilestone2Title,
    body: l10n.researchMilestone2Body,
    limit: l10n.researchMilestone2Limit,
    source: l10n.researchMilestone2Source,
  ),
  ResearchMilestone(
    title: l10n.researchMilestone3Title,
    body: l10n.researchMilestone3Body,
    limit: l10n.researchMilestone3Limit,
    source: l10n.researchMilestone3Source,
    url: AppConstants.eegDatasetUrl,
  ),
  ResearchMilestone(
    title: l10n.researchMilestone4Title,
    body: l10n.researchMilestone4Body,
    limit: l10n.researchMilestone4Limit,
    source: l10n.researchMilestone4Source,
  ),
];

/// A self-run camera experiment: 30 seconds of watching one proxy
/// component move, with a fixed interpretation written before the run.
///
/// The interpretation describes what the proxy does, never what the
/// user's mind does. An experiment whose reading claims a mental state
/// must not be added.
class ResearchExperiment {
  const ResearchExperiment({
    required this.id,
    required this.title,
    required this.body,
    required this.reading,
  });

  final String id;
  final String title;
  final String body;

  /// What the result means, fixed in advance so a surprising run cannot
  /// be reinterpreted into a stronger claim afterwards.
  final String reading;
}

List<ResearchExperiment> researchExperiments(AppLocalizations l10n) => [
  ResearchExperiment(
    id: 'still',
    title: l10n.researchExperimentStillTitle,
    body: l10n.researchExperimentStillBody,
    reading: l10n.researchExperimentStillReading,
  ),
  ResearchExperiment(
    id: 'cover',
    title: l10n.researchExperimentCoverTitle,
    body: l10n.researchExperimentCoverBody,
    reading: l10n.researchExperimentCoverReading,
  ),
];
