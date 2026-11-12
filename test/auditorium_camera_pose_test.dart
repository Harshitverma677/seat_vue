import 'package:flutter_test/flutter_test.dart';
import 'package:seat_vue/data/mock_auditoriums.dart';
import 'package:seat_vue/features/seat_preview/models/auditorium_camera_state.dart';
import 'package:seat_vue/models/seat.dart';

void main() {
  group('Auditorium 3D Camera Pose Tests', () {
    test('Every generated seat resolves to a unique 3D position and camera pose', () {
      final seats = MockAuditoriums.generateAuditoriumSeats();
      expect(seats.length, equals(64));

      for (final seat in seats) {
        final pose = MockAuditoriums.getCameraPoseForSeat(seat);
        expect(pose.seatId, equals(seat.id));

        // Eye position must be seat base position + eye height offset
        expect(
          pose.cameraPosition.y,
          closeTo(seat.worldPosition.y + MockAuditoriums.eyeHeightOffset, 0.001),
        );

        // Lateral X must match seat X
        expect(pose.cameraPosition.x, equals(seat.worldPosition.x));

        // Depth Z must match seat Z
        expect(pose.cameraPosition.z, equals(seat.worldPosition.z));

        // Target must point toward screen center (0, 3.5, 0)
        expect(pose.lookAtTarget.x, equals(0.0));
        expect(pose.lookAtTarget.y, equals(3.5));
        expect(pose.lookAtTarget.z, equals(0.0));
      }
    });

    test('Front row A is closer to screen than back row H', () {
      final seats = MockAuditoriums.generateAuditoriumSeats();
      final seatA = seats.firstWhere((s) => s.id == 'A1');
      final seatH = seats.firstWhere((s) => s.id == 'H1');

      expect(seatA.worldPosition.z, lessThan(seatH.worldPosition.z));
      expect(seatA.worldPosition.y, lessThan(seatH.worldPosition.y)); // Tiered theater incline
    });

    test('Left seats have negative X and right seats have positive X', () {
      final seats = MockAuditoriums.generateAuditoriumSeats();
      final seatLeft = seats.firstWhere((s) => s.id == 'C1');
      final seatRight = seats.firstWhere((s) => s.id == 'C8');

      expect(seatLeft.worldPosition.x, lessThan(0.0));
      expect(seatRight.worldPosition.x, greaterThan(0.0));
    });

    test('AuditoriumCameraState.lerp correctly interpolates between overview and seat pose', () {
      final startState = AuditoriumCameraState(
        position: MockAuditoriums.overviewCameraPosition,
        target: MockAuditoriums.overviewLookAtTarget,
        fov: 65.0,
      );

      final seats = MockAuditoriums.generateAuditoriumSeats();
      final seatPose = MockAuditoriums.getCameraPoseForSeat(seats.firstWhere((s) => s.id == 'D4'));

      // t = 0.0 -> matches start
      final at0 = AuditoriumCameraState.lerp(startState, seatPose, 0.0);
      expect(at0.position.x, equals(startState.position.x));
      expect(at0.position.z, equals(startState.position.z));

      // t = 1.0 -> matches target
      final at1 = AuditoriumCameraState.lerp(startState, seatPose, 1.0);
      expect(at1.position.x, equals(seatPose.cameraPosition.x));
      expect(at1.position.z, equals(seatPose.cameraPosition.z));

      // t = 0.5 -> exact midpoint
      final atHalf = AuditoriumCameraState.lerp(startState, seatPose, 0.5);
      final expectedMidZ = (startState.position.z + seatPose.cameraPosition.z) * 0.5;
      expect(atHalf.position.z, closeTo(expectedMidZ, 0.001));
    });
  });
}
