/// Model representing a movie showtime option.
class Showtime {
  final String id;
  final String movieId;
  final String dateLabel;
  final String time;
  final String hallName;
  final String experienceType;
  final double basePrice;

  const Showtime({
    required this.id,
    required this.movieId,
    required this.dateLabel,
    required this.time,
    required this.hallName,
    required this.experienceType,
    required this.basePrice,
  });
}

