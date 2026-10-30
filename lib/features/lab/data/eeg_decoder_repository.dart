import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nemro/features/lab/data/eeg_decoder.dart';
import 'package:nemro/features/lab/data/eeg_recording.dart';
import 'package:nemro/features/lab/data/eeg_repository.dart';

const eegDecoderModelAsset = 'assets/models/eeg_decoder.json';

class EegDecoderRepository {
  const EegDecoderRepository({this.bundle});

  final AssetBundle? bundle;

  Future<EegDecoder> load() async {
    final assets = bundle ?? rootBundle;
    final source = await assets.loadString(eegDecoderModelAsset);
    return EegDecoder(EegDecoderModel.fromJson(source));
  }
}

final eegDecoderRepositoryProvider = Provider<EegDecoderRepository>(
  (ref) => const EegDecoderRepository(),
);

final eegDecoderProvider = FutureProvider.autoDispose<EegDecoder>(
  (ref) => ref.watch(eegDecoderRepositoryProvider).load(),
);

/// Predictions for every complete left/right task window in the recording.
///
/// They are computed once when the model and recording are available, so the
/// playback timer never runs feature extraction on the UI thread.
final eegPredictionsProvider =
    FutureProvider.autoDispose<Map<double, EegPrediction>>((ref) async {
      final decoder = await ref.watch(eegDecoderProvider.future);
      final recording = await ref.watch(eegRecordingProvider.future);
      return decodeAllEvents(decoder, recording);
    });

/// Decodes every complete task window, skipping windows that fail to decode
/// instead of failing the whole batch: one bad window (for example a model
/// window that runs past the end of the recording, or a recording missing a
/// model channel) must not hide every other prediction. The Lab panel
/// already shows an "incomplete" state for events without a prediction.
Map<double, EegPrediction> decodeAllEvents(
  EegDecoder decoder,
  EegRecording recording,
) {
  final predictions = <double, EegPrediction>{};
  for (final event in recording.events) {
    if (event.kind != EegEventKind.leftFist &&
        event.kind != EegEventKind.rightFist) {
      continue;
    }
    if (event.end > recording.duration + 1e-6) {
      continue;
    }
    try {
      predictions[event.onset] = decoder.decode(recording, event);
    } catch (error) {
      // Skip this window; the other predictions still stand.
      debugPrint('Skipping undecodable EEG window at ${event.onset}s: $error');
    }
  }
  return predictions;
}
