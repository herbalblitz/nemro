import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:nemro/features/live/data/attention_analyzer.dart';
import 'package:nemro/features/live/data/camera_frame_converter.dart';

LumaFrame _checkerboard({int size = 16, bool invert = false}) {
  final pixels = Float32List(size * size);
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final bright = (x + y).isEven;
      pixels[y * size + x] = (bright != invert) ? 0.85 : 0.15;
    }
  }
  return LumaFrame(width: size, height: size, pixels: pixels);
}

LumaFrame _blank(double value, {int size = 16}) {
  return LumaFrame(
    width: size,
    height: size,
    pixels: Float32List.fromList(List<double>.filled(size * size, value)),
  );
}

void main() {
  group('LumaFrame conversion', () {
    test('downsamples a Y plane and normalizes luminance', () {
      final frame = lumaFrameFromYPlane(
        bytes: Uint8List.fromList([0, 51, 102, 153, 204, 255, 255, 255]),
        width: 2,
        height: 2,
        bytesPerRow: 4,
        targetMaxDimension: 2,
      );

      expect(frame, isNotNull);
      expect(frame!.width, 2);
      expect(frame.height, 2);
      expect(frame.pixels[0], closeTo(0.0, 0.001));
      expect(frame.pixels[1], closeTo(51 / 255, 0.001));
      expect(frame.pixels[2], closeTo(204 / 255, 0.001));
      expect(frame.pixels[3], closeTo(1.0, 0.001));
    });

    test('Y plane rejects a row stride smaller than the width', () {
      final frame = lumaFrameFromYPlane(
        bytes: Uint8List.fromList(List<int>.filled(8, 128)),
        width: 4,
        height: 2,
        bytesPerRow: 3,
      );
      expect(frame, isNull);
    });

    test('BGRA conversion uses standard luminance weights', () {
      LumaFrame? convert(List<int> bytes) {
        return lumaFrameFromBgra(
          bytes: Uint8List.fromList(bytes),
          width: 1,
          height: 1,
          bytesPerRow: 4,
          targetMaxDimension: 1,
        );
      }

      expect(convert([0, 0, 0, 255])!.pixels[0], closeTo(0.0, 0.001));
      expect(convert([255, 255, 255, 255])!.pixels[0], closeTo(1.0, 0.001));
      expect(convert([0, 0, 255, 255])!.pixels[0], closeTo(0.299, 0.001));
      expect(convert([0, 255, 0, 255])!.pixels[0], closeTo(0.587, 0.001));
      expect(convert([255, 0, 0, 255])!.pixels[0], closeTo(0.114, 0.001));
    });
  });

  group('AttentionAnalyzer', () {
    test('a blank wall stays near zero even when it is stable', () {
      final analyzer = AttentionAnalyzer();
      late AttentionSample sample;
      for (var i = 0; i < 5; i++) {
        sample = analyzer.addFrame(_blank(0.5));
      }

      expect(sample.roundedScore, lessThan(5));
      expect(sample.presence, 0);
      expect(sample.stability, 1);
    });

    test('a textured, stable frame produces a high proxy score', () {
      final analyzer = AttentionAnalyzer();
      late AttentionSample sample;
      for (var i = 0; i < 4; i++) {
        sample = analyzer.addFrame(_checkerboard());
      }

      expect(sample.roundedScore, greaterThan(90));
      expect(sample.isWarmingUp, isFalse);
      expect(sample.presence, 1);
    });

    test('motion lowers the score relative to a stable frame', () {
      final stableAnalyzer = AttentionAnalyzer();
      final movingAnalyzer = AttentionAnalyzer();
      late AttentionSample stable;
      late AttentionSample moving;

      for (var i = 0; i < 12; i++) {
        stable = stableAnalyzer.addFrame(_checkerboard());
        moving = movingAnalyzer.addFrame(_checkerboard(invert: i.isOdd));
      }

      expect(stable.roundedScore, greaterThan(90));
      expect(moving.roundedScore, lessThan(stable.roundedScore - 30));
      expect(moving.stability, lessThan(0.1));
    });

    test('warmup covers the first three frames', () {
      final analyzer = AttentionAnalyzer();
      final first = analyzer.addFrame(_checkerboard());
      final second = analyzer.addFrame(_checkerboard());
      final third = analyzer.addFrame(_checkerboard());

      expect(first.isWarmingUp, isTrue);
      expect(second.isWarmingUp, isTrue);
      expect(third.isWarmingUp, isFalse);
    });

    test('reset clears the frame count and previous frame', () {
      final analyzer = AttentionAnalyzer();
      analyzer.addFrame(_checkerboard());
      analyzer.addFrame(_checkerboard());
      analyzer.reset();

      final sample = analyzer.addFrame(_blank(0.5));
      expect(sample.frames, 1);
      expect(sample.motion, 0);
    });

    test('scores stay inside the documented range', () {
      final analyzer = AttentionAnalyzer();
      for (var i = 0; i < 20; i++) {
        final sample = analyzer.addFrame(_checkerboard(invert: i.isOdd));
        expect(sample.score, inInclusiveRange(0, 100));
      }
    });
  });
}
