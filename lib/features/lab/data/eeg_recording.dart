import 'dart:convert';

/// The kind of task marker attached to a moment in the recording.
enum EegEventKind { rest, leftFist, rightFist, other }

/// A labelled task window from the recording.
class EegEvent {
  const EegEvent({
    required this.onset,
    required this.duration,
    required this.label,
  });

  /// Seconds from the start of the recording.
  final double onset;

  /// Length of the task window in seconds.
  final double duration;

  /// Raw marker label from the dataset (`T0`, `T1`, `T2`).
  final String label;

  double get end => onset + duration;

  EegEventKind get kind => switch (label) {
    'T0' => EegEventKind.rest,
    'T1' => EegEventKind.leftFist,
    'T2' => EegEventKind.rightFist,
    _ => EegEventKind.other,
  };

  bool contains(double seconds) => seconds >= onset && seconds < end;
}

/// A short, bundled window of public EEG data plus its source metadata.
class EegRecording {
  const EegRecording({
    required this.source,
    required this.doi,
    required this.subject,
    required this.run,
    required this.license,
    required this.units,
    required this.samplingRate,
    required this.channels,
    required this.events,
    required this.samples,
    required this.duration,
  });

  final String source;
  final String doi;
  final String subject;
  final String run;
  final String license;
  final String units;
  final double samplingRate;
  final List<String> channels;
  final List<EegEvent> events;

  /// Channel-major samples. `samples[channel][index]`.
  final List<List<double>> samples;

  /// Duration of the bundled window in seconds.
  final double duration;

  int get sampleCount => samples.isEmpty ? 0 : samples.first.length;

  /// Parses the CSV and JSON assets bundled with the app.
  ///
  /// The CSV has a `time_s` column followed by one column per channel. The
  /// metadata JSON records the source, channel order, sampling rate, and task
  /// markers. Keeping them separate makes the raw signal easy to inspect.
  factory EegRecording.parse({
    required String csv,
    required String metadataJson,
  }) {
    final metadata = jsonDecode(metadataJson);
    if (metadata is! Map<String, dynamic>) {
      throw const FormatException('EEG metadata must be a JSON object.');
    }

    final metadataChannels = _readStringList(metadata['channels']);
    final samplingRate = _readDouble(metadata['sampling_rate_hz']);
    if (samplingRate <= 0) {
      throw const FormatException('EEG sampling rate must be positive.');
    }

    final lines = const LineSplitter().convert(csv);
    if (lines.isEmpty) {
      throw const FormatException('EEG CSV is empty.');
    }

    final header = lines.first.split(',');
    if (header.length < 2 || header.first.trim() != 'time_s') {
      throw const FormatException(
        'EEG CSV must start with a time_s column and at least one channel.',
      );
    }

    final channels = header.sublist(1).map((value) => value.trim()).toList();
    if (channels.any((channel) => channel.isEmpty)) {
      throw const FormatException('EEG CSV has an empty channel name.');
    }
    if (metadataChannels.isNotEmpty &&
        !_sameOrder(metadataChannels, channels)) {
      throw const FormatException(
        'EEG metadata channel order does not match the CSV header.',
      );
    }

    final samples = List<List<double>>.generate(
      channels.length,
      (_) => <double>[],
      growable: true,
    );

    double? lastTime;
    for (final line in lines.skip(1)) {
      if (line.trim().isEmpty) continue;
      final cells = line.split(',');
      if (cells.length != header.length) {
        throw FormatException(
          'EEG CSV row has ${cells.length} cells; expected ${header.length}.',
        );
      }

      final time = double.tryParse(cells.first.trim());
      if (time == null || time < 0) {
        throw const FormatException('EEG CSV has an invalid timestamp.');
      }
      if (lastTime != null && time <= lastTime) {
        throw const FormatException('EEG timestamps must increase.');
      }
      lastTime = time;

      for (var channel = 0; channel < channels.length; channel++) {
        final value = double.tryParse(cells[channel + 1].trim());
        if (value == null) {
          throw FormatException(
            'EEG CSV has an invalid value for ${channels[channel]}.',
          );
        }
        samples[channel].add(value);
      }
    }

    if (lastTime == null || samples.first.isEmpty) {
      throw const FormatException('EEG CSV has no samples.');
    }

    final events = <EegEvent>[];
    final rawEvents = metadata['events'];
    if (rawEvents is List) {
      for (final rawEvent in rawEvents) {
        if (rawEvent is! Map<String, dynamic>) {
          throw const FormatException('EEG event must be a JSON object.');
        }
        final onset = _readDouble(rawEvent['onset']);
        final duration = _readDouble(rawEvent['duration']);
        final label = rawEvent['label'];
        if (onset < 0 || duration <= 0 || label is! String || label.isEmpty) {
          throw const FormatException('EEG event has invalid fields.');
        }
        events.add(EegEvent(onset: onset, duration: duration, label: label));
      }
    }
    events.sort((a, b) => a.onset.compareTo(b.onset));

    final declaredDuration = metadata['duration_s'];
    final duration = declaredDuration is num
        ? declaredDuration.toDouble()
        : lastTime + 1 / samplingRate;
    if (duration <= 0) {
      throw const FormatException('EEG duration must be positive.');
    }
    if (declaredDuration is num) {
      final impliedDuration = lastTime + 1 / samplingRate;
      if ((declaredDuration.toDouble() - impliedDuration).abs() >
          1 / samplingRate) {
        throw const FormatException(
          'EEG declared duration does not match the samples.',
        );
      }
    }

    return EegRecording(
      source: _readString(metadata['source'], fallback: 'Unknown dataset'),
      doi: _readString(metadata['doi']),
      subject: _readString(metadata['subject']),
      run: _readString(metadata['run']),
      license: _readString(metadata['license'], fallback: 'Unknown license'),
      units: _readString(metadata['units'], fallback: 'uV'),
      samplingRate: samplingRate,
      channels: channels,
      events: events,
      samples: samples,
      duration: duration,
    );
  }

  /// Returns the task marker covering [seconds], if any.
  EegEvent? eventAt(double seconds) {
    for (final event in events) {
      if (event.contains(seconds)) return event;
    }
    return null;
  }
}

bool _sameOrder(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

List<String> _readStringList(Object? value) {
  if (value is! List) return const [];
  return value.map((item) => item.toString()).toList();
}

String _readString(Object? value, {String fallback = ''}) {
  return value is String && value.isNotEmpty ? value : fallback;
}

double _readDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) return parsed;
  }
  throw const FormatException('EEG metadata has an invalid number.');
}
