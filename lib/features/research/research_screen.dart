import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nemro/core/l10n/generated/app_localizations.dart';
import 'package:nemro/core/preferences/preferences_providers.dart';
import 'package:nemro/features/live/data/camera_proxy_analyzer.dart';
import 'package:nemro/features/live/data/frame_throttler.dart';
import 'package:nemro/features/live/data/live_camera_gateway.dart';
import 'package:nemro/features/live/data/system_settings_opener.dart';
import 'package:nemro/features/research/data/research_content.dart';

/// Research, done honestly and on-device.
///
/// Two parts, both offline and both non-medical:
/// - Milestone explainers: four landmark findings, each with its limit
///   and its source. Nothing here is presented as settled science
///   beyond what the citation supports.
/// - Self-run experiments: 30-second camera runs that show how the
///   proxy reacts to motion and to a covered lens. The interpretation
///   is fixed before the run and describes the signal only, never a
///   mental state. Results stay on screen; nothing is saved or
///   uploaded.
class ResearchScreen extends ConsumerStatefulWidget {
  const ResearchScreen({super.key});

  @override
  ConsumerState<ResearchScreen> createState() => _ResearchScreenState();
}

class _ExperimentResult {
  const _ExperimentResult({
    required this.experiment,
    required this.averageScore,
    required this.averageStability,
    required this.averageLighting,
    required this.averagePresence,
    required this.frames,
    required this.pausedByLifecycle,
  });

  final ResearchExperiment experiment;

  /// Null when no frame was analyzed.
  final int? averageScore;
  final int? averageStability;
  final int? averageLighting;
  final int? averagePresence;
  final int frames;
  final bool pausedByLifecycle;
}

