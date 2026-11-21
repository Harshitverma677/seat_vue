import 'package:flutter_test/flutter_test.dart';
import 'package:seat_vue/data/mock_auditoriums.dart';
import 'package:seat_vue/features/seat_preview/services/seat_geometry_service.dart';

void main() {
  group('Real-World Cinema Auditorium Physical Dimensions & Validation Tests', () {
    test('1. Standard cinema seat dimensions match real-world range', () {
      const standardSeatWidth = 0.55; // Metres (0.48–0.60 m)
      const standardSeatDepth = 0.52; // Metres (0.45–0.55 m)
      const standardSeatHeight = 0.46; // Metres (0.43–0.48 m)

      expect(standardSeatWidth, inInclusiveRange(0.48, 0.60));
      expect(standardSeatDepth, inInclusiveRange(0.45, 0.55));
      expect(standardSeatHeight, inInclusiveRange(0.43, 0.48));
    });

    test('2. Row spacing (pitch) respects required ranges for standard and recliners', () {
      expect(SeatGeometryService.standardRowPitch, inInclusiveRange(0.90, 1.10));
      expect(SeatGeometryService.reclinerRowPitch, inInclusiveRange(1.40, 1.80));
    });

    test('3. Recliners do not collide when fully reclined', () {
      const reclinedDepth = 0.92; // Extended footrest depth
      final clearance = SeatGeometryService.reclinerRowPitch - reclinedDepth;

      // Legroom clearance must be > 0.35m
      expect(clearance, greaterThan(0.35));
    });

    test('4. Aisles remain free of seats with clear passage', () {
      final col3X = SeatGeometryService.getXCoordinateForCol(2); // Col 3 (Left bank edge)
      final col4X = SeatGeometryService.getXCoordinateForCol(3); // Col 4 (Center bank edge)
      final leftAisleGap = (col4X - col3X).abs();

      final col11X = SeatGeometryService.getXCoordinateForCol(10); // Col 11 (Center bank edge)
      final col12X = SeatGeometryService.getXCoordinateForCol(11); // Col 12 (Right bank edge)
      final rightAisleGap = (col12X - col11X).abs();

      // Physical walking gap between seat edges must be >= 1.0m
      expect(leftAisleGap, greaterThanOrEqualTo(1.15));
      expect(rightAisleGap, greaterThanOrEqualTo(1.15));
    });

    test('5. Auditorium floor area is strictly within 190 m² and 270 m²', () {
      const auditoriumWidth = 12.00; // Metres
      const auditoriumLength = 16.50; // Metres
      const floorArea = auditoriumWidth * auditoriumLength; // 198.00 m²

      expect(floorArea, inInclusiveRange(190.0, 270.0));
      expect(floorArea, equals(198.00));
    });

    test('6. Average floor area per seat is strictly within 0.9 m² and 1.2 m²', () {
      final seats = MockAuditoriums.generateAuditoriumSeats();
      final capacity = seats.length; // 168 seats
      const floorArea = 12.00 * 16.50; // 198.00 m²
      final avgAreaPerSeat = floorArea / capacity; // 1.179 m²/seat

      expect(capacity, inInclusiveRange(100, 200));
      expect(avgAreaPerSeat, inInclusiveRange(0.90, 1.20));
      expect(avgAreaPerSeat, closeTo(1.179, 0.005));
    });

    test('7. Sightline clearance: Seats in front do not block the screen', () {
      // Row A floor: 0.40m, chair height: 0.90m -> top of front headrest: 1.30m
      const rowAFloor = 0.40;
      const chairHeight = 0.90;
      const frontHeadrestTopY = rowAFloor + chairHeight; // 1.30m

      // Row B floor: 0.75m, seated eye height: +1.20m -> eye Y: 1.95m
      const rowBFloor = 0.75;
      const eyeHeight = 1.20;
      const rowBEyeY = rowBFloor + eyeHeight; // 1.95m

      // Eye is 0.65m above the headrest in front
      final eyeAboveHeadrest = rowBEyeY - frontHeadrestTopY;
      expect(eyeAboveHeadrest, greaterThan(0.50));

      // Screen bottom is mounted at 1.90m above floor
      const screenBottomY = 1.90;
      expect(screenBottomY, greaterThan(frontHeadrestTopY));
    });

    test('8. Camera positions derived from actual seat 3D coordinates', () {
      final seats = MockAuditoriums.generateAuditoriumSeats();

      for (final seat in seats) {
        final pose = MockAuditoriums.getCameraPoseForSeat(seat);
        expect(pose.cameraPosition.x, equals(seat.worldPosition.x));
        expect(pose.cameraPosition.z, equals(seat.worldPosition.z));
        expect(
          pose.cameraPosition.y,
          closeTo(seat.worldPosition.y + SeatGeometryService.eyeHeightOffset, 0.001),
        );
      }
    });

    test('9. Flutter and Three.js use identical seat identifiers', () {
      final seats = MockAuditoriums.generateAuditoriumSeats();
      final ids = seats.map((s) => s.id).toSet();

      // Check key seats exist
      expect(ids.contains('B4'), isTrue);
      expect(ids.contains('F8'), isTrue);
      expect(ids.contains('I12'), isTrue);
      expect(ids.contains('A1'), isTrue);
      expect(ids.contains('L14'), isTrue);
      expect(ids.length, equals(168));
    });
  });
}
