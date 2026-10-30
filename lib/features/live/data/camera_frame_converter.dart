import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';

import 'package:nemro/features/live/data/camera_proxy_analyzer.dart';

/// Converts a camera image to a small, normalized luminance frame.
///
/// Android uses YUV420/NV21 and iOS uses BGRA. Unsupported formats return null
/// so the Live screen can keep waiting instead of crashing on a frame.
LumaFrame? lumaFrameFromCameraImage(
  CameraImage image, {
  int targetMaxDimension = 48,
}) {
  if (image.width <= 0 || image.height <= 0 || image.planes.isEmpty) {
    return null;
  }

  final plane = image.planes.first;
  switch (image.format.group) {
    case ImageFormatGroup.bgra8888:
      if (image.planes.length != 1) return null;
      return lumaFrameFromBgra(
        bytes: plane.bytes,
        width: image.width,
        height: image.height,
        bytesPerRow: plane.bytesPerRow,
        bytesPerPixel: plane.bytesPerPixel ?? 4,
        targetMaxDimension: targetMaxDimension,
      );
    case ImageFormatGroup.yuv420:
    case ImageFormatGroup.nv21:
    case ImageFormatGroup.unknown:
      return lumaFrameFromYPlane(
        bytes: plane.bytes,
        width: image.width,
        height: image.height,
        bytesPerRow: plane.bytesPerRow,
        targetMaxDimension: targetMaxDimension,
      );
    case ImageFormatGroup.jpeg:
      return null;
  }
}

/// Converts a Y-plane buffer (YUV420 or NV21) to a luminance frame.
LumaFrame? lumaFrameFromYPlane({
  required Uint8List bytes,
  required int width,
  required int height,
  required int bytesPerRow,
  int targetMaxDimension = 48,
}) {
  if (width <= 0 ||
      height <= 0 ||
      bytesPerRow < width ||
      bytes.length < bytesPerRow * height) {
    return null;
  }

  final size = _outputSize(width, height, targetMaxDimension);
  final pixels = Float32List(size.width * size.height);
  for (var y = 0; y < size.height; y++) {
    final sourceY = _sourceIndex(y, size.height, height);
    final sourceRow = sourceY * bytesPerRow;
    final outputRow = y * size.width;
    for (var x = 0; x < size.width; x++) {
      final sourceX = _sourceIndex(x, size.width, width);
      pixels[outputRow + x] = bytes[sourceRow + sourceX] / 255.0;
    }
  }

  return LumaFrame(width: size.width, height: size.height, pixels: pixels);
}

/// Converts a BGRA buffer to a luminance frame.
LumaFrame? lumaFrameFromBgra({
  required Uint8List bytes,
  required int width,
  required int height,
  required int bytesPerRow,
  int bytesPerPixel = 4,
  int targetMaxDimension = 48,
}) {
  if (width <= 0 ||
      height <= 0 ||
      bytesPerPixel < 3 ||
      bytesPerRow < width * bytesPerPixel ||
      bytes.length < bytesPerRow * height) {
    return null;
  }

  final size = _outputSize(width, height, targetMaxDimension);
  final pixels = Float32List(size.width * size.height);
  for (var y = 0; y < size.height; y++) {
    final sourceY = _sourceIndex(y, size.height, height);
    final sourceRow = sourceY * bytesPerRow;
    final outputRow = y * size.width;
    for (var x = 0; x < size.width; x++) {
      final sourceX = _sourceIndex(x, size.width, width);
      final index = sourceRow + sourceX * bytesPerPixel;
      final blue = bytes[index];
      final green = bytes[index + 1];
      final red = bytes[index + 2];
      final luma = (0.114 * blue + 0.587 * green + 0.299 * red) / 255.0;
      pixels[outputRow + x] = luma;
    }
  }

  return LumaFrame(width: size.width, height: size.height, pixels: pixels);
}

({int width, int height}) _outputSize(
  int width,
  int height,
  int targetMaxDimension,
) {
  final target = math.max(1, targetMaxDimension);
  final scale = math.min(1.0, target / math.max(width, height));
  return (
    width: math.max(1, (width * scale).round()),
    height: math.max(1, (height * scale).round()),
  );
}

int _sourceIndex(int outputIndex, int outputLength, int sourceLength) {
  return ((outputIndex + 0.5) * sourceLength / outputLength)
      .floor()
      .clamp(0, sourceLength - 1)
      .toInt();
}
