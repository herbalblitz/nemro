import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nemro/features/lab/data/eeg_recording.dart';
import 'package:nemro/features/lab/data/eeg_repository.dart';

const _csv = '''
time_s,C3,Cz
0.0000,1,2
0.00625,3,4
0.0125,5,6
''';

String _metadata({
  List<String> channels = const ['C3', 'Cz'],
  List<Map<String, Object>> events = const [
    {'onset': 0.0, 'duration': 0.00625, 'label': 'T0'},
    {'onset': 0.00625, 'duration': 0.00625, 'label': 'T1'},
  ],
}) {
  return jsonEncode({
    'source': 'Test dataset',
    'doi': '10.0000/test',
    'subject': 'S001',
    'run': 'R04',
    'license': 'ODC-BY 1.0',
    'units': 'uV',
    'sampling_rate_hz': 160,
    'channels': channels,
    'events': events,
    'duration_s': 0.01875,
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parses channels, samples, and task markers', () {
    final recording = EegRecording.parse(csv: _csv, metadataJson: _metadata());

    expect(recording.channels, ['C3', 'Cz']);
    expect(recording.sampleCount, 3);
    expect(recording.duration, 0.01875);
    expect(recording.samples[0], [1, 3, 5]);
    expect(recording.samples[1], [2, 4, 6]);
    expect(recording.eventAt(0.0)?.kind, EegEventKind.rest);
    expect(recording.eventAt(0.00625)?.kind, EegEventKind.leftFist);
    expect(recording.eventAt(0.02), isNull);
  });

  test('rejects a malformed row', () {
    expect(
      () => EegRecording.parse(
        csv: 'time_s,C3\n0.0,1\n0.00625\n',
        metadataJson: _metadata(channels: const ['C3']),
      ),
      throwsFormatException,
    );
  });

  test('rejects a declared duration that does not match the samples', () {
    final mismatched = jsonDecode(_metadata()) as Map<String, dynamic>;
    mismatched['duration_s'] = 0.05;
    expect(
      () => EegRecording.parse(csv: _csv, metadataJson: jsonEncode(mismatched)),
      throwsFormatException,
    );
  });

  test('rejects metadata that does not match the CSV channels', () {
    expect(
      () => EegRecording.parse(
        csv: _csv,
        metadataJson: _metadata(channels: const ['Cz', 'C3']),
      ),
      throwsFormatException,
    );
  });

  test('rejects timestamps that do not increase', () {
    expect(
      () => EegRecording.parse(
        csv: 'time_s,C3\n0.0,1\n0.0,2\n',
        metadataJson: _metadata(channels: const ['C3']),
      ),
      throwsFormatException,
    );
  });

  test('rejects non-finite sample values and timestamps', () {
    // double.tryParse accepts 'NaN', and a NaN sample would poison the
    // decoder (NaN probability, then a crash rounding it for display),
    // so non-finite values must fail at the parse boundary.
    expect(
      () => EegRecording.parse(
        csv: 'time_s,C3,Cz\n0.0000,NaN,2\n0.00625,3,4\n0.0125,5,6\n',
        metadataJson: _metadata(),
      ),
      throwsFormatException,
    );
    expect(
      () => EegRecording.parse(
        csv: 'time_s,C3,Cz\nNaN,1,2\n0.00625,3,4\n0.0125,5,6\n',
        metadataJson: _metadata(),
      ),
      throwsFormatException,
    );
  });

  test('rejects a non-finite metadata number', () {
    final mutated = jsonDecode(_metadata()) as Map<String, dynamic>;
    mutated['sampling_rate_hz'] = 'NaN';
    expect(
      () => EegRecording.parse(csv: _csv, metadataJson: jsonEncode(mutated)),
      throwsFormatException,
    );
  });

  test('the bundled sample has the expected shape and markers', () async {
    final csv = await rootBundle.loadString(eegSampleCsvAsset);
    final metadata = await rootBundle.loadString(eegSampleMetadataAsset);
    final recording = EegRecording.parse(csv: csv, metadataJson: metadata);

    expect(recording.channels, hasLength(8));
    expect(recording.sampleCount, 9600);
    expect(recording.duration, 60);
    expect(recording.events, hasLength(15));
    expect(
      recording.events.where((event) => event.kind == EegEventKind.leftFist),
      hasLength(3),
    );
    expect(
      recording.events.where((event) => event.kind == EegEventKind.rightFist),
      hasLength(4),
    );
    expect(recording.eventAt(4.2)?.kind, EegEventKind.rightFist);
    expect(recording.eventAt(12.5)?.kind, EegEventKind.leftFist);
    expect(recording.source, contains('PhysioNet'));
  });
}
