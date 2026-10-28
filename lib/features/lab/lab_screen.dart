import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nemro/core/constants/app_constants.dart';
import 'package:nemro/core/l10n/generated/app_localizations.dart';
import 'package:nemro/core/theme/app_theme.dart';
import 'package:nemro/features/lab/data/eeg_decoder.dart';
import 'package:nemro/features/lab/data/eeg_decoder_repository.dart';
import 'package:nemro/features/lab/data/eeg_recording.dart';
import 'package:nemro/features/lab/data/eeg_repository.dart';
import 'package:nemro/features/lab/widgets/eeg_chart.dart';

class LabScreen extends ConsumerWidget {
  const LabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedId = ref.watch(selectedLabRecordingProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.labTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<String>(
                segments: [
                  for (final recording in labRecordings)
                    ButtonSegment(
                      value: recording.id,
                      label: Text(recording.label),
                    ),
                ],
                selected: {selectedId},
                showSelectedIcon: false,
                onSelectionChanged: (selection) {
                  ref
                      .read(selectedLabRecordingProvider.notifier)
                      .select(selection.first);
                },
              ),
            ),
          ),
          Expanded(
            child: ref
                .watch(eegRecordingProvider)
                .when(
                  loading: () => const _LoadingState(),
                  error: (error, stackTrace) => _ErrorState(
                    onRetry: () => ref.invalidate(eegRecordingProvider),
                  ),
                  data: (recording) => _LabContent(recording: recording),
                ),
          ),
        ],
      ),
    );
  }
}

class _LabContent extends StatefulWidget {
  const _LabContent({required this.recording});

  final EegRecording recording;

  @override
  State<_LabContent> createState() => _LabContentState();
}

class _LabContentState extends State<_LabContent>
    with WidgetsBindingObserver {
  static const _windowSeconds = 10.0;
  static const _tick = Duration(milliseconds: 50);

  Timer? _timer;
  double _position = 0;
  double _speed = 1;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _playing) {
      _pause();
    }
  }

  void _togglePlay() {
    if (_playing) {
      _pause();
      return;
    }

    if (_position >= widget.recording.duration) {
      _position = 0;
    }

    setState(() => _playing = true);
    _timer = Timer.periodic(_tick, (_) {
      if (!mounted) return;
      setState(() {
        _position = math.min(
          widget.recording.duration,
          _position + _tick.inMilliseconds / 1000 * _speed,
        );
        if (_position >= widget.recording.duration) {
          _playing = false;
          _timer?.cancel();
          _timer = null;
        }
      });
    });
  }

  void _pause() {
    _timer?.cancel();
    _timer = null;
    setState(() => _playing = false);
  }

  void _restart() {
    setState(() => _position = 0);
  }

  void _seek(double value) {
    setState(() {
      _position = value.clamp(0.0, widget.recording.duration).toDouble();
    });
  }

  Future<void> _openDataset() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final launched = await launchUrl(
      Uri.parse(AppConstants.eegDatasetUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.commonError)));
    }
  }

  Future<void> _openLicense() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final launched = await launchUrl(
      Uri.parse(AppConstants.eegLicenseUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.commonError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final recording = widget.recording;
    final windowSeconds = math.min(_windowSeconds, recording.duration);
    final maxWindowStart = math.max(0.0, recording.duration - windowSeconds);
    final windowStart = (_position - windowSeconds * 0.8)
        .clamp(0.0, maxWindowStart)
        .toDouble();
    final event = recording.eventAt(_position);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          l10n.labReplayTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.labReplayIntro,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 20),
        _ReplayCard(
          recording: recording,
          position: _position,
          windowStart: windowStart,
          windowSeconds: windowSeconds,
          playing: _playing,
          speed: _speed,
          event: event,
          onPlay: _togglePlay,
          onRestart: _restart,
          onSeek: _seek,
          onSpeed: (speed) => setState(() => _speed = speed),
        ),
        const SizedBox(height: 16),
        _DecoderCard(recording: recording, event: event),
        const SizedBox(height: 16),
        _DatasetCard(
          recording: recording,
          onOpenDataset: _openDataset,
          onOpenLicense: _openLicense,
        ),
        const SizedBox(height: 24),
        FilledButton.tonal(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
          child: Text(l10n.commonBack),
        ),
      ],
    );
  }
}

class _ReplayCard extends StatelessWidget {
  const _ReplayCard({
    required this.recording,
    required this.position,
    required this.windowStart,
    required this.windowSeconds,
    required this.playing,
    required this.speed,
    required this.event,
    required this.onPlay,
    required this.onRestart,
    required this.onSeek,
    required this.onSpeed,
  });

