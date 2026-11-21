import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seat_vue/data/mock_cinemas.dart';
import 'package:seat_vue/data/mock_movies.dart';
import 'package:seat_vue/features/booking_selection/screens/booking_selection_screen.dart';
import 'package:seat_vue/features/movie_details/screens/movie_details_screen.dart';

void main() {
  group('Dribbble UI Redesign Tests', () {
    final testMovie = MockMovies.sampleMovies.first;

    testWidgets('MovieDetailsScreen renders Dribbble aesthetic with golden Select seats button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MovieDetailsScreen(movie: testMovie),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Movie Title & Genre Chips
      expect(find.text(testMovie.title), findsWidgets);
      for (final genre in testMovie.genres) {
        expect(find.text(genre), findsOneWidget);
      }

      // 2. Rating row
      expect(find.byIcon(Icons.star_rounded), findsWidgets);
      expect(find.textContaining('/10'), findsOneWidget);
      expect(find.text(testMovie.certification), findsOneWidget);

      // 3. About the Movie section and expandable Read more
      expect(find.text('About the movie'), findsOneWidget);
      final readMoreFinder = find.text('Read more');
      expect(readMoreFinder, findsOneWidget);

      // Scroll to 'Read more' and tap to toggle expansion
      await tester.ensureVisible(readMoreFinder);
      await tester.tap(readMoreFinder);
      await tester.pumpAndSettle();
      expect(find.text('Show less'), findsOneWidget);

      // 4. Cast section
      expect(find.text('Cast'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsWidgets);

      // 5. Golden CTA button: "Select seats"
      final selectSeatsBtn = find.text('Select seats');
      expect(selectSeatsBtn, findsOneWidget);

      // Tap 'Select seats' to navigate to BookingSelectionScreen
      await tester.tap(selectSeatsBtn);
      await tester.pumpAndSettle();

      // Verify navigated to BookingSelectionScreen
      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('Cinema Halls in Delhi'), findsOneWidget);
      expect(find.text('Continue to Seat Selection'), findsOneWidget);
    });

    testWidgets('BookingSelectionScreen allows cinema, date and showtime selection and continues to SeatSelectionScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookingSelectionScreen(movie: testMovie),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Delhi is default city
      expect(find.text('Delhi'), findsOneWidget);
      expect(find.text('Cinema Halls in Delhi'), findsOneWidget);

      // Verify Delhi cinema halls listed
      expect(find.text(MockCinemas.delhiCinemas.first.name), findsOneWidget);

      // Verify grouped showtimes are visible
      expect(find.text('Available Showtimes'), findsOneWidget);

      // Verify golden Continue CTA
      final continueBtn = find.text('Continue to Seat Selection');
      expect(continueBtn, findsOneWidget);

      // Tap Continue to Seat Selection
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      // Verify we arrived in SeatSelectionScreen (screen header with S C R E E N)
      expect(find.text('S C R E E N'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });
  });
}
