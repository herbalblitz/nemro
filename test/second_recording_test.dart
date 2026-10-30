import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nemro/features/lab/data/eeg_decoder.dart';
import 'package:nemro/features/lab/data/eeg_decoder_repository.dart';
import 'package:nemro/features/lab/data/eeg_recording.dart';
import 'package:nemro/features/lab/data/eeg_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'the second bundled sample has the expected shape and markers',
    () async {
      final csv = await rootBundle.loadString(eegSecondCsvAsset);
      final metadata = await rootBundle.loadString(eegSecondMetadataAsset);
      final recording = EegRecording.parse(csv: csv, metadataJson: metadata);

      expect(recording.subject, 'S002');
      expect(recording.run, contains('R04'));
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
      expect(recording.source, contains('PhysioNet'));
    },
  );

  test('the bundled decoder runs on the second recording', () async {
    final csv = await rootBundle.loadString(eegSecondCsvAsset);
    final metadata = await rootBundle.loadString(eegSecondMetadataAsset);
    final recording = EegRecording.parse(csv: csv, metadataJson: metadata);
    final modelSource = await rootBundle.loadString(eegDecoderModelAsset);
    final decoder = EegDecoder(EegDecoderModel.fromJson(modelSource));

    // The decoder was trained and held-out evaluated on S001 only, so
    // this checks that it runs on a different subject's windows without
    // crashing — not that it matches its S001 held-out accuracy.
    final predictions = decodeAllEvents(decoder, recording);
    expect(predictions, hasLength(7));
    for (final prediction in predictions.values) {
      expect(
        prediction.leftProbability + prediction.rightProbability,
        closeTo(1.0, 1e-6),
      );
    }
  });

  test('recording selector falls back to the original sample', () {
    expect(labRecordingById('s002r04').label, 'S002 · R04');
    expect(labRecordingById('unknown-id').id, 's001r04');
  });
}
