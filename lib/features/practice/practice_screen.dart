import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nemro/core/l10n/generated/app_localizations.dart';
import 'package:nemro/core/preferences/preferences_providers.dart';
import 'package:nemro/features/live/data/camera_proxy_analyzer.dart';
import 'package:nemro/features/live/data/frame_throttler.dart';
import 'package:nemro/features/live/data/live_camera_gateway.dart';
import 'package:nemro/features/live/data/system_settings_opener.dart';
import 'package:nemro/features/practice/data/breath_pacer.dart';

/// An adaptive breathing session.
///
/// The breathing circle's pace follows the Live camera signal proxy in
/// real time: the exhale stretches when the signal is steady and
/// shortens when it is weak. The camera opens only after **Start**,
/// frames are analyzed in memory like Live, and nothing is recorded,
/// stored, or uploaded. The session summary is shown on screen only;
/// it is never saved to Insights.
///
/// The score is a camera-signal heuristic, not a measure of calm,
/// focus, or any medical state, and the screen copy says so.
class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeSummary {
  const _PracticeSummary({
    required this.averageScore,
    required this.duration,
    required this.cycles,
    required this.pausedByLifecycle,
  });

  /// Null when no frame was analyzed.
  final int? averageScore;
  final Duration duration;
  final int cycles;
  final bool pausedByLifecycle;
}

