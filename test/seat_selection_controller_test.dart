import 'package:flutter_test/flutter_test.dart';
import 'package:seat_vue/data/mock_auditoriums.dart';
import 'package:seat_vue/features/seat_selection/state/seat_selection_controller.dart';
import 'package:seat_vue/models/seat.dart';

void main() {
  group('SeatSelectionController Tests', () {
    test('Initializes with full auditorium layout', () {
      final controller = SeatSelectionController(basePrice: 12.50, reclinerPrice: 16.00);
      expect(controller.seats.length, equals(126)); // 9 rows (A-I), 14 cols
      expect(controller.selectedSeatIds, isEmpty);
      expect(controller.totalPrice, equals(0.0));
    });

    test('Toggles available seat selection correctly', () {
      final controller = SeatSelectionController(basePrice: 12.50, reclinerPrice: 16.00);

      // C1 is available
      controller.toggleSeat('C1');
      expect(controller.isSelected('C1'), isTrue);
      expect(controller.activePreviewSeatId, equals('C1'));
      expect(controller.totalPrice, equals(12.50));

      // Toggle off
      controller.toggleSeat('C1');
      expect(controller.isSelected('C1'), isFalse);
      expect(controller.activePreviewSeatId, isNull);
      expect(controller.totalPrice, equals(0.0));
    });

    test('Unavailable seats cannot be selected', () {
      final controller = SeatSelectionController(basePrice: 12.50, reclinerPrice: 16.00);

      // C5 is in MockAuditoriums.unavailableSeatIds
      expect(MockAuditoriums.unavailableSeatIds.contains('C5'), isTrue);

      controller.toggleSeat('C5');
      expect(controller.isSelected('C5'), isFalse);
      expect(controller.selectedSeatIds, isEmpty);
    });

    test('Recliner seat has correct tier and pricing', () {
      final controller = SeatSelectionController(basePrice: 12.50, reclinerPrice: 16.00);

      // Row I is Recliner
      final reclinerSeat = controller.getSeatById('I12');
      expect(reclinerSeat, isNotNull);
      expect(reclinerSeat!.type, equals(SeatType.recliner));
      expect(reclinerSeat.price, equals(16.00));

      controller.toggleSeat('I12');
      expect(controller.totalPrice, equals(16.00));
    });

    test('setActivePreviewSeat sets active preview without breaking selection', () {
      final controller = SeatSelectionController(basePrice: 12.50, reclinerPrice: 16.00);

      controller.toggleSeat('B1');
      expect(controller.selectedSeatIds.length, equals(1));
      expect(controller.activePreviewSeatId, equals('B1'));

      // Tapping B2 moves the single-seat selection to B2
      controller.toggleSeat('B2');
      expect(controller.selectedSeatIds.length, equals(1));
      expect(controller.activePreviewSeatId, equals('B2'));
      expect(controller.isSelected('B2'), isTrue);

      controller.setActivePreviewSeat('B1');
      expect(controller.activePreviewSeatId, equals('B1'));
    });
  });
}
