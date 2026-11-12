import 'dart:math' as math;
import '../../../models/seat.dart';
import '../../../models/seat_camera_pose.dart';

/// Live state of the 3D camera in the auditorium.
class AuditoriumCameraState {
  final Position3D position;
  final Position3D target;
  final double fov;
  final double yawOffset; // Pan offset in radians (-pi/4 to +pi/4)
  final double pitchOffset; // Tilt offset in radians (-pi/6 to +pi/6)

  const AuditoriumCameraState({
    required this.position,
    required this.target,
    this.fov = 60.0,
    this.yawOffset = 0.0,
    this.pitchOffset = 0.0,
  });

  AuditoriumCameraState copyWith({
    Position3D? position,
    Position3D? target,
    double? fov,
    double? yawOffset,
    double? pitchOffset,
  }) {
    return AuditoriumCameraState(
      position: position ?? this.position,
      target: target ?? this.target,
      fov: fov ?? this.fov,
      yawOffset: yawOffset ?? this.yawOffset,
      pitchOffset: pitchOffset ?? this.pitchOffset,
    );
  }

  /// Linearly interpolate between two camera poses.
  static AuditoriumCameraState lerp(
    AuditoriumCameraState a,
    SeatCameraPose targetPose,
    double t,
  ) {
    final curPos = a.position;
    final tgtPos = targetPose.cameraPosition;

    final curTarget = a.target;
    final tgtTarget = targetPose.lookAtTarget;

    return AuditoriumCameraState(
      position: Position3D(
        curPos.x + (tgtPos.x - curPos.x) * t,
        curPos.y + (tgtPos.y - curPos.y) * t,
        curPos.z + (tgtPos.z - curPos.z) * t,
      ),
      target: Position3D(
        curTarget.x + (tgtTarget.x - curTarget.x) * t,
        curTarget.y + (tgtTarget.y - curTarget.y) * t,
        curTarget.z + (tgtTarget.z - curTarget.z) * t,
      ),
      fov: a.fov + (targetPose.fov - a.fov) * t,
      // Interpolate offsets back to 0 on pose change
      yawOffset: a.yawOffset * (1.0 - t),
      pitchOffset: a.pitchOffset * (1.0 - t),
    );
  }

  /// Effective look target combining lookAtTarget and user look-around offsets.
  Position3D get effectiveLookTarget {
    // Vector from camera to target
    final dx = target.x - position.x;
    final dy = target.y - position.y;
    final dz = target.z - position.z;
    final dist = math.sqrt(dx * dx + dy * dy + dz * dz);

    // Baseline angles
    final baseYaw = math.atan2(dx, -dz);
    final basePitch = math.asin((dy / (dist > 0.001 ? dist : 1.0)).clamp(-1.0, 1.0));

    final totalYaw = baseYaw + yawOffset;
    final totalPitch = (basePitch + pitchOffset).clamp(-1.1, 1.1);

    final effX = position.x + dist * math.sin(totalYaw) * math.cos(totalPitch);
    final effY = position.y + dist * math.sin(totalPitch);
    final effZ = position.z - dist * math.cos(totalYaw) * math.cos(totalPitch);

    return Position3D(effX, effY, effZ);
  }
}

