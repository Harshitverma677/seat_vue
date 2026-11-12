import 'package:flutter_test/flutter_test.dart';
import 'package:seat_vue/data/mock_auditoriums.dart';
import 'package:seat_vue/features/seat_selection/state/seat_selection_controller.dart';
import 'package:seat_vue/models/seat.dart';

void main() {
  group('SeatSelectionController Tests', () {
    test('Initializes with full auditorium layout', () {
      final controller = SeatSelectionController(basePrice: 15.0);
      expect(controller.seats.length, equals(64)); // 8 rows x 8 seats
      expect(controller.selectedSeatIds, isEmpty);
      expect(controller.totalPrice, equals(0.0));
    });

    test('Toggles available seat selection correctly', () {
      final controller = SeatSelectionController(basePrice: 15.0);

      // C2 is available
      controller.toggleSeat('C2');
      expect(controller.isSelected('C2'), isTrue);
      expect(controller.activePreviewSeatId, equals('C2'));
      expect(controller.totalPrice, equals(15.0));

      // Toggle off
      controller.toggleSeat('C2');
      expect(controller.isSelected('C2'), isFalse);
      expect(controller.activePreviewSeatId, isNull);
      expect(controller.totalPrice, equals(0.0));
    });

    test('Unavailable seats cannot be selected', () {
      final controller = SeatSelectionController(basePrice: 15.0);

      // C4 is in MockAuditoriums.unavailableSeatIds
      expect(MockAuditoriums.unavailableSeatIds.contains('C4'), isTrue);

      controller.toggleSeat('C4');
      expect(controller.isSelected('C4'), isFalse);
      expect(controller.selectedSeatIds, isEmpty);
    });

    test('VIP seat has correct tier and pricing', () {
      final controller = SeatSelectionController(basePrice: 15.0);

      // Row H is VIP
      final vipSeat = controller.getSeatById('H2');
      expect(vipSeat, isNotNull);
      expect(vipSeat!.type, equals(SeatType.vip));
      expect(vipSeat.price, equals(20.0)); // 15 + 5

      controller.toggleSeat('H2');
      expect(controller.totalPrice, equals(20.0));
    });

    test('setActivePreviewSeat sets active preview without breaking selection', () {
      final controller = SeatSelectionController(basePrice: 15.0);

      controller.toggleSeat('B1');
      controller.toggleSeat('B2');
      expect(controller.selectedSeatIds.length, equals(2));

      controller.setActivePreviewSeat('B1');
      expect(controller.activePreviewSeatId, equals('B1'));
    });
  });
}
