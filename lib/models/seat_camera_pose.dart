import 'seat.dart';

/// Camera pose definition associated with viewing from an exact seat.
class SeatCameraPose {
  final String seatId;
  final Position3D cameraPosition;
  final Position3D lookAtTarget;
  final double fov;

  const SeatCameraPose({
    required this.seatId,
    required this.cameraPosition,
    required this.lookAtTarget,
    this.fov = 60.0,
  });

  Map<String, dynamic> toJson() => {
        'seatId': seatId,
        'cameraPosition': cameraPosition.toJson(),
        'lookAtTarget': lookAtTarget.toJson(),
        'fov': fov,
      };

  @override
  String toString() =>
      'SeatCameraPose(seatId: $seatId, eye: $cameraPosition, target: $lookAtTarget, fov: $fov)';
}

