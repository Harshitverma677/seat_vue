import 'dart:math' as math;
import '../models/seat.dart';
import '../models/seat_camera_pose.dart';

/// Mock auditorium generator and seat-to-camera pose repository.
/// Matches the reference recording layout: 9 rows (A-I), 13 columns,
/// Standard rows (A-G: €12.50) and Recliner rows (H-I: €16.00).
class MockAuditoriums {
  MockAuditoriums._();

  static const double eyeHeightOffset = 1.15; // Camera height above seat base
  static const Position3D defaultScreenTarget = Position3D(0.0, 3.5, 0.0);
  static const Position3D overviewCameraPosition = Position3D(0.0, 7.5, 18.0);
  static const Position3D overviewLookAtTarget = Position3D(0.0, 3.2, 0.0);

  static const List<String> rowLabels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];
  static const int totalColumns = 13;

  // Taken mock seats matching the reference video
  static const Set<String> unavailableSeatIds = {
    'A2',
    'A4',
    'A11',
    'B7',
    'C5',
    'C6',
    'D3',
    'D5',
    'D6',
    'D7',
    'D12',
    'E3',
    'E4',
    'E11',
    'F3',
    'F7',
    'G3',
    'G5',
    'G8',
    'G12',
    'H7',
  };

  // Recliner missing/gap seats for aisles in Rows H and I
  static const Set<String> aisleGaps = {
    'H3',
    'H4',
    'H10',
    'H11',
    'I3',
    'I4',
    'I10',
    'I11',
  };

  /// Lateral X offsets in meters for columns 1 to 13.
  /// Matches video reference:
  /// Seat 4: -2.2m (2.2m left of centre)
  /// Seat 8: +0.3m (0.3m right of centre)
  /// Seat 12: +3.3m (3.3m right of centre)
  static const List<double> columnXOffsets = [
    -3.8, // 1
    -3.0, // 2
    -2.2, // 3
    -2.2, // 4
    -1.6, // 5
    -1.0, // 6
    -0.4, // 7
    0.3,  // 8
    0.9,  // 9
    1.5,  // 10
    2.1,  // 11
    3.3,  // 12
    4.1,  // 13
  ];

  /// Generates the complete 2D and 3D auditorium seat layout.
  static List<Seat> generateAuditoriumSeats({
    double standardPrice = 12.50,
    double reclinerPrice = 16.00,
  }) {
    final List<Seat> seats = [];

    for (int r = 0; r < rowLabels.length; r++) {
      final row = rowLabels[r];
      final isRecliner = row == 'H' || row == 'I';
      final price = isRecliner ? reclinerPrice : standardPrice;

      // Distance from screen in meters:
      // Row B: 6.3m, Row F: 9.8m, Row I: 13.3m
      final double z = 5.6 + (r * 0.9625) + (isRecliner ? 0.35 : 0.0);
      final double y = 0.5 + (r * 0.38);

      for (int s = 1; s <= totalColumns; s++) {
        final id = '$row$s';
        if (aisleGaps.contains(id)) continue;

        final isUnavailable = unavailableSeatIds.contains(id);
        final x = columnXOffsets[s - 1];

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

  /// Calculates dynamic viewing metrics for a seat.
  static SeatViewingMetrics calculateMetrics(Seat seat) {
    // 1. Distance to screen
    final distanceToScreen = seat.worldPosition.z;

    // 2. Field of View (based on 10m wide screen at distance)
    const screenWidth = 11.0;
    final fovRadians = 2 * math.atan((screenWidth / 2) / distanceToScreen);
    final fovDegrees = (fovRadians * 180 / math.pi).round();

    // 3. Distance from centre
    final x = seat.worldPosition.x;
    final distFromCenter = x.abs();
    final String centerLabel;
    if (distFromCenter < 0.15) {
      centerLabel = 'at centre';
    } else if (x < 0) {
      centerLabel = 'left of centre';
    } else {
      centerLabel = 'right of centre';
    }

    // Category / Badge string
    final String badge;
    if (seat.type == SeatType.recliner || seat.type == SeatType.vip) {
      badge = 'RECLINER';
    } else if (seat.rowLabel == 'A' || seat.rowLabel == 'B' || seat.rowLabel == 'C') {
      badge = 'UP CLOSE';
    } else if (seat.rowLabel == 'D' || seat.rowLabel == 'E' || seat.rowLabel == 'F') {
      badge = 'SWEET SPOT';
    } else {
      badge = 'FULL PICTURE';
    }

    return SeatViewingMetrics(
      distanceToScreen: distanceToScreen,
      fieldOfView: fovDegrees,
      distanceFromCentre: distFromCenter,
      centreAlignmentLabel: centerLabel,
      badgeLabel: badge,
    );
  }

  /// Maps a seat to its precise 3D viewing camera pose.
  static SeatCameraPose getCameraPoseForSeat(Seat seat) {
    final eyePosition = Position3D(
      seat.worldPosition.x,
      seat.worldPosition.y + eyeHeightOffset,
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

  /// Overview camera pose.
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
  final int fieldOfView;
  final double distanceFromCentre;
  final String centreAlignmentLabel;
  final String badgeLabel;

  const SeatViewingMetrics({
    required this.distanceToScreen,
    required this.fieldOfView,
    required this.distanceFromCentre,
    required this.centreAlignmentLabel,
    required this.badgeLabel,
  });
}
