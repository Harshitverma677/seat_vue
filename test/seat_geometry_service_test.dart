import 'package:flutter_test/flutter_test.dart';
import 'package:seat_vue/data/mock_auditoriums.dart';
import 'package:seat_vue/models/seat.dart';
import 'package:seat_vue/features/seat_preview/services/seat_geometry_service.dart';

void main() {
  group('SeatGeometryService Calibration & Geometry Tests', () {
    test('Auditorium generates 168 total seats (12 rows x 14 columns)', () {
      final seats = MockAuditoriums.generateAuditoriumSeats();
      expect(seats.length, equals(168));

      // Rows A-H are Standard, Rows I-L are Recliners
      final standardSeats = seats.where((s) => s.type == SeatType.standard).toList();
      final reclinerSeats = seats.where((s) => s.type == SeatType.recliner).toList();

      expect(standardSeats.length, equals(8 * 14)); // 112
      expect(reclinerSeats.length, equals(4 * 14)); // 56
    });

    test('Distance increases from front rows to back rows', () {
      final zA = SeatGeometryService.getZDistanceForRow(0);
      final zB = SeatGeometryService.getZDistanceForRow(1);
      final zF = SeatGeometryService.getZDistanceForRow(5);
      final zI = SeatGeometryService.getZDistanceForRow(8);

      expect(zA, lessThan(zB));
      expect(zB, lessThan(zF));
      expect(zF, lessThan(zI));
    });

    test('Lateral offsets are negative on left and positive on right', () {
      final x1 = SeatGeometryService.getXCoordinateForCol(0); // Col 1
      final x4 = SeatGeometryService.getXCoordinateForCol(3); // Col 4
      final x8 = SeatGeometryService.getXCoordinateForCol(7); // Col 8
      final x12 = SeatGeometryService.getXCoordinateForCol(11); // Col 12

      expect(x1, lessThan(0.0));
      expect(x4, lessThan(0.0));
      expect(x8, greaterThan(0.0));
      expect(x12, greaterThan(0.0));
    });

    test('Calibration target B4 matches specifications (~6.3m, ~82 deg, ~2.2m left)', () {
      final seats = MockAuditoriums.generateAuditoriumSeats();
      final seatB4 = seats.firstWhere((s) => s.id == 'B4');
      final metrics = SeatGeometryService.calculateMetrics(seatB4);

      expect(metrics.distanceToScreen, closeTo(6.3, 0.2));
      expect(metrics.fieldOfView, inInclusiveRange(78, 88));
      expect(metrics.distanceFromCentre, closeTo(2.2, 0.15));
      expect(metrics.centreAlignmentLabel, equals('left of centre'));
      expect(metrics.badgeLabel, equals('UP CLOSE'));
    });

    test('Calibration target F8 matches specifications (~10.1m, ~60 deg, ~0.3m right)', () {
      final seats = MockAuditoriums.generateAuditoriumSeats();
      final seatF8 = seats.firstWhere((s) => s.id == 'F8');
      final metrics = SeatGeometryService.calculateMetrics(seatF8);

      expect(metrics.distanceToScreen, closeTo(10.1, 0.5));
      expect(metrics.fieldOfView, inInclusiveRange(55, 68));
      expect(metrics.distanceFromCentre, closeTo(0.3, 0.15));
      expect(metrics.centreAlignmentLabel, equals('right of centre'));
      expect(metrics.badgeLabel, equals('SWEET SPOT'));
    });

    test('Calibration target I12 matches specifications (~13.6m, ~44 deg, ~3.3m right)', () {
      final seats = MockAuditoriums.generateAuditoriumSeats();
      final seatI12 = seats.firstWhere((s) => s.id == 'I12');
      final metrics = SeatGeometryService.calculateMetrics(seatI12);

      expect(metrics.distanceToScreen, closeTo(13.6, 0.5));
      expect(metrics.fieldOfView, inInclusiveRange(40, 50));
      expect(metrics.distanceFromCentre, closeTo(3.3, 0.15));
      expect(metrics.centreAlignmentLabel, equals('right of centre'));
      expect(metrics.badgeLabel, equals('FULL PICTURE'));
    });
  });
}

