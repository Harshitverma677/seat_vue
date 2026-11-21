import 'dart:math' as math;
import '../../../data/mock_auditoriums.dart';
import '../../../models/seat.dart';

/// Geometry and viewing metrics calculation service.
/// Implements the exact specifications defined in 14_SEAT_METRICS_AND_GEOMETRY.md.
class SeatGeometryService {
  SeatGeometryService._();

  // Longitudinal configuration (in metres)
  static const double firstRowDist = 5.35; // Distance of Row A to screen plane
  static const double standardRowPitch = 0.95; // Real-world standard row pitch (0.90–1.10 m)
  static const double reclinerRowPitch = 1.60; // Real-world recliner row pitch (1.40–1.80 m)

  // Screen configuration
  static const double screenWidth = 11.60;
  static const double halfScreen = screenWidth / 2.0; // 5.80m

  // Seated eye height offset above tier floor (0.46m cushion + 0.74m torso/eye level)
  static const double eyeHeightOffset = 1.20;

  // Lateral X coordinates for columns 1 through 14 (indices 0 to 13).
  // Accounts for aisle gaps after seat 3 (left aisle: 1.15m) and seat 11 (right aisle: 1.15m).
  // Calibrated to match real-world cinema dimensions:
  // - B4: lateral offset ~2.2m left (-2.20m)
  // - F8: lateral offset ~0.3m right (+0.28m)
  // - I12: lateral offset ~3.3m right (+3.28m)
  static const List<double> columnXCoordinates = [
    -4.85, // Col 1 (Block 1)
    -4.30, // Col 2 (Block 1)
    -3.75, // Col 3 (Block 1)
    // --- Left Aisle Gap (1.15m) ---
    -2.20, // Col 4 (Block 2 - B4 target: ~2.2m left)
    -1.60, // Col 5 (Block 2)
    -1.00, // Col 6 (Block 2)
    -0.40, // Col 7 (Block 2)
    0.28,  // Col 8 (Block 2 - F8 target: ~0.3m right)
    0.88,  // Col 9 (Block 2)
    1.48,  // Col 10 (Block 2)
    2.08,  // Col 11 (Block 2)
    // --- Right Aisle Gap (1.15m) ---
    3.28,  // Col 12 (Block 3 - I12 target: ~3.3m right)
    3.83,  // Col 13 (Block 3)
    4.38,  // Col 14 (Block 3)
  ];

  /// Computes the longitudinal Z distance to the screen plane for a given row index.
  static double getZDistanceForRow(int rowIndex) {
    if (rowIndex < 8) {
      return firstRowDist + (rowIndex * standardRowPitch);
    } else {
      return firstRowDist + (7 * standardRowPitch) + ((rowIndex - 7) * reclinerRowPitch);
    }
  }

  /// Computes the lateral X coordinate (in meters) for a given seat column index (0..13).
  static double getXCoordinateForCol(int colIndex) {
    if (colIndex < 0) return columnXCoordinates.first;
    if (colIndex >= columnXCoordinates.length) return columnXCoordinates.last;
    return columnXCoordinates[colIndex];
  }

  /// Computes viewing metrics for a given seat based on real auditorium coordinates.
  static SeatViewingMetrics calculateMetrics(Seat seat) {
    final rawOffset = seat.worldPosition.x;
    final zDistance = seat.worldPosition.z;

    // Euclidean direct distance
    final directDistance = math.sqrt(zDistance * zDistance + rawOffset * rawOffset);

    // Horizontal field of view in degrees:
    // fovDegrees = (atan2(halfScreen + rawOffset, zDistance) + atan2(halfScreen - rawOffset, zDistance)) * (180 / pi)
    final leftAngle = math.atan2(halfScreen + rawOffset, zDistance);
    final rightAngle = math.atan2(halfScreen - rawOffset, zDistance);
    final fovRadians = leftAngle + rightAngle;
    final fovDegrees = (fovRadians * 180.0 / math.pi).round();

    // Lateral distance and label
    final distFromCenter = rawOffset.abs();
    final String centerLabel;
    if (distFromCenter < 0.15) {
      centerLabel = 'at centre';
    } else if (rawOffset < 0) {
      centerLabel = 'left of centre';
    } else {
      centerLabel = 'right of centre';
    }

    // Zone Tag according to 14_SEAT_METRICS_AND_GEOMETRY.md:
    // Row indices 0-2 (A-C): UP CLOSE
    // Row indices 3-6 (D-G): SWEET SPOT
    // Row indices 7-8 (H-I): FULL PICTURE
    final String badge;
    final rowIndex = MockAuditoriums.rowLabels.indexOf(seat.rowLabel);
    if (rowIndex >= 0 && rowIndex <= 2) {
      badge = 'UP CLOSE';
    } else if (rowIndex >= 3 && rowIndex <= 6) {
      badge = 'SWEET SPOT';
    } else {
      badge = 'FULL PICTURE';
    }

    return SeatViewingMetrics(
      distanceToScreen: zDistance,
      directDistance: directDistance,
      fieldOfView: fovDegrees,
      distanceFromCentre: distFromCenter,
      centreAlignmentLabel: centerLabel,
      badgeLabel: badge,
    );
  }
}

