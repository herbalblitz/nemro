import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nemro/core/l10n/generated/app_localizations.dart';
import 'package:nemro/core/theme/app_theme.dart';
import 'package:nemro/features/live/data/attention_analyzer.dart';
import 'package:nemro/features/live/data/live_camera_gateway.dart';
import 'package:nemro/features/live/data/live_session_summary.dart';

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen>
    with WidgetsBindingObserver {
  static const int _uiFrameInterval = 2;

  final AttentionAnalyzer _analyzer = AttentionAnalyzer();

  LiveCameraSession? _session;
  StreamSubscription<LumaFrame>? _frameSubscription;
  AttentionSample? _sample;
  LiveSessionSummary? _summary;
  LiveCameraFailure? _failure;
  DateTime? _startedAt;
  int _operation = 0;
  int _frameCount = 0;
  int _framesSinceUiUpdate = 0;
  int _scoreCount = 0;
  double _scoreSum = 0;
  bool _isStarting = false;
  bool _isRunning = false;
  bool _pausedByLifecycle = false;
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
      unawaited(_stopSession(pausedByLifecycle: true));
    }
  }

  Future<void> _startSession() async {
    if (_isStarting || _isRunning) return;

    final operation = ++_operation;
    setState(() {
      _isStarting = true;
      _failure = null;
      _summary = null;
      _pausedByLifecycle = false;
    });

    try {
      final session = await ref.read(liveCameraGatewayProvider).start();
      if (!mounted || operation != _operation) {
        try {
          await session.dispose();
        } catch (_) {
          // The screen is gone; there is nothing else to clean up.
        }
        return;
      }

      _session = session;
      _analyzer.reset();
      _sample = null;
      _startedAt = DateTime.now();
      _frameCount = 0;
      _framesSinceUiUpdate = 0;
      _scoreCount = 0;
      _scoreSum = 0;
      _frameSubscription = session.frames.listen(_onFrame);

      setState(() {
        _isStarting = false;
        _isRunning = true;
      });

      final lifecycleState =
          WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
      if (lifecycleState != AppLifecycleState.resumed) {
        await _stopSession(pausedByLifecycle: true);
      }
    } on LiveCameraException catch (error) {
      if (!mounted || operation != _operation) return;
      setState(() {
        _isStarting = false;
        _isRunning = false;
        _failure = error.failure;
      });
    } catch (_) {
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

    final sample = _analyzer.addFrame(frame);
    _frameCount++;
    _scoreSum += sample.score;
    _scoreCount++;
    _framesSinceUiUpdate++;
    if (_framesSinceUiUpdate < _uiFrameInterval) return;
    _framesSinceUiUpdate = 0;
    if (!mounted) return;
    setState(() => _sample = sample);
  }

  Future<void> _stopSession({bool pausedByLifecycle = false}) async {
    if (!_isRunning) return;
    _operation++;

    final session = _session;
    final subscription = _frameSubscription;
    _session = null;
    _frameSubscription = null;
    final endedAt = DateTime.now();
    final duration = _startedAt == null
        ? Duration.zero
        : endedAt.difference(_startedAt!);
    final average = _scoreCount == 0
        ? 0
        : (_scoreSum / _scoreCount).round().clamp(0, 100).toInt();
    final summary = LiveSessionSummary(
      averageScore: average,
      duration: duration,
      frames: _frameCount,
      endedAt: endedAt,
    );

    if (mounted) {
      setState(() {
        _isRunning = false;
        _isStarting = false;
        _sample = null;
        _summary = summary;
        _failure = null;
        _pausedByLifecycle = pausedByLifecycle;
      });
    }

    final cancelFuture = subscription?.cancel();
    try {
      await session?.dispose();
    } catch (_) {
      // The camera may already have been released by the platform.
    }
    await cancelFuture;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.liveTitle),
        leading: context.canPop()
            ? null
            : IconButton(
                onPressed: () => context.go('/'),
                tooltip: l10n.navHome,
                icon: const Icon(Icons.close_rounded),
              ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (_isRunning)
            ..._buildRunning(l10n, theme)
          else if (_isStarting)
            ..._buildStarting(l10n, theme)
          else
            ..._buildIdle(l10n, theme),
        ],
      ),
    );
  }

  List<Widget> _buildIdle(AppLocalizations l10n, ThemeData theme) {
    final failure = _failure;
    final summary = _summary;
    final showPrivacyBullets = failure == null && summary == null;

    return [
      _HeroCard(l10n: l10n, theme: theme),
      const SizedBox(height: 20),
      if (failure != null) ...[
        _ErrorCard(
          failure: failure,
          onRetry: _startSession,
          l10n: l10n,
          theme: theme,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.livePrivacyNote,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ] else ...[
        if (summary != null) ...[
          _SummaryCard(
            summary: summary,
            pausedByLifecycle: _pausedByLifecycle,
            l10n: l10n,
            theme: theme,
          ),
          const SizedBox(height: 16),
        ],
        FilledButton.icon(
          key: const ValueKey('live-start-button'),
          onPressed: _startSession,
          icon: const Icon(Icons.videocam_outlined),
          label: Text(
            summary != null ? l10n.liveStartAgain : l10n.liveStartButton,
          ),
        ),
        if (showPrivacyBullets) ...[
          const SizedBox(height: 10),
          Text(
            l10n.liveStartingBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          _PrivacyBullets(l10n: l10n, theme: theme),
        ] else ...[
          const SizedBox(height: 16),
          Text(
            l10n.livePrivacyNote,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ],
    ];
  }

  List<Widget> _buildStarting(AppLocalizations l10n, ThemeData theme) {
    return [
      Card(
        elevation: 0,
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 18),
              Text(
                l10n.liveStarting,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.liveStartingBody,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
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
    return [
      if (session != null) _PreviewCard(session: session, l10n: l10n),
      const SizedBox(height: 16),
      _ScoreCard(
        sample: _sample,
        frameCount: _frameCount,
        l10n: l10n,
        theme: theme,
      ),
      const SizedBox(height: 16),
      FilledButton.tonalIcon(
        key: const ValueKey('live-stop-button'),
        onPressed: () => unawaited(_stopSession()),
        icon: const Icon(Icons.stop_circle_outlined),
        label: Text(l10n.liveStopButton),
      ),
      const SizedBox(height: 12),
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
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.indigo, AppColors.indigoDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.indigo.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.center_focus_strong_outlined,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.liveBadge,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.liveStartTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.liveStartBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.session, required this.l10n});

  final LiveCameraSession session;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final rawAspectRatio = session.aspectRatio;
    final cameraAspectRatio = rawAspectRatio.isFinite && rawAspectRatio > 0
        ? rawAspectRatio
        : 4 / 3;
    // CameraPreview reports its ratio in landscape orientation and inverts it
    // in portrait; match that here so the card does not letterbox the preview.
    final aspectRatio =
        MediaQuery.orientationOf(context) == Orientation.portrait
        ? 1 / cameraAspectRatio
        : cameraAspectRatio;
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Semantics(
        label: l10n.livePreviewSemantics,
        child: AspectRatio(
          key: const ValueKey('live-preview'),
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: Colors.black, child: session.buildPreview()),
              const Positioned(top: 12, left: 12, child: _LiveBadge()),
              Positioned(
                right: 12,
                bottom: 12,
                child: _OnDeviceChip(label: l10n.liveBadge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFFF5A5F),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context).liveLiveBadge,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnDeviceChip extends StatelessWidget {
  const _OnDeviceChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.memory_outlined, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.sample,
    required this.frameCount,
    required this.l10n,
    required this.theme,
  });

  final AttentionSample? sample;
  final int frameCount;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final current = sample;
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.liveScoreTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _OnDeviceChip(label: l10n.liveBadge),
              ],
            ),
            const SizedBox(height: 12),
            if (current == null)
              Text(
                l10n.liveScoreWaiting,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else ...[
              Semantics(
                label: l10n.liveScoreSemantics(current.roundedScore),
                excludeSemantics: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${current.roundedScore}',
                      key: const ValueKey('live-score'),
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 4),
                      child: Text(
                        '/100',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _ScoreLevel(
                      score: current.roundedScore,
                      l10n: l10n,
                      theme: theme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: current.roundedScore / 100,
                  minHeight: 10,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              if (current.isWarmingUp) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.liveScoreWarmingUp,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                l10n.liveScoreCaption,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const Divider(height: 24),
              _ComponentBar(
                label: l10n.liveLightLabel,
                value: current.lighting,
                theme: theme,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(height: 10),
              _ComponentBar(
                label: l10n.liveStabilityLabel,
                value: current.stability,
                theme: theme,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                '${l10n.liveFramesLabel}: $frameCount',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScoreLevel extends StatelessWidget {
  const _ScoreLevel({
    required this.score,
    required this.l10n,
    required this.theme,
  });

  final int score;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color background;
    final Color foreground;
    if (score >= 67) {
      label = l10n.liveScoreHigh;
      background = theme.colorScheme.primaryContainer;
      foreground = theme.colorScheme.onPrimaryContainer;
    } else if (score >= 34) {
      label = l10n.liveScoreMedium;
      background = theme.colorScheme.secondaryContainer;
      foreground = theme.colorScheme.onSecondaryContainer;
    } else {
      label = l10n.liveScoreLow;
      background = theme.colorScheme.errorContainer;
      foreground = theme.colorScheme.onErrorContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ComponentBar extends StatelessWidget {
  const _ComponentBar({
    required this.label,
    required this.value,
    required this.theme,
    required this.color,
  });

  final String label;
  final double value;
  final ThemeData theme;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final normalized = value.clamp(0.0, 1.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${(normalized * 100).round()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: normalized,
            minHeight: 6,
            color: color,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.summary,
    required this.pausedByLifecycle,
    required this.l10n,
    required this.theme,
  });

  final LiveSessionSummary summary;
  final bool pausedByLifecycle;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
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
              l10n.liveSummaryTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _SummaryStat(
                    label: l10n.liveSummaryAverage,
                    value: '${summary.averageScore}',
                    theme: theme,
                  ),
                ),
                Expanded(
                  child: _SummaryStat(
                    label: l10n.liveSummaryDuration,
                    value: _formatDuration(summary.duration),
                    theme: theme,
                  ),
                ),
                Expanded(
                  child: _SummaryStat(
                    label: l10n.liveSummaryFrames,
                    value: '${summary.frames}',
                    theme: theme,
                  ),
                ),
              ],
            ),
            if (summary.frames == 0) ...[
              const SizedBox(height: 12),
              Text(
                l10n.liveSummaryNoFrames,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
            if (pausedByLifecycle) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.liveSummaryPaused,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
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

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.failure,
    required this.onRetry,
    required this.l10n,
    required this.theme,
  });

  final LiveCameraFailure failure;
  final VoidCallback onRetry;
  final AppLocalizations l10n;
  final ThemeData theme;

  String get _message {
    return switch (failure) {
      LiveCameraFailure.permissionDenied => l10n.liveErrorPermissionDenied,
      LiveCameraFailure.permissionPermanentlyDenied =>
        l10n.liveErrorPermissionPermanentlyDenied,
      LiveCameraFailure.restricted => l10n.liveErrorRestricted,
      LiveCameraFailure.noCamera => l10n.liveErrorNoCamera,
      LiveCameraFailure.unavailable => l10n.liveErrorUnavailable,
    };
  }

  @override
  Widget build(BuildContext context) {
    final showSettingsHint =
        failure == LiveCameraFailure.permissionPermanentlyDenied;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.error.withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.videocam_off_outlined,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.liveErrorTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      height: 1.4,
                    ),
                  ),
                  if (showSettingsHint) ...[
                    const SizedBox(height: 6),
                    Text(
                      l10n.livePermissionHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    key: const ValueKey('live-retry-button'),
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.commonRetry),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyBullets extends StatelessWidget {
  const _PrivacyBullets({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
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
          children: [
            _Bullet(
              icon: Icons.videocam_outlined,
              text: l10n.liveStartBullet1,
              theme: theme,
            ),
            const Divider(height: 24),
            _Bullet(
              icon: Icons.memory_outlined,
              text: l10n.liveStartBullet2,
              theme: theme,
            ),
            const Divider(height: 24),
            _Bullet(
              icon: Icons.stop_circle_outlined,
              text: l10n.liveStartBullet3,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.icon, required this.text, required this.theme});

  final IconData icon;
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