class _ResearchScreenState extends ConsumerState<ResearchScreen>
    with WidgetsBindingObserver {
  static const int _uiFrameInterval = 2;
  static const Duration _experimentDuration = Duration(seconds: 30);

  final CameraProxyAnalyzer _analyzer = CameraProxyAnalyzer();

  ResearchExperiment? _runningExperiment;
  LiveCameraSession? _session;
  StreamSubscription<LumaFrame>? _frameSubscription;
  Timer? _tickTimer;
  CameraProxySample? _sample;
  LiveCameraFailure? _failure;
  _ExperimentResult? _result;
  DateTime? _startedAt;
  FrameThrottler? _throttler;
  int _operation = 0;
  int _frameCount = 0;
  int _framesSinceUiUpdate = 0;
  int _scoreCount = 0;
  double _scoreSum = 0;
  double _stabilitySum = 0;
  double _lightingSum = 0;
  double _presenceSum = 0;
  bool _isStarting = false;
  bool _isRunning = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _operation++;
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _tickTimer?.cancel();
    final subscription = _frameSubscription;
    _frameSubscription = null;
    unawaited(subscription?.cancel() ?? Future<void>.value());
    final session = _session;
    _session = null;
    unawaited(session?.dispose() ?? Future<void>.value());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isRunning &&
        (state == AppLifecycleState.inactive ||
            state == AppLifecycleState.paused ||
            state == AppLifecycleState.detached)) {
      unawaited(_endExperiment(pausedByLifecycle: true));
    }
  }

  Future<void> _startExperiment(ResearchExperiment experiment) async {
    if (_isStarting || _isRunning) return;

    final operation = ++_operation;
    setState(() {
      _isStarting = true;
      _failure = null;
      _result = null;
      _runningExperiment = experiment;
    });

    try {
      final lensDirection = ref.read(liveCameraLensProvider);
      final session = await ref
          .read(liveCameraGatewayProvider)
          .start(lensDirection: lensDirection);
      if (!mounted || operation != _operation) {
        try {
          await session.dispose();
        } catch (error) {
          debugPrint('Research session disposal failed: $error');
        }
        return;
      }

      _session = session;
      _analyzer.reset();
      _sample = null;
      _throttler = ref.read(frameThrottlerProvider);
      _throttler!.reset();
      _startedAt = DateTime.now();
      _frameCount = 0;
      _framesSinceUiUpdate = 0;
      _scoreCount = 0;
      _scoreSum = 0;
      _stabilitySum = 0;
      _lightingSum = 0;
      _presenceSum = 0;
      _frameSubscription = session.frames.listen((frame) {
        if (identical(session, _session)) _onFrame(frame);
      });
      _tickTimer?.cancel();
      _tickTimer = Timer.periodic(
        const Duration(milliseconds: 100),
        (_) => _onTick(),
      );

      setState(() {
        _isStarting = false;
        _isRunning = true;
      });

      final lifecycleState =
          WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
      if (lifecycleState != AppLifecycleState.resumed) {
        await _endExperiment(pausedByLifecycle: true);
      }
    } on LiveCameraException catch (error) {
      if (!mounted || operation != _operation) return;
      setState(() {
        _isStarting = false;
        _isRunning = false;
        _failure = error.failure;
      });
    } catch (error) {
      debugPrint('Research camera start failed: $error');
      if (!mounted || operation != _operation) return;
      setState(() {
        _isStarting = false;
        _isRunning = false;
        _failure = LiveCameraFailure.unavailable;
      });
    }
  }

  void _onFrame(LumaFrame frame) {
    if (!_isRunning || _disposed) return;

    final throttler = _throttler;
    if (throttler != null && !throttler.shouldAnalyze()) return;

    final sample = _analyzer.addFrame(frame);
    _frameCount++;
    _scoreSum += sample.score;
    _stabilitySum += sample.stability;
    _lightingSum += sample.lighting;
    _presenceSum += sample.presence;
    _scoreCount++;
    _framesSinceUiUpdate++;
    if (_framesSinceUiUpdate < _uiFrameInterval) return;
    _framesSinceUiUpdate = 0;
    if (!mounted) return;
    setState(() => _sample = sample);
  }

  void _onTick() {
    if (!_isRunning || _disposed || !mounted) return;
    final startedAt = _startedAt;
    if (startedAt == null) return;
    setState(() {});
    if (DateTime.now().difference(startedAt) >= _experimentDuration) {
      unawaited(_endExperiment());
    }
  }

  Future<void> _endExperiment({bool pausedByLifecycle = false}) async {
    if (!_isRunning && _session == null) return;
    _operation++;
    _tickTimer?.cancel();
    _tickTimer = null;
    final subscription = _frameSubscription;
    _frameSubscription = null;
    final session = _session;
    _session = null;
    unawaited(subscription?.cancel().then((_) {}).catchError((_) {}));
    unawaited(session?.dispose().then((_) {}).catchError((_) {}));

    final experiment = _runningExperiment;
    if (experiment == null || !mounted) {
      if (mounted) {
        setState(() {
          _isRunning = false;
          _isStarting = false;
        });
      }
      return;
    }
    int? average(double sum) => _scoreCount == 0
        ? null
        : (sum / _scoreCount * 100).round().clamp(0, 100);
    final result = _ExperimentResult(
      experiment: experiment,
      averageScore: _scoreCount == 0
          ? null
          : (_scoreSum / _scoreCount).round().clamp(0, 100),
      averageStability: average(_stabilitySum),
      averageLighting: average(_lightingSum),
      averagePresence: average(_presenceSum),
      frames: _frameCount,
      pausedByLifecycle: pausedByLifecycle,
    );
    setState(() {
      _isRunning = false;
      _isStarting = false;
      _result = result;
    });
  }

  String _failureMessage(LiveCameraFailure failure, AppLocalizations l10n) =>
      switch (failure) {
        LiveCameraFailure.permissionDenied => l10n.liveErrorPermissionDenied,
        LiveCameraFailure.permissionPermanentlyDenied =>
          l10n.liveErrorPermissionPermanentlyDenied,
        LiveCameraFailure.restricted => l10n.liveErrorRestricted,
        LiveCameraFailure.noCamera => l10n.liveErrorNoCamera,
        LiveCameraFailure.unavailable => l10n.liveErrorUnavailable,
      };

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    return '${(totalSeconds ~/ 60).toString().padLeft(2, '0')}:'
        '${(totalSeconds % 60).toString().padLeft(2, '0')}';
  }

  Future<void> _openUrl(String url, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    final launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.commonError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return PopScope(
      // Back while running ends the experiment and shows its result
      // instead of leaving the screen mid-run.
      canPop: !_isRunning,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isRunning) unawaited(_endExperiment());
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.researchTitle)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _isRunning || _isStarting
                ? _buildRunning(l10n, theme)
                : _buildIdle(l10n, theme),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildIdle(AppLocalizations l10n, ThemeData theme) {
    final failure = _failure;
    final result = _result;
    final milestones = researchMilestones(l10n);
    final experiments = researchExperiments(l10n);
    return [
      Text(
        l10n.researchSubtitle,
        style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
      ),
      const SizedBox(height: 12),
      Text(
        l10n.researchHonestNote,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
      ),
      if (failure != null) ...[
        const SizedBox(height: 20),
        _ErrorCard(
          message: _failureMessage(failure, l10n),
          showSettings:
              failure == LiveCameraFailure.permissionPermanentlyDenied,
          onRetry: () {
            final experiment = _runningExperiment;
            if (experiment != null) unawaited(_startExperiment(experiment));
          },
          onOpenSettings: () async {
            try {
              await ref.read(systemSettingsOpenerProvider).openAppSettings();
            } catch (_) {
              // Opening system settings must not crash the screen.
            }
          },
          l10n: l10n,
          theme: theme,
        ),
      ],
      if (result != null) ...[
        const SizedBox(height: 20),
        _ResultCard(
          result: result,
          onRunAgain: () => unawaited(_startExperiment(result.experiment)),
          onBackToList: () => setState(() => _result = null),
          l10n: l10n,
          theme: theme,
        ),
      ],
      const SizedBox(height: 24),
      Text(
        l10n.researchMilestonesTitle,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 12),
      for (final milestone in milestones) ...[
        _MilestoneCard(
          milestone: milestone,
          onOpenUrl: (url) => unawaited(_openUrl(url, l10n)),
          l10n: l10n,
        ),
        const SizedBox(height: 10),
      ],
      const SizedBox(height: 24),
      Text(
        l10n.researchExperimentsTitle,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 12),
      for (final experiment in experiments) ...[
        _ExperimentCard(
          experiment: experiment,
          onStart: () => unawaited(_startExperiment(experiment)),
          l10n: l10n,
          theme: theme,
        ),
        const SizedBox(height: 10),
      ],
      const SizedBox(height: 16),
      Text(
        l10n.livePrivacyNote,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
      ),
    ];
  }

  List<Widget> _buildRunning(AppLocalizations l10n, ThemeData theme) {
    final session = _session;
    final experiment = _runningExperiment;
    final sample = _sample;
    final startedAt = _startedAt;
    final remaining = startedAt == null
        ? _experimentDuration
        : _experimentDuration - DateTime.now().difference(startedAt);
    final remainingText = _formatDuration(
      remaining.isNegative ? Duration.zero : remaining,
    );
    return [
      if (experiment != null)
        Text(
          experiment.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      const SizedBox(height: 12),
      if (session != null)
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: session.aspectRatio,
            child: session.buildPreview(),
          ),
        ),
      const SizedBox(height: 20),
      if (_isStarting)
        const Center(child: CircularProgressIndicator())
      else ...[
        Text(
          remainingText,
          key: const ValueKey('research-remaining-label'),
          textAlign: TextAlign.center,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          sample == null
              ? l10n.liveScoreWaiting
              : '${l10n.liveScoreTitle}: ${sample.roundedScore}',
          key: const ValueKey('research-score-label'),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          key: const ValueKey('research-stop-button'),
          onPressed: () => unawaited(_endExperiment()),
          icon: const Icon(Icons.stop_rounded),
          label: Text(l10n.researchStopButton),
        ),
      ],
    ];
  }
}

