import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nemro/features/lab/data/eeg_recording.dart';

const eegSampleCsvAsset = 'assets/eeg/s001_r04_60s.csv';
const eegSampleMetadataAsset = 'assets/eeg/s001_r04_60s.json';
const eegSecondCsvAsset = 'assets/eeg/s002_r04_60s.csv';
const eegSecondMetadataAsset = 'assets/eeg/s002_r04_60s.json';

/// One bundled Lab recording: a CSV + JSON metadata pair from the same
/// PhysioNet EEGMMIDB dataset, redistributed under ODC-BY 1.0.
class LabRecordingRef {
  const LabRecordingRef({
    required this.id,
    required this.label,
    required this.csvAsset,
    required this.metadataAsset,
  });

  final String id;

  /// Short label shown in the recording selector, e.g. "S001 · R04".
  final String label;
  final String csvAsset;
  final String metadataAsset;
}

const labRecordings = [
  LabRecordingRef(
    id: 's001r04',
    label: 'S001 · R04',
    csvAsset: eegSampleCsvAsset,
    metadataAsset: eegSampleMetadataAsset,
  ),
  LabRecordingRef(
    id: 's002r04',
    label: 'S002 · R04',
    csvAsset: eegSecondCsvAsset,
    metadataAsset: eegSecondMetadataAsset,
  ),
];

LabRecordingRef labRecordingById(String id) {
  return labRecordings.firstWhere(
    (recording) => recording.id == id,
    orElse: () => labRecordings.first,
  );
}

/// The recording Lab currently shows. Defaults to the original S001
/// sample; an unknown stored id falls back to it via [labRecordingById].
final selectedLabRecordingProvider =
    NotifierProvider<SelectedLabRecordingController, String>(
      SelectedLabRecordingController.new,
    );

class SelectedLabRecordingController extends Notifier<String> {
  @override
  String build() => labRecordings.first.id;

  void select(String id) {
    state = labRecordingById(id).id;
  }
}

/// Loads a bundled replay window from Flutter's asset bundle.
class EegRepository {
  const EegRepository({this.bundle});

  final AssetBundle? bundle;

  Future<EegRecording> loadRecording(LabRecordingRef ref) async {
    final assets = bundle ?? rootBundle;
    final results = await Future.wait([
      assets.loadString(ref.csvAsset),
      assets.loadString(ref.metadataAsset),
    ]);
    return EegRecording.parse(csv: results[0], metadataJson: results[1]);
  }
}

final eegRepositoryProvider = Provider<EegRepository>(
  (ref) => const EegRepository(),
);

final eegRecordingProvider = FutureProvider.autoDispose<EegRecording>(
  (ref) => ref
      .watch(eegRepositoryProvider)
      .loadRecording(labRecordingById(ref.watch(selectedLabRecordingProvider))),
);
