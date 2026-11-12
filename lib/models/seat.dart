/// Three-dimensional point in the cinema coordinate space (in meters).
/// Origin (0, 0, 0) is at the center of the floor directly below the screen.
/// +X is right, +Y is up, +Z is back into the auditorium seating.
class Position3D {
  final double x;
  final double y;
  final double z;

  const Position3D(this.x, this.y, this.z);

  Position3D copyWith({double? x, double? y, double? z}) {
    return Position3D(x ?? this.x, y ?? this.y, z ?? this.z);
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'z': z};

  factory Position3D.fromJson(Map<String, dynamic> json) => Position3D(
        (json['x'] as num).toDouble(),
        (json['y'] as num).toDouble(),
        (json['z'] as num).toDouble(),
      );

  @override
  String toString() => 'Position3D($x, $y, $z)';
}

/// The booking status of an individual seat.
enum SeatStatus {
  available,
  selected,
  unavailable,
}

/// Category or tier of seat.
enum SeatType {
  standard,
  vip,
}

/// Typed model representing a seat in the auditorium.
class Seat {
  final String id; // e.g. "C7"
  final String rowLabel; // e.g. "C"
  final int seatNumber; // e.g. 7
  final SeatType type;
  final SeatStatus status;
  final double price;
  final Position3D worldPosition;

  const Seat({
    required this.id,
    required this.rowLabel,
    required this.seatNumber,
    this.type = SeatType.standard,
    this.status = SeatStatus.available,
    required this.price,
    required this.worldPosition,
  });

  bool get isAvailable => status == SeatStatus.available;
  bool get isSelected => status == SeatStatus.selected;
  bool get isUnavailable => status == SeatStatus.unavailable;

  Seat copyWith({
    SeatStatus? status,
    SeatType? type,
    double? price,
  }) {
    return Seat(
      id: id,
      rowLabel: rowLabel,
      seatNumber: seatNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      price: price ?? this.price,
      worldPosition: worldPosition,
    );
  }
}