class _MilestoneCard extends StatefulWidget {
  const _MilestoneCard({
    required this.milestone,
    required this.onOpenUrl,
    required this.l10n,
  });

  final ResearchMilestone milestone;
  final void Function(String url) onOpenUrl;
  final AppLocalizations l10n;

  @override
  State<_MilestoneCard> createState() => _MilestoneCardState();
}

class _MilestoneCardState extends State<_MilestoneCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final milestone = widget.milestone;
    final l10n = widget.l10n;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      milestone.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 22,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 12),
                Text(
                  milestone.body,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.researchLimitLabel}: ${milestone.limit}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.researchSourceLabel}: ${milestone.source}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                if (milestone.url != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => widget.onOpenUrl(milestone.url!),
                    child: Text(l10n.researchOpenSource),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ExperimentCard extends StatelessWidget {
  const _ExperimentCard({
    required this.experiment,
    required this.onStart,
    required this.l10n,
    required this.theme,
  });

  final ResearchExperiment experiment;
  final VoidCallback onStart;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              experiment.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              experiment.body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: ValueKey('research-start-${experiment.id}'),
              onPressed: onStart,
              child: Text(l10n.researchStartButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.showSettings,
    required this.onRetry,
    required this.onOpenSettings,
    required this.l10n,
    required this.theme,
  });

  final String message;
  final bool showSettings;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.errorContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.liveErrorTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(message, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(l10n.liveStartAgain)),
            if (showSettings) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: onOpenSettings,
                child: Text(l10n.liveOpenSettings),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    required this.onRunAgain,
    required this.onBackToList,
    required this.l10n,
    required this.theme,
  });

  final _ExperimentResult result;
  final VoidCallback onRunAgain;
  final VoidCallback onBackToList;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    String percent(int? value) => value == null ? '—' : '$value';
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.researchResultTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              result.experiment.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              result.averageScore == null
                  ? l10n.liveSummaryNoFrames
                  : '${l10n.researchResultAverage}: ${result.averageScore}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.researchResultStability}: '
              '${percent(result.averageStability)}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.researchResultLighting}: '
              '${percent(result.averageLighting)}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.researchResultPresence}: '
              '${percent(result.averagePresence)}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.liveSummaryFrames}: ${result.frames}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              result.experiment.reading,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.researchResultNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            if (result.pausedByLifecycle) ...[
              const SizedBox(height: 8),
              Text(
                l10n.liveSummaryPaused,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              key: const ValueKey('research-run-again-button'),
              onPressed: onRunAgain,
              child: Text(l10n.researchRunAgain),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onBackToList,
              child: Text(l10n.researchBackToList),
            ),
          ],
        ),
      ),
    );
  }
}
