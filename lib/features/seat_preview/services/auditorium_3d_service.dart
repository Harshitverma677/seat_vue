import 'package:flutter/material.dart';
import '../../../data/mock_auditoriums.dart';
import '../../../models/seat_camera_pose.dart';
import '../models/auditorium_camera_state.dart';

/// Service coordinating 3D camera animations, seat transitions, and look-around bounds.
class Auditorium3DService extends ChangeNotifier {
  late AuditoriumCameraState _currentState;
  SeatCameraPose? _currentPose;
  bool _isAnimating = false;

  // Maximum pan/tilt bounds in radians (~35 degrees)
  static const double maxYaw = 0.65;
  static const double maxPitch = 0.45;

  Auditorium3DService({SeatCameraPose? initialPose}) {
    final pose = initialPose ?? MockAuditoriums.overviewPose;
    _currentPose = pose;
    _currentState = AuditoriumCameraState(
      position: pose.cameraPosition,
      target: pose.lookAtTarget,
      fov: pose.fov,
    );
  }

  AuditoriumCameraState get currentState => _currentState;
  SeatCameraPose? get currentPose => _currentPose;
  bool get isAnimating => _isAnimating;

  /// Sets live interpolated state from external animation controllers.
  void setInterpolatedState(AuditoriumCameraState state) {
    _currentState = state;
    notifyListeners();
  }

  /// Mark animation start/end to prevent conflicting user interactions.
  void setAnimating(bool animating) {
    _isAnimating = animating;
    notifyListeners();
  }

  /// Directly jump or set the destination pose.
  void setTargetPose(SeatCameraPose pose) {
    _currentPose = pose;
    notifyListeners();
  }

  /// Apply user touch look-around gesture with bounds clamping.
  void applyLookAround(double deltaX, double deltaY) {
    if (_isAnimating) return;

    // Sensitivity factor
    const double sensitivity = 0.0035;

    final newYaw = (_currentState.yawOffset - deltaX * sensitivity).clamp(-maxYaw, maxYaw);
    final newPitch = (_currentState.pitchOffset - deltaY * sensitivity).clamp(-maxPitch, maxPitch);

    _currentState = _currentState.copyWith(
      yawOffset: newYaw,
      pitchOffset: newPitch,
    );
    notifyListeners();
  }

  /// Smoothly recenters look-around to default forward lookAt.
  void resetLookAround() {
    _currentState = _currentState.copyWith(
      yawOffset: 0.0,
      pitchOffset: 0.0,
    );
    notifyListeners();
  }
}