  final EegRecording recording;
  final double position;
  final double windowStart;
  final double windowSeconds;
  final bool playing;
  final double speed;
  final EegEvent? event;
  final VoidCallback onPlay;
  final VoidCallback onRestart;
  final ValueChanged<double> onSeek;
  final ValueChanged<double> onSpeed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final eventColor = _eventColor(event);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF071A24), Color(0xFF0E3A46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                const Icon(
                  Icons.monitor_heart_outlined,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.labChannelSummary(
                      recording.channels.length,
                      recording.samplingRate.round(),
                    ),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.teal.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Text(
                    l10n.labReplayBadge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 280,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
              child: EegChart(
                recording: recording,
                windowStart: windowStart,
                windowSeconds: windowSeconds,
                position: position,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    activeTrackColor: AppColors.teal,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.16),
                    thumbColor: Colors.white,
                    overlayColor: Colors.white.withValues(alpha: 0.12),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                  ),
                  child: Slider(
                    value: position.clamp(0.0, recording.duration).toDouble(),
                    max: recording.duration,
                    onChanged: onSeek,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${_formatTime(position)} / '
                            '${_formatTime(recording.duration)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SpeedSelector(speed: speed, onChanged: onSpeed),
                  ],
                ),
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.labWindowLabel(windowSeconds.round()),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 9,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onPlay,
                        icon: Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(playing ? l10n.labPause : l10n.labPlay),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.outlined(
                      onPressed: onRestart,
                      tooltip: l10n.labRestart,
                      icon: const Icon(Icons.replay_rounded),
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.24),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _NowChip(
                    text: '${l10n.labNow} · ${_eventText(event, l10n)}',
                    color: eventColor,
                  ),
                ),
                const SizedBox(height: 12),
                _EventLegend(l10n: l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeedSelector extends StatelessWidget {
  const _SpeedSelector({required this.speed, required this.onChanged});

  final double speed;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    const speeds = [0.5, 1.0, 2.0];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final value in speeds)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: _SpeedButton(
              speed: value,
              selected: speed == value,
              onTap: () => onChanged(value),
            ),
          ),
      ],
    );
  }
}

class _SpeedButton extends StatelessWidget {
  const _SpeedButton({
    required this.speed,
    required this.selected,
    required this.onTap,
  });

