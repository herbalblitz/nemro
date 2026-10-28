import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nemro/features/live/data/attention_analyzer.dart';
import 'package:nemro/features/live/data/camera_frame_converter.dart';

enum LiveCameraFailure {
  permissionDenied,
  permissionPermanentlyDenied,
  restricted,
  noCamera,
  unavailable,
}

class LiveCameraException implements Exception {
  const LiveCameraException(this.failure, [this.details]);

  final LiveCameraFailure failure;
  final String? details;

  @override
  String toString() {
    final suffix = details == null ? '' : ': $details';
    return 'LiveCameraException($failure$suffix)';
  }
}

abstract interface class LiveCameraSession {
  Widget buildPreview();

  double get aspectRatio;

  Stream<LumaFrame> get frames;

  Future<void> dispose();
}

abstract interface class LiveCameraGateway {
  Future<LiveCameraSession> start({
    CameraLensDirection lensDirection = CameraLensDirection.front,
  });
}

final liveCameraGatewayProvider = Provider<LiveCameraGateway>(
  (ref) => const DeviceLiveCameraGateway(),
);

class DeviceLiveCameraGateway implements LiveCameraGateway {
  const DeviceLiveCameraGateway();

  @override
  Future<LiveCameraSession> start({
    CameraLensDirection lensDirection = CameraLensDirection.front,
  }) async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw const LiveCameraException(LiveCameraFailure.noCamera);
      }

      final description = cameras.firstWhere(
        (camera) => camera.lensDirection == lensDirection,
        orElse: () => cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        ),
      );
      final controller = CameraController(
        description,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      try {
        await controller.initialize();
      } on CameraException catch (error) {
        await controller.dispose();
        throw _mapCameraException(error);
      } catch (_) {
        await controller.dispose();
        rethrow;
      }

      final session = _DeviceLiveCameraSession(controller);
      try {
        await session.start();
      } catch (error) {
        await session.dispose();
        if (error is CameraException) {
          throw _mapCameraException(error);
        }
        rethrow;
      }
      return session;
    } on CameraException catch (error) {
      throw _mapCameraException(error);
    }
  }
}

class _DeviceLiveCameraSession implements LiveCameraSession {
  _DeviceLiveCameraSession(this._controller);

  final CameraController _controller;
  final StreamController<LumaFrame> _frames =
      StreamController<LumaFrame>.broadcast();
  bool _disposed = false;

  Future<void> start() async {
    await _controller.startImageStream(_onImage);
  }

  void _onImage(CameraImage image) {
    if (_disposed) return;
    final frame = lumaFrameFromCameraImage(image);
    if (frame != null && !_frames.isClosed) {
      _frames.add(frame);
    }
  }

  @override
  Widget buildPreview() => CameraPreview(_controller);

  @override
  double get aspectRatio {
    final size = _controller.value.previewSize;
    if (size == null || size.width <= 0 || size.height <= 0) {
      return 4 / 3;
    }
    return size.width / size.height;
  }

  @override
  Stream<LumaFrame> get frames => _frames.stream;

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    try {
      if (_controller.value.isStreamingImages) {
        await _controller.stopImageStream();
      }
    } catch (_) {
      // The camera may already be stopped or gone; disposal still proceeds.
    }

    try {
      await _controller.dispose();
    } catch (_) {
      // A failed camera teardown must not break the screen.
    }

    await _frames.close();
  }
}

LiveCameraException _mapCameraException(CameraException error) {
  final failure = switch (error.code) {
    'CameraAccessDenied' => LiveCameraFailure.permissionDenied,
    'CameraAccessDeniedWithoutPrompt' =>
      LiveCameraFailure.permissionPermanentlyDenied,
    'CameraAccessRestricted' => LiveCameraFailure.restricted,
    'cameraNotFound' || 'CameraNotFound' => LiveCameraFailure.noCamera,
    _ => LiveCameraFailure.unavailable,
  };
  return LiveCameraException(failure, error.description);
}
