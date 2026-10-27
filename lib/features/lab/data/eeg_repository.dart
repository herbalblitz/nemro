import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nemro/features/lab/data/eeg_recording.dart';

const eegSampleCsvAsset = 'assets/eeg/s001_r04_60s.csv';
const eegSampleMetadataAsset = 'assets/eeg/s001_r04_60s.json';

/// Loads the bundled replay window from Flutter's asset bundle.
class EegRepository {
  const EegRepository({this.bundle});

  final AssetBundle? bundle;

  Future<EegRecording> loadSample() async {
    final assets = bundle ?? rootBundle;
    final results = await Future.wait([
      assets.loadString(eegSampleCsvAsset),
      assets.loadString(eegSampleMetadataAsset),
    ]);
    return EegRecording.parse(csv: results[0], metadataJson: results[1]);
  }
}

final eegRepositoryProvider = Provider<EegRepository>(
  (ref) => const EegRepository(),
);

final eegRecordingProvider = FutureProvider.autoDispose<EegRecording>(
  (ref) => ref.watch(eegRepositoryProvider).loadSample(),
);
