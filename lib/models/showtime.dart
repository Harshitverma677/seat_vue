/// Time of day period for movie showtimes.
enum ShowtimePeriod {
  morning,
  afternoon,
  evening,
  night;

  String get displayName {
    switch (this) {
      case ShowtimePeriod.morning:
        return 'Morning';
      case ShowtimePeriod.afternoon:
        return 'Afternoon';
      case ShowtimePeriod.evening:
        return 'Evening';
      case ShowtimePeriod.night:
        return 'Night';
    }
  }

  String get iconEmoji {
    switch (this) {
      case ShowtimePeriod.morning:
        return '🌅';
      case ShowtimePeriod.afternoon:
        return '☀️';
      case ShowtimePeriod.evening:
        return '🌆';
      case ShowtimePeriod.night:
        return '🌙';
    }
  }
}

/// Model representing a movie showtime option.
class Showtime {
  final String id;
  final String movieId;
  final String cinemaId;
  final String dateLabel;
  final String time;
  final String hallName;
  final String experienceType;
  final double basePrice;
  final ShowtimePeriod period;

  const Showtime({
    required this.id,
    required this.movieId,
    this.cinemaId = 'c1',
    required this.dateLabel,
    required this.time,
    required this.hallName,
    required this.experienceType,
    required this.basePrice,
    this.period = ShowtimePeriod.evening,
  });

  /// Computes the exact local DateTime of this showtime given a target calendar Date.
  DateTime? getScheduledDateTime(DateTime targetDate) {
    final cleanTime = time.trim();
    final isPm = cleanTime.toUpperCase().contains('PM');
    final isAm = cleanTime.toUpperCase().contains('AM');

    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(cleanTime);
    if (match == null) return null;

    int hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);

    if (isPm && hour < 12) {
      hour += 12;
    } else if (isAm && hour == 12) {
      hour = 0;
    }

    return DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      hour,
      minute,
    );
  }

  /// Checks whether this showtime has already passed relative to `now`.
  bool isPast(DateTime targetDate, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final scheduled = getScheduledDateTime(targetDate);
    if (scheduled == null) return false;
    return scheduled.isBefore(current);
  }
}
