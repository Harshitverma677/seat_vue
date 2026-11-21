import 'package:flutter_test/flutter_test.dart';
import 'package:seat_vue/data/mock_cinemas.dart';
import 'package:seat_vue/data/mock_movies.dart';
import 'package:seat_vue/models/showtime.dart';

void main() {
  group('Delhi Theatres and Past Showtimes Filtering Tests', () {
    test('1. All available cinemas are located strictly in Delhi', () {
      final cinemas = MockCinemas.delhiCinemas;
      expect(cinemas.isNotEmpty, isTrue);
      for (final cinema in cinemas) {
        expect(cinema.city.toLowerCase(), equals('delhi'));
      }
    });

    test('2. Showtime time parsing correctly converts AM/PM to local 24h DateTime', () {
      final baseDate = DateTime(2026, 11, 21);
      final morningShow = Showtime(
        id: 'st_test_1',
        movieId: 'm1',
        dateLabel: 'Today, 21 Nov',
        time: '09:45 AM',
        hallName: 'Audi 1',
        experienceType: '2D',
        basePrice: 10.0,
      );
      final afternoonShow = Showtime(
        id: 'st_test_2',
        movieId: 'm1',
        dateLabel: 'Today, 21 Nov',
        time: '03:45 PM',
        hallName: 'Audi 1',
        experienceType: 'IMAX 3D',
        basePrice: 15.0,
      );

      final morningDt = morningShow.getScheduledDateTime(baseDate)!;
      expect(morningDt.hour, equals(9));
      expect(morningDt.minute, equals(45));

      final afternoonDt = afternoonShow.getScheduledDateTime(baseDate)!;
      expect(afternoonDt.hour, equals(15));
      expect(afternoonDt.minute, equals(45));
    });

    test('3. Past showtimes are eliminated for today based on current local time', () {
      final today = DateTime(2026, 11, 21);
      // Simulated current local time: 14:00 (2:00 PM)
      final simulatedNow = DateTime(2026, 11, 21, 14, 0);

      final showtimes = MockMovies.getAvailableUpcomingShowtimes(
        movieId: 'm1',
        cinemaId: 'c1',
        targetDate: today,
        dateLabel: 'Today, 21 Nov',
        now: simulatedNow,
      );

      expect(showtimes.isNotEmpty, isTrue);
      for (final st in showtimes) {
        final stDt = st.getScheduledDateTime(today)!;
        expect(stDt.isAfter(simulatedNow), isTrue,
            reason: 'Showtime ${st.time} scheduled at $stDt should be after current time $simulatedNow');
      }

      // 09:45 AM and 11:15 AM must NOT be included because 14:00 has passed them
      expect(showtimes.any((st) => st.time.contains('09:45 AM')), isFalse);
      expect(showtimes.any((st) => st.time.contains('11:15 AM')), isFalse);

      // Afternoon (03:45 PM) and Evening (06:15 PM) must be present
      expect(showtimes.any((st) => st.time.contains('03:45 PM')), isTrue);
      expect(showtimes.any((st) => st.time.contains('06:15 PM')), isTrue);
    });

    test('4. Earliest upcoming showtime is the first item in filtered list', () {
      final today = DateTime(2026, 11, 21);
      final simulatedNow = DateTime(2026, 11, 21, 14, 0);

      final showtimes = MockMovies.getAvailableUpcomingShowtimes(
        movieId: 'm1',
        cinemaId: 'c1',
        targetDate: today,
        dateLabel: 'Today, 21 Nov',
        now: simulatedNow,
      );

      // Earliest upcoming show after 14:00 is 03:45 PM
      final earliest = showtimes.first;
      expect(earliest.time, equals('03:45 PM'));
    });

    test('5. Future dates retain all valid configured showtimes without time filtering', () {
      final tomorrow = DateTime(2026, 11, 22);
      final simulatedNow = DateTime(2026, 11, 21, 14, 0);

      final showtimes = MockMovies.getAvailableUpcomingShowtimes(
        movieId: 'm1',
        cinemaId: 'c1',
        targetDate: tomorrow,
        dateLabel: 'Tomorrow, 22 Nov',
        now: simulatedNow,
      );

      // Tomorrow morning shows (09:45 AM) must be available
      expect(showtimes.any((st) => st.time.contains('09:45 AM')), isTrue);
      expect(showtimes.length, greaterThanOrEqualTo(6));
    });

    test('6. Past dates return zero available showtimes', () {
      final yesterday = DateTime(2026, 11, 20);
      final simulatedNow = DateTime(2026, 11, 21, 14, 0);

      final showtimes = MockMovies.getAvailableUpcomingShowtimes(
        movieId: 'm1',
        cinemaId: 'c1',
        targetDate: yesterday,
        dateLabel: 'Yesterday, 20 Nov',
        now: simulatedNow,
      );

      expect(showtimes.isEmpty, isTrue);
    });
  });
}
