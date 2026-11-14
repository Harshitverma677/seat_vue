import '../features/seat_preview/services/seat_geometry_service.dart';
import '../models/seat.dart';
import '../models/seat_camera_pose.dart';

/// Mock auditorium generator and seat-to-camera pose repository.
/// Layout: 9 rows (A-I), 14 seats per row (1-14) = 126 total seats.
/// Rows A-H are Standard (€12.50), Row I is Recliner (€16.00).
class MockAuditoriums {
  MockAuditoriums._();

  static const double eyeHeightOffset = SeatGeometryService.eyeHeightOffset;
  static const Position3D defaultScreenTarget = Position3D(0.0, 3.5, 0.0);
  static const Position3D overviewCameraPosition = Position3D(0.0, 9.5, 18.5);
  static const Position3D overviewLookAtTarget = Position3D(0.0, 3.2, 0.0);

  static const List<String> rowLabels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];
  static const int seatsPerRow = 14;

  // Taken mock seats matching the reference video (never including test seats B4, F8, I12)
  static const Set<String> unavailableSeatIds = {
    'A2',
    'A5',
    'A12',
    'B7',
    'B9',
    'C5',
    'C6',
    'D3',
    'D5',
    'D6',
    'D7',
    'D13',
    'E3',
    'E4',
    'E12',
    'F3',
    'F7',
    'G3',
    'G5',
    'G9',
    'G13',
    'H7',
  };

  /// Generates the complete 126-seat auditorium layout (9 rows x 14 columns).
  static List<Seat> generateAuditoriumSeats({
    double standardPrice = 12.50,
    double reclinerPrice = 16.00,
  }) {
    final List<Seat> seats = [];

    for (int r = 0; r < rowLabels.length; r++) {
      final row = rowLabels[r];
      final isRecliner = row == 'I';
      final price = isRecliner ? reclinerPrice : standardPrice;

      // Longitudinal Z and elevation Y
      final double z = SeatGeometryService.getZDistanceForRow(r);
      final double y = 0.5 + (r * 0.38);

      for (int s = 1; s <= seatsPerRow; s++) {
        final id = '$row$s';
        final isUnavailable = unavailableSeatIds.contains(id);
        final x = SeatGeometryService.getXCoordinateForCol(s - 1);

        seats.add(
          Seat(
            id: id,
            rowLabel: row,
            seatNumber: s,
            type: isRecliner ? SeatType.recliner : SeatType.standard,
            status: isUnavailable ? SeatStatus.unavailable : SeatStatus.available,
            price: price,
            worldPosition: Position3D(x, y, z),
          ),
        );
      }
    }

    return seats;
  }

  /// Calculates dynamic viewing metrics for a seat via SeatGeometryService.
  static SeatViewingMetrics calculateMetrics(Seat seat) {
    return SeatGeometryService.calculateMetrics(seat);
  }

  /// Maps a seat to its precise 3D viewing camera pose.
  static SeatCameraPose getCameraPoseForSeat(Seat seat) {
    final eyePosition = Position3D(
      seat.worldPosition.x,
      seat.worldPosition.y + SeatGeometryService.eyeHeightOffset,
      seat.worldPosition.z,
    );

    final metrics = calculateMetrics(seat);

    return SeatCameraPose(
      seatId: seat.id,
      cameraPosition: eyePosition,
      lookAtTarget: defaultScreenTarget,
      fov: metrics.fieldOfView.toDouble(),
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

  /// Overview camera pose for initial auditorium entrance.
  static const SeatCameraPose overviewPose = SeatCameraPose(
    seatId: 'OVERVIEW',
    cameraPosition: overviewCameraPosition,
    lookAtTarget: overviewLookAtTarget,
    fov: 65.0,
  );
}

/// Detailed viewing metrics displayed in the reference preview panel.
class SeatViewingMetrics {
  final double distanceToScreen;
  final double directDistance;
  final int fieldOfView;
  final double distanceFromCentre;
  final String centreAlignmentLabel;
  final String badgeLabel;

  const SeatViewingMetrics({
    required this.distanceToScreen,
    this.directDistance = 0.0,
    required this.fieldOfView,
    required this.distanceFromCentre,
    required this.centreAlignmentLabel,
    required this.badgeLabel,
  });
}
