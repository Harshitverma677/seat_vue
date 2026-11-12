import '../models/seat.dart';
import '../models/seat_camera_pose.dart';

/// Mock auditorium generator and seat-to-camera pose repository.
class MockAuditoriums {
  MockAuditoriums._();

  static const double eyeHeightOffset = 1.15; // Camera height above seat base
  static const Position3D defaultScreenTarget = Position3D(0.0, 3.5, 0.0);
  static const Position3D overviewCameraPosition = Position3D(0.0, 8.5, 21.0);
  static const Position3D overviewLookAtTarget = Position3D(0.0, 2.5, 5.0);

  static const List<String> rowLabels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  static const int seatsPerRow = 8;

  // Pre-determined unavailable mock seats
  static const Set<String> unavailableSeatIds = {
    'A4',
    'A5',
    'B3',
    'C4',
    'C5',
    'D5',
    'D6',
    'F2',
    'F3',
    'G7',
    'H4',
  };

  /// Generates the complete 2D and 3D auditorium seat layout.
  static List<Seat> generateAuditoriumSeats({double basePrice = 16.50}) {
    final List<Seat> seats = [];

    // Lateral X spacing for 8 seats with center aisle between seat 4 and 5
    final List<double> xOffsets = [
      -4.5, // 1
      -3.2, // 2
      -1.9, // 3
      -0.8, // 4
      0.8,  // 5
      1.9,  // 6
      3.2,  // 7
      4.5,  // 8
    ];

    for (int r = 0; r < rowLabels.length; r++) {
      final row = rowLabels[r];
      final isVip = row == 'H';
      final double z = 6.0 + (r * 1.5); // Row depth from screen: 6.0m to 16.5m
      final double y = 0.5 + (r * 0.42); // Stepped theater incline: 0.5m to 3.44m
      final seatPrice = isVip ? basePrice + 5.0 : basePrice;

      for (int s = 1; s <= seatsPerRow; s++) {
        final id = '$row$s';
        final isUnavailable = unavailableSeatIds.contains(id);
        final x = xOffsets[s - 1];

        seats.add(
          Seat(
            id: id,
            rowLabel: row,
            seatNumber: s,
            type: isVip ? SeatType.vip : SeatType.standard,
            status: isUnavailable ? SeatStatus.unavailable : SeatStatus.available,
            price: seatPrice,
            worldPosition: Position3D(x, y, z),
          ),
        );
      }
    }

    return seats;
  }

  /// Maps a seat to its precise 3D viewing camera pose.
  static SeatCameraPose getCameraPoseForSeat(Seat seat) {
    final eyePosition = Position3D(
      seat.worldPosition.x,
      seat.worldPosition.y + eyeHeightOffset,
      seat.worldPosition.z,
    );

    // Target is screen center
    return SeatCameraPose(
      seatId: seat.id,
      cameraPosition: eyePosition,
      lookAtTarget: defaultScreenTarget,
      fov: 62.0,
    );
  }

  /// Get camera pose directly by seat ID.
  static SeatCameraPose? getCameraPoseBySeatId(String seatId, List<Seat> seats) {
    try {
      final seat = seats.firstWhere((s) => s.id == seatId);
      return getCameraPoseForSeat(seat);
    } catch (_) {
      return null;
    }
  }

  /// Overview camera pose for the initial entrance to the auditorium.
  static const SeatCameraPose overviewPose = SeatCameraPose(
    seatId: 'OVERVIEW',
    cameraPosition: overviewCameraPosition,
    lookAtTarget: overviewLookAtTarget,
    fov: 65.0,
  );
}