class _PracticeScreenState extends ConsumerState<PracticeScreen>
    with WidgetsBindingObserver {
  static const int _uiFrameInterval = 2;
  static const List<int> _durationOptions = [1, 3, 5];

  final CameraProxyAnalyzer _analyzer = CameraProxyAnalyzer();
  final AdaptiveBreathPacer _pacer = AdaptiveBreathPacer();

  LiveCameraSession? _session;
  StreamSubscription<LumaFrame>? _frameSubscription;
  Timer? _tickTimer;
  CameraProxySample? _sample;
  LiveCameraFailure? _failure;
  _PracticeSummary? _summary;
  BreathPhaseState _phaseState = const BreathPhaseState(
    phase: BreathPhase.inhale,
    progress: 0,
    phaseDuration: AdaptiveBreathPacer.inhaleDuration,
  );
  DateTime? _startedAt;
  FrameThrottler? _throttler;
  String? _semanticBand;
  int? _semanticScore;
  int _operation = 0;
  int _frameCount = 0;
  int _framesSinceUiUpdate = 0;
  int _scoreCount = 0;
  double _scoreSum = 0;
  int _durationMinutes = 3;
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
      unawaited(_endSession(pausedByLifecycle: true));
    }
  }

  Duration get _sessionDuration => Duration(minutes: _durationMinutes);

  double get _currentScore => _sample?.score ?? 50;

  Future<void> _startSession() async {
    if (_isStarting || _isRunning) return;

    final operation = ++_operation;
    setState(() {
      _isStarting = true;
      _failure = null;
      _summary = null;
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
          debugPrint('Practice session disposal failed: $error');
        }
        return;
      }

      _session = session;
      _analyzer.reset();
      _pacer.start();
      _sample = null;
      _semanticBand = null;
      _semanticScore = null;
      _throttler = ref.read(frameThrottlerProvider);
      _throttler!.reset();
      _startedAt = DateTime.now();
      _frameCount = 0;
      _framesSinceUiUpdate = 0;
      _scoreCount = 0;
      _scoreSum = 0;
      _phaseState = _pacer.update(_currentScore);
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
        await _endSession(pausedByLifecycle: true);
      }
    } on LiveCameraException catch (error) {
      if (!mounted || operation != _operation) return;
      setState(() {
        _isStarting = false;
        _isRunning = false;
        _failure = error.failure;
      });
    } catch (error) {
      debugPrint('Practice camera start failed: $error');
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
    _scoreCount++;
    _framesSinceUiUpdate++;
    if (_framesSinceUiUpdate < _uiFrameInterval) return;
    _framesSinceUiUpdate = 0;
    if (!mounted) return;
    setState(() {
      _sample = sample;
      _phaseState = _pacer.update(sample.score);
      // Announce the score only when its band changes, so a screen
      // reader is not spammed by every frame.
      final band = _bandForScore(sample.roundedScore);
      if (band != _semanticBand) {
        _semanticBand = band;
        _semanticScore = sample.roundedScore;
      }
    });
  }

  void _onTick() {
    if (!_isRunning || _disposed || !mounted) return;
    final startedAt = _startedAt;
    if (startedAt == null) return;
    final elapsed = DateTime.now().difference(startedAt);
    setState(() {
      _phaseState = _pacer.update(_currentScore);
    });
    if (elapsed >= _sessionDuration) {
      unawaited(_endSession());
    }
  }

  Future<void> _endSession({bool pausedByLifecycle = false}) async {
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

    final startedAt = _startedAt;
    final duration = startedAt == null
        ? Duration.zero
        : DateTime.now().difference(startedAt);
    final summary = _PracticeSummary(
      averageScore: _scoreCount == 0
          ? null
          : (_scoreSum / _scoreCount).round().clamp(0, 100),
      duration: duration,
      cycles: _pacer.completedCycles,
      pausedByLifecycle: pausedByLifecycle,
    );
    _pacer.reset();
    if (!mounted) return;
    setState(() {
      _isRunning = false;
      _isStarting = false;
      _summary = summary;
    });
  }

  static String _bandForScore(int score) {
    if (score >= 67) return 'high';
    if (score >= 34) return 'medium';
    return 'low';
  }

  String _phaseLabel(BreathPhase phase, AppLocalizations l10n) =>
      switch (phase) {
        BreathPhase.inhale => l10n.practiceInhale,
        BreathPhase.holdAfterInhale => l10n.practiceHold,
        BreathPhase.exhale => l10n.practiceExhale,
        BreathPhase.holdAfterExhale => l10n.practiceHold,
      };

  double _circleSize(BreathPhaseState state) {
    const min = 120.0;
    const max = 220.0;
    switch (state.phase) {
      case BreathPhase.inhale:
        return min + state.progress * (max - min);
      case BreathPhase.holdAfterInhale:
        return max;
      case BreathPhase.exhale:
        return max - state.progress * (max - min);
      case BreathPhase.holdAfterExhale:
        return min;
    }
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return PopScope(
      // Back while running ends the session and shows its summary
      // instead of leaving the screen mid-session.
      canPop: !_isRunning,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isRunning) unawaited(_endSession());
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.practiceTitle)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _isRunning
                ? _buildRunning(l10n, theme)
                : _buildIdle(l10n, theme),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildIdle(AppLocalizations l10n, ThemeData theme) {
    final failure = _failure;
    final summary = _summary;
    return [
      Text(
        l10n.practiceIntro,
        style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
      ),
      const SizedBox(height: 12),
      Text(
        l10n.practiceHonestNote,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
      ),
      if (failure != null) ...[
        const SizedBox(height: 20),
        Card(
          elevation: 0,
          color: theme.colorScheme.errorContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                Text(
                  _failureMessage(failure, l10n),
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _startSession,
                  child: Text(l10n.liveStartAgain),
                ),
                if (failure ==
                    LiveCameraFailure.permissionPermanentlyDenied) ...[
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () async {
                      try {
                        await ref
                            .read(systemSettingsOpenerProvider)
                            .openAppSettings();
                      } catch (_) {
                        // Opening system settings must not crash the screen.
                      }
                    },
                    child: Text(l10n.liveOpenSettings),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
      if (summary != null) ...[
        const SizedBox(height: 20),
        Card(
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
                  l10n.practiceSummaryTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  summary.averageScore == null
                      ? l10n.liveSummaryNoFrames
                      : '${l10n.practiceSummaryAverage}: '
                            '${summary.averageScore}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.practiceSummaryDuration}: '
                  '${_formatDuration(summary.duration)}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.practiceSummaryCycles}: ${summary.cycles}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.liveSummaryFrames}: $_frameCount',
                  style: theme.textTheme.bodyMedium,
                ),
                if (summary.pausedByLifecycle) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.liveSummaryPaused,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
      const SizedBox(height: 20),
      Text(
        l10n.practiceDurationLabel,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: _durationOptions.map((minutes) {
          return ChoiceChip(
            key: ValueKey('practice-duration-$minutes'),
            label: Text(l10n.practiceMinutes(minutes)),
            selected: _durationMinutes == minutes,
            onSelected: (selected) {
              if (!selected) return;
              setState(() => _durationMinutes = minutes);
            },
          );
        }).toList(),
      ),
      const SizedBox(height: 20),
      if (_isStarting)
        const Center(child: CircularProgressIndicator())
      else
        FilledButton.icon(
          key: const ValueKey('practice-start-button'),
          onPressed: _startSession,
          icon: const Icon(Icons.self_improvement_outlined),
          label: Text(
            summary != null
                ? l10n.practiceStartAgain
                : l10n.practiceStartButton,
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
    final sample = _sample;
    final startedAt = _startedAt;
    final remaining = startedAt == null
        ? _sessionDuration
        : _sessionDuration - DateTime.now().difference(startedAt);
    final remainingText = _formatDuration(
      remaining.isNegative ? Duration.zero : remaining,
    );
    final score = sample?.roundedScore;
    return [
      if (session != null)
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: session.aspectRatio,
            child: session.buildPreview(),
          ),
        ),
      const SizedBox(height: 24),
      Center(
        child: Container(
          key: const ValueKey('practice-breathing-circle'),
          width: _circleSize(_phaseState),
          height: _circleSize(_phaseState),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primaryContainer,
          ),
        ),
      ),
      const SizedBox(height: 24),
      Text(
        _phaseLabel(_phaseState.phase, l10n),
        key: const ValueKey('practice-phase-label'),
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        '${l10n.practiceRemaining}: $remainingText',
        key: const ValueKey('practice-remaining-label'),
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 8),
      Semantics(
        label: _semanticScore == null
            ? l10n.liveScoreWaiting
            : l10n.liveScoreSemantics(_semanticScore!),
        child: Text(
          score == null
              ? l10n.liveScoreWaiting
              : '${l10n.liveScoreTitle}: $score',
          key: const ValueKey('practice-score-label'),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      const SizedBox(height: 24),
      FilledButton.icon(
        key: const ValueKey('practice-stop-button'),
        onPressed: () => unawaited(_endSession()),
        icon: const Icon(Icons.stop_rounded),
        label: Text(l10n.practiceStopButton),
      ),
    ];
  }
}
