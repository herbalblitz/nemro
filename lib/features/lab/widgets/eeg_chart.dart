import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'package:nemro/features/lab/data/eeg_recording.dart';

/// A scrolling multi-channel EEG plot with task-marker bands and a playhead.
class EegChart extends StatelessWidget {
  const EegChart({
    super.key,
    required this.recording,
    required this.windowStart,
    required this.windowSeconds,
    required this.position,
  });

  final EegRecording recording;
  final double windowStart;
  final double windowSeconds;
  final double position;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _EegChartPainter(
        recording: recording,
        windowStart: windowStart,
        windowSeconds: windowSeconds,
        position: position,
      ),
      size: Size.infinite,
    );
  }
}

class _EegChartPainter extends CustomPainter {
  _EegChartPainter({
    required this.recording,
    required this.windowStart,
    required this.windowSeconds,
    required this.position,
  });

  final EegRecording recording;
  final double windowStart;
  final double windowSeconds;
  final double position;

  static const _lineColors = [
    Color(0xFF5FE1D2),
    Color(0xFF7ED6FF),
    Color(0xFFFFC66D),
    Color(0xFFB7A6FF),
    Color(0xFF7FE0A0),
    Color(0xFFFF9DB4),
    Color(0xFF9FD4FF),
    Color(0xFFE6E8FF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const plotLeft = 36.0;
    const plotTop = 26.0;
    const plotRightPadding = 10.0;
    const plotBottomPadding = 8.0;
    final plotRight = size.width - plotRightPadding;
    final plotBottom = size.height - plotBottomPadding;
    final plotWidth = plotRight - plotLeft;
    final plotHeight = plotBottom - plotTop;
    if (plotWidth <= 0 || plotHeight <= 0 || recording.channels.isEmpty) {
      return;
    }

    final windowEnd = windowStart + windowSeconds;
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1;

    // One-second vertical grid.
    for (var second = windowStart.ceil(); second <= windowEnd; second++) {
      final x = plotLeft + (second - windowStart) / windowSeconds * plotWidth;
      canvas.drawLine(Offset(x, plotTop), Offset(x, plotBottom), gridPaint);
    }

    // One horizontal line per channel.
    final rowHeight = plotHeight / recording.channels.length;
    for (var channel = 0; channel <= recording.channels.length; channel++) {
      final y = plotTop + channel * rowHeight;
      canvas.drawLine(Offset(plotLeft, y), Offset(plotRight, y), gridPaint);
    }

    // Task-marker bands.
    for (final event in recording.events) {
      if (event.kind == EegEventKind.rest) continue;
      final start = math.max(event.onset, windowStart);
      final end = math.min(event.end, windowEnd);
      if (end <= start) continue;

      final x = plotLeft + (start - windowStart) / windowSeconds * plotWidth;
      final width = (end - start) / windowSeconds * plotWidth;
      final color = switch (event.kind) {
        EegEventKind.leftFist => const Color(0xFF4EA8FF),
        EegEventKind.rightFist => const Color(0xFFFFA24E),
        _ => Colors.white,
      };
      canvas.drawRect(
        Rect.fromLTWH(x, plotTop, width, plotHeight),
        Paint()..color = color.withValues(alpha: 0.15),
      );

      if (width > 16) {
        _drawText(
          canvas,
          event.kind == EegEventKind.leftFist ? 'L' : 'R',
          Offset(x + 5, plotTop + 5),
          color: color.withValues(alpha: 0.9),
          fontSize: 9,
          fontWeight: FontWeight.w800,
        );
      }
    }

    // Waveforms.
    for (var channel = 0; channel < recording.channels.length; channel++) {
      final baseline = plotTop + rowHeight * (channel + 0.5);
      final amplitude = rowHeight * 0.38;
      final path = Path();
      var first = true;

      for (var x = plotLeft; x <= plotRight; x += 1) {
        final seconds =
            windowStart + (x - plotLeft) / plotWidth * windowSeconds;
        final index = (seconds * recording.samplingRate)
            .round()
            .clamp(0, recording.sampleCount - 1)
            .toInt();
        final value = recording.samples[channel][index];
        // 250 uV fills most of a row without clipping typical EEG.
        final normalized = (value / 250.0).clamp(-1.0, 1.0).toDouble();
        final y = baseline - normalized * amplitude;
        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(
        path,
        Paint()
          ..color = _lineColors[channel % _lineColors.length]
          ..strokeWidth = 1.1
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round,
      );

      _drawText(
        canvas,
        recording.channels[channel],
        Offset(plotLeft - 6, baseline),
        color: Colors.white.withValues(alpha: 0.65),
        fontSize: 9,
        alignRight: true,
        centerVertically: true,
      );
    }

    // Playhead.
    final playheadX =
        plotLeft + (position - windowStart) / windowSeconds * plotWidth;
    if (playheadX >= plotLeft && playheadX <= plotRight) {
      final playheadPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..strokeWidth = 1.4;
      canvas.drawLine(
        Offset(playheadX, plotTop),
        Offset(playheadX, plotBottom),
        playheadPaint,
      );
      final marker = Path()
        ..moveTo(playheadX - 4, plotTop)
        ..lineTo(playheadX + 4, plotTop)
        ..lineTo(playheadX, plotTop + 6)
        ..close();
      canvas.drawPath(marker, Paint()..color = Colors.white);
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    required Color color,
    required double fontSize,
    FontWeight fontWeight = FontWeight.w500,
    bool alignRight = false,
    bool centerVertically = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = alignRight ? offset.dx - painter.width : offset.dx;
    final dy = centerVertically ? offset.dy - painter.height / 2 : offset.dy;
    painter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant _EegChartPainter oldDelegate) {
    return oldDelegate.recording != recording ||
        oldDelegate.windowStart != windowStart ||
        oldDelegate.windowSeconds != windowSeconds ||
        oldDelegate.position != position;
  }
}
