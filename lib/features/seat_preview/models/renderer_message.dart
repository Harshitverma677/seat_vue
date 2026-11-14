import 'dart:convert';
import '../../../models/seat.dart';

/// Typed message payload sent between Flutter and the 3D WebGL renderer.
sealed class RendererMessage {
  final String type;
  const RendererMessage(this.type);

  Map<String, dynamic> toJson();
  String serialize() => jsonEncode(toJson());
}

/// Command to move camera to a specific seat/pose.
class SetCameraPoseCommand extends RendererMessage {
  final Position3D cameraPosition;
  final Position3D lookAtTarget;
  final double fov;
  final int durationMs;

  const SetCameraPoseCommand({
    required this.cameraPosition,
    required this.lookAtTarget,
    this.fov = 60.0,
    this.durationMs = 500,
  }) : super('setCameraPose');

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'cameraPosition': cameraPosition.toJson(),
        'lookAtTarget': lookAtTarget.toJson(),
        'fov': fov,
        'durationMs': durationMs,
      };
}

/// Command to reset look-around pan/tilt to center forward.
class RecenterCameraCommand extends RendererMessage {
  final int durationMs;

  const RecenterCameraCommand({this.durationMs = 280}) : super('recenterCamera');

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'durationMs': durationMs,
      };
}

/// Command to pass touch drag deltas for look-around.
class SetLookInputCommand extends RendererMessage {
  final double deltaX;
  final double deltaY;

  const SetLookInputCommand({
    required this.deltaX,
    required this.deltaY,
  }) : super('setLookInput');

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'deltaX': deltaX,
        'deltaY': deltaY,
      };
}

/// Notification sent from 3D renderer back to Flutter.
class RendererEvent {
  final String type;
  final Map<String, dynamic> data;

  const RendererEvent({
    required this.type,
    this.data = const {},
  });

  factory RendererEvent.fromJson(Map<String, dynamic> json) {
    return RendererEvent(
      type: json['type'] as String? ?? 'unknown',
      data: json,
    );
  }

  factory RendererEvent.parse(String message) {
    try {
      final decoded = jsonDecode(message) as Map<String, dynamic>;
      return RendererEvent.fromJson(decoded);
    } catch (_) {
      return RendererEvent(type: 'raw', data: {'message': message});
    }
  }

  bool get isSceneReady => type == 'sceneReady';
  bool get isTransitionCompleted => type == 'cameraTransitionCompleted';
  bool get isError => type == 'sceneError';
}