  final double speed;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = speed == speed.roundToDouble()
        ? '${speed.toInt()}×'
        : '$speed×';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF071A24) : Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _NowChip extends StatelessWidget {
  const _NowChip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventLegend extends StatelessWidget {
  const _EventLegend({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 14,
        runSpacing: 8,
        children: [
          _LegendItem(color: Colors.white38, label: l10n.labRest),
          _LegendItem(color: const Color(0xFF4EA8FF), label: l10n.labLeftFist),
          _LegendItem(color: const Color(0xFFFFA24E), label: l10n.labRightFist),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _DecoderCard extends ConsumerWidget {
  const _DecoderCard({required this.recording, required this.event});

  final EegRecording recording;
  final EegEvent? event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final decoder = ref.watch(eegDecoderProvider);
    final predictions = ref.watch(eegPredictionsProvider);

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
                Icon(Icons.memory_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.labDecoderTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.labOnDeviceBadge,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              l10n.labDecoderBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            decoder.when(
              loading: () => _DecoderStatus(
                icon: const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                text: l10n.labDecoderLoading,
                theme: theme,
              ),
              error: (error, stackTrace) => _DecoderStatus(
                icon: Icon(
                  Icons.error_outline_rounded,
                  size: 18,
                  color: theme.colorScheme.error,
                ),
                text: l10n.labDecoderUnavailable,
                theme: theme,
              ),
              data: (decoder) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ModelSummary(decoder: decoder, theme: theme, l10n: l10n),
                  const SizedBox(height: 12),
                  _PredictionPanel(
                    recording: recording,
                    event: event,
                    predictions: predictions,
                    theme: theme,
                    l10n: l10n,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.labDecoderLimitations,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelSummary extends StatelessWidget {
  const _ModelSummary({
    required this.decoder,
    required this.theme,
    required this.l10n,
  });

  final EegDecoder decoder;
  final ThemeData theme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final training = decoder.model.training;
    // The accuracy value and its label must travel together: a model
    // with a held-out run wears the held-out label, while a model
    // without one falls back to leave-one-run-out — and must say so.
    final hasHeldOut = training.testRun.isNotEmpty;
    final accuracy = hasHeldOut
        ? training.heldOutAccuracy
        : training.leaveOneRunOutAccuracy;
    final percent = (accuracy * 100).round();
    // The held-out confusion matrix, documented in docs/model-card.md as
    // rows = actual, columns = predicted. Shown only for a model with a
    // held-out run and a complete 2x2 matrix: a leave-one-run-out
    // fallback has no held-out matrix to show, even if the JSON happens
    // to carry one.
    final confusion = training.heldOutConfusion;
    final hasConfusion = hasHeldOut &&
        confusion.length == 2 &&
        confusion.every((row) => row.length == 2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryLine(
            icon: Icons.tune_rounded,
            text: l10n.labDecoderModel(decoder.model.channels.length),
            theme: theme,
          ),
          const SizedBox(height: 6),
          _SummaryLine(
            icon: Icons.science_outlined,
            text: hasHeldOut
                ? l10n.labDecoderTraining(
                    training.trainRuns.join(' & '),
                    training.testRun,
                  )
                : l10n.labDecoderTrainingLoro(
                    training.trainRuns.join(' & '),
                  ),
            theme: theme,
          ),
          const SizedBox(height: 6),
          _SummaryLine(
            icon: Icons.verified_outlined,
            text: hasHeldOut
                ? l10n.labDecoderAccuracy(percent)
                : l10n.labDecoderAccuracyLoro(percent),
            theme: theme,
          ),
          if (hasConfusion) ...[
            const SizedBox(height: 8),
            Text(
              l10n.labDecoderConfusionTitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Table(
              children: [
                TableRow(
                  children: [
                    const SizedBox.shrink(),
                    _ConfusionCell(l10n.labLeftFist, theme: theme, center: true),
                    _ConfusionCell(l10n.labRightFist, theme: theme, center: true),
                  ],
                ),
                TableRow(
                  children: [
                    _ConfusionCell(l10n.labLeftFist, theme: theme),
                    _ConfusionCell('${confusion[0][0]}', theme: theme, center: true),
                    _ConfusionCell('${confusion[0][1]}', theme: theme, center: true),
                  ],
                ),
                TableRow(
                  children: [
                    _ConfusionCell(l10n.labRightFist, theme: theme),
                    _ConfusionCell('${confusion[1][0]}', theme: theme, center: true),
                    _ConfusionCell('${confusion[1][1]}', theme: theme, center: true),
                  ],
                ),
              ],
            ),
          ],
          // The model's own preprocessing and limitations text: parsed
          // for a while, never shown until now. Shown only when the
          // model actually provides them; the static italic caveat below
          // the card stays as the general disclaimer for all states.
          if (decoder.model.preprocessing.isNotEmpty) ...[
            const SizedBox(height: 6),
            _SummaryLine(
              icon: Icons.filter_alt_outlined,
              text:
                  '${l10n.labDecoderPreprocessingLabel}: '
                  '${decoder.model.preprocessing}',
              theme: theme,
            ),
          ],
          if (decoder.model.limitations.isNotEmpty) ...[
            const SizedBox(height: 6),
            _SummaryLine(
              icon: Icons.warning_amber_rounded,
              text:
                  '${l10n.labDecoderLimitationsLabel}: '
                  '${decoder.model.limitations}',
              theme: theme,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.icon,
    required this.text,
    required this.theme,
  });

  final IconData icon;
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfusionCell extends StatelessWidget {
  const _ConfusionCell(this.text, {required this.theme, this.center = false});

  final String text;
  final ThemeData theme;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.35,
        ),
      ),
    );
  }
}

class _PredictionPanel extends StatelessWidget {
  const _PredictionPanel({
    required this.recording,
    required this.event,
    required this.predictions,
    required this.theme,
    required this.l10n,
  });

  final EegRecording recording;
  final EegEvent? event;
  final AsyncValue<Map<double, EegPrediction>> predictions;
  final ThemeData theme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final current = event;
    if (current == null ||
        (current.kind != EegEventKind.leftFist &&
            current.kind != EegEventKind.rightFist)) {
      return _DecoderStatus(
        icon: Icon(
          Icons.pause_circle_outline_rounded,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        text: l10n.labDecoderIdle,
        theme: theme,
      );
    }

    if (current.end > recording.duration + 1e-6) {
      return _DecoderStatus(
        icon: Icon(
          Icons.hourglass_empty_rounded,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        text: l10n.labDecoderIncomplete,
        theme: theme,
      );
    }

    return predictions.when(
      loading: () => _DecoderStatus(
        icon: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        text: l10n.labDecoderDecoding,
        theme: theme,
      ),
      error: (error, stackTrace) => _DecoderStatus(
        icon: Icon(
          Icons.error_outline_rounded,
          size: 18,
          color: theme.colorScheme.error,
        ),
        text: l10n.labDecoderUnavailable,
        theme: theme,
      ),
      data: (byOnset) {
        final prediction = byOnset[current.onset];
        if (prediction == null) {
          return _DecoderStatus(
            icon: Icon(
              Icons.hourglass_empty_rounded,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            text: l10n.labDecoderIncomplete,
            theme: theme,
          );
        }
        return _PredictionResult(
          prediction: prediction,
          marker: current,
          theme: theme,
          l10n: l10n,
        );
      },
    );
  }
}

class _PredictionResult extends StatelessWidget {
  const _PredictionResult({
    required this.prediction,
    required this.marker,
    required this.theme,
    required this.l10n,
  });

  final EegPrediction prediction;
  final EegEvent marker;
  final ThemeData theme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final predictedLabel = prediction.isRight
        ? l10n.labRightFist
        : l10n.labLeftFist;
    final markerIsRight = marker.kind == EegEventKind.rightFist;
    final markerLabel = markerIsRight ? l10n.labRightFist : l10n.labLeftFist;
    final matches = prediction.isRight == markerIsRight;
    final confidence = (prediction.confidence * 100).round();
    final leftPercent = (prediction.leftProbability * 100).round();
    final rightPercent = (prediction.rightProbability * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.labDecoderPrediction,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$confidence%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            predictedLabel,
            key: const ValueKey('decoder-prediction-label'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          _ProbabilityBar(
            leftProbability: prediction.leftProbability,
            rightProbability: prediction.rightProbability,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${l10n.labLeftFist} $leftPercent%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${l10n.labRightFist} $rightPercent%',
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                matches
                    ? Icons.check_circle_outline_rounded
                    : Icons.info_outline_rounded,
                size: 16,
                color: matches
                    ? const Color(0xFF2E7D32)
                    : theme.colorScheme.tertiary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${l10n.labDecoderMarker}: $markerLabel',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProbabilityBar extends StatelessWidget {
  const _ProbabilityBar({
    required this.leftProbability,
    required this.rightProbability,
  });

  final double leftProbability;
  final double rightProbability;

  @override
  Widget build(BuildContext context) {
    final total = leftProbability + rightProbability;
    final leftFraction = total <= 0 ? 0.5 : leftProbability / total;
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                SizedBox(
                  width: constraints.maxWidth * leftFraction,
                  child: const ColoredBox(color: Color(0xFF4EA8FF)),
                ),
                const Expanded(child: ColoredBox(color: Color(0xFFFFA24E))),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DecoderStatus extends StatelessWidget {
  const _DecoderStatus({
    required this.icon,
    required this.text,
    required this.theme,
  });

  final Widget icon;
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatasetCard extends StatelessWidget {
  const _DatasetCard({
    required this.recording,
    required this.onOpenDataset,
    required this.onOpenLicense,
  });

  final EegRecording recording;
  final VoidCallback onOpenDataset;
  final VoidCallback onOpenLicense;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

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
                Icon(Icons.dataset_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.labDatasetTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _InfoRow(
              label: l10n.labSourceLabel,
              value: 'PhysioNet EEGMMIDB v1.0.0',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: l10n.labRecordingLabel,
              value: '${recording.subject} · ${recording.run}',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: l10n.labChannelsLabel,
              value: l10n.labChannelSummary(
                recording.channels.length,
                recording.samplingRate.round(),
              ),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: l10n.labLicenseLabel,
              value: 'ODC-BY 1.0',
              onTap: onOpenLicense,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.labRunDescription(recording.subject),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onOpenDataset,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(l10n.labOpenDataset),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueText = Text(
      value,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: onTap == null ? null : theme.colorScheme.primary,
        decoration: onTap == null ? null : TextDecoration.underline,
      ),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: onTap == null
              ? valueText
              : InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: valueText,
                  ),
                ),
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(l10n.labLoading),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 40),
            const SizedBox(height: 12),
            Text(l10n.labLoadError, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: onRetry, child: Text(l10n.labRetry)),
          ],
        ),
      ),
    );
  }
}

String _eventText(EegEvent? event, AppLocalizations l10n) {
  return switch (event?.kind) {
    EegEventKind.leftFist => l10n.labLeftFist,
    EegEventKind.rightFist => l10n.labRightFist,
    _ => l10n.labRest,
  };
}

Color _eventColor(EegEvent? event) {
  return switch (event?.kind) {
    EegEventKind.leftFist => const Color(0xFF4EA8FF),
    EegEventKind.rightFist => const Color(0xFFFFA24E),
    _ => Colors.white38,
  };
}

String _formatTime(double seconds) {
  final safe = seconds.clamp(0.0, double.infinity).toDouble();
  final minutes = safe ~/ 60;
  final remaining = safe % 60;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${remaining.toStringAsFixed(1).padLeft(4, '0')}';
}
