import 'package:flutter/foundation.dart';
import '../../../data/mock_auditoriums.dart';
import '../../../models/seat.dart';

/// Single source of truth for seat selection and active 3D preview focus.
class SeatSelectionController extends ChangeNotifier {
  final List<Seat> _seats;
  final Set<String> _selectedSeatIds = <String>{};
  String? _activePreviewSeatId;

  SeatSelectionController({double basePrice = 16.50})
      : _seats = MockAuditoriums.generateAuditoriumSeats(basePrice: basePrice);

  List<Seat> get seats => List.unmodifiable(_seats);
  Set<String> get selectedSeatIds => Set.unmodifiable(_selectedSeatIds);
  String? get activePreviewSeatId => _activePreviewSeatId;

  Seat? get activePreviewSeat {
    if (_activePreviewSeatId == null) return null;
    return getSeatById(_activePreviewSeatId!);
  }

  List<Seat> get selectedSeats {
    return _seats.where((s) => _selectedSeatIds.contains(s.id)).toList();
  }

  double get totalPrice {
    return selectedSeats.fold(0.0, (sum, seat) => sum + seat.price);
  }

  bool isSelected(String seatId) => _selectedSeatIds.contains(seatId);

  Seat? getSeatById(String seatId) {
    try {
      return _seats.firstWhere((s) => s.id == seatId);
    } catch (_) {
      return null;
    }
  }

  /// Toggles selection of a seat. Unavailable seats cannot be selected.
  void toggleSeat(String seatId) {
    final seat = getSeatById(seatId);
    if (seat == null || seat.isUnavailable) return;

    if (_selectedSeatIds.contains(seatId)) {
      _selectedSeatIds.remove(seatId);
      if (_activePreviewSeatId == seatId) {
        _activePreviewSeatId = _selectedSeatIds.isNotEmpty ? _selectedSeatIds.last : null;
      }
    } else {
      _selectedSeatIds.add(seatId);
      _activePreviewSeatId = seatId;
    }
    notifyListeners();
  }

  /// Updates the active seat to be previewed in 3D.
  void setActivePreviewSeat(String seatId) {
    final seat = getSeatById(seatId);
    if (seat == null) return;
    _activePreviewSeatId = seatId;
    if (!_selectedSeatIds.contains(seatId) && !seat.isUnavailable) {
      _selectedSeatIds.add(seatId);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedSeatIds.clear();
    _activePreviewSeatId = null;
    notifyListeners();
  }
}
