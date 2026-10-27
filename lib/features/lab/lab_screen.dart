import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nemro/core/constants/app_constants.dart';
import 'package:nemro/core/l10n/generated/app_localizations.dart';
import 'package:nemro/core/theme/app_theme.dart';
import 'package:nemro/features/lab/data/eeg_recording.dart';
import 'package:nemro/features/lab/data/eeg_repository.dart';
import 'package:nemro/features/lab/widgets/eeg_chart.dart';

class LabScreen extends ConsumerWidget {
  const LabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.labTitle)),
      body: ref
          .watch(eegRecordingProvider)
          .when(
            loading: () => const _LoadingState(),
            error: (error, stackTrace) => _ErrorState(
              onRetry: () => ref.invalidate(eegRecordingProvider),
            ),
            data: (recording) => _LabContent(recording: recording),
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

class _LabContentState extends State<_LabContent> {
  static const _windowSeconds = 10.0;
  static const _tick = Duration(milliseconds: 50);

  Timer? _timer;
  double _position = 0;
  double _speed = 1;
  bool _playing = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
        const _DecoderCard(),
        const SizedBox(height: 16),
        _DatasetCard(recording: recording, onOpenDataset: _openDataset),
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

class _DecoderCard extends StatelessWidget {
  const _DecoderCard();

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
                    l10n.labNextBadge,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
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
            const SizedBox(height: 10),
            Text(
              l10n.labDisclaimer,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatasetCard extends StatelessWidget {
  const _DatasetCard({required this.recording, required this.onOpenDataset});

  final EegRecording recording;
  final VoidCallback onOpenDataset;

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
              value: '${recording.subject} · R04',
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
            _InfoRow(label: l10n.labLicenseLabel, value: 'ODC-BY 1.0'),
            const SizedBox(height: 12),
            Text(
              l10n.labRunDescription,
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
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
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
