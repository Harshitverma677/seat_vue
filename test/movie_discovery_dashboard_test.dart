import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seat_vue/data/mock_movies.dart';
import 'package:seat_vue/features/booking_selection/screens/booking_selection_screen.dart';
import 'package:seat_vue/features/movie_details/screens/movie_details_screen.dart';
import 'package:seat_vue/features/movie_discovery/screens/movie_discovery_dashboard_screen.dart';
import 'package:seat_vue/features/movie_discovery/widgets/cinema_selection_card.dart';
import 'package:seat_vue/features/seat_selection/screens/seat_selection_screen.dart';

void main() {
  group('Simplified Sliding Movie Cards Home Screen Tests', () {
    testWidgets('Home screen renders minimal sliding movie card layout matching reference',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MovieDiscoveryDashboardScreen(
            initialMovies: MockMovies.sampleMovies,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final firstMovie = MockMovies.sampleMovies.first;

      // 1. Prominent Movie Title at the top
      expect(find.text(firstMovie.title), findsWidgets);

      // 2. Action icons (Search)
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsNothing);

      // 3. Genre chips
      for (final genre in firstMovie.genres) {
        expect(find.text(genre), findsOneWidget);
      }

      // 4. Rating and Info button (replaces Watch Trailer)
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      expect(find.text('Info'), findsOneWidget);
      expect(find.text('Watch Trailer'), findsNothing);

      // 5. Horizontally swipeable PageView
      expect(find.byType(PageView), findsOneWidget);

      // 6. Minimal Bottom Navigation Bar with 3 icons
      expect(find.byIcon(Icons.motion_photos_on_rounded), findsOneWidget);
      expect(find.byIcon(Icons.confirmation_number_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);

      // 7. Verify NO distracting location pins or multiple category sections on home screen
      expect(find.text('Select Date'), findsNothing);
      expect(find.text('Cinema Halls in Delhi'), findsNothing);
      expect(find.text('Now Showing'), findsNothing);
    });

    testWidgets('Horizontal swiping updates active movie title, genres and rating',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MovieDiscoveryDashboardScreen(
            initialMovies: MockMovies.sampleMovies,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final firstMovie = MockMovies.sampleMovies[0];
      final secondMovie = MockMovies.sampleMovies[1];

      // Initial state is first movie
      expect(find.text(firstMovie.title), findsWidgets);

      // Swipe left on PageView to transition to second movie
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Second movie is now active
      expect(find.text(secondMovie.title), findsWidgets);
      for (final genre in secondMovie.genres) {
        expect(find.text(genre), findsOneWidget);
      }
    });

    testWidgets('Tapping Info button opens MovieDetailsScreen independently',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MovieDiscoveryDashboardScreen(
            initialMovies: MockMovies.sampleMovies,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Info button
      final infoBtn = find.text('Info');
      expect(infoBtn, findsOneWidget);
      await tester.tap(infoBtn);
      await tester.pumpAndSettle();

      // MovieDetailsScreen is opened
      expect(find.byType(MovieDetailsScreen), findsOneWidget);
      expect(find.text('About the movie'), findsOneWidget);
      expect(find.text('Cast'), findsOneWidget);
      expect(find.text('Select seats'), findsOneWidget);

      // Pop back to home screen
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // Back on home screen carousel
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('Tapping movie card navigates to Delhi cinema halls, date and showtime selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MovieDiscoveryDashboardScreen(
            initialMovies: MockMovies.sampleMovies,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the center movie card
      await tester.tap(find.byType(PageView));
      await tester.pumpAndSettle();

      // Navigated to BookingSelectionScreen
      expect(find.byType(BookingSelectionScreen), findsOneWidget);
      expect(find.text('Select Date'), findsOneWidget);
      expect(find.text('Cinema Halls in Delhi'), findsOneWidget);

      // Verify showtimes are embedded within selected cinema
      expect(find.text('Available Showtimes'), findsOneWidget);
      expect(find.byType(CinemaSelectionCard), findsWidgets);
      expect(find.text('Continue to Seat Selection'), findsOneWidget);

      // Continue to Seat Selection
      await tester.tap(find.text('Continue to Seat Selection'));
      await tester.pumpAndSettle();

      // In SeatSelectionScreen
      expect(find.byType(SeatSelectionScreen), findsOneWidget);
      expect(find.text('S C R E E N'), findsOneWidget);
    });
  });
}
