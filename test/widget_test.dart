import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seat_vue/app/app.dart';
import 'package:seat_vue/data/mock_movies.dart';
import 'package:seat_vue/features/booking_selection/screens/booking_selection_screen.dart';
import 'package:seat_vue/features/seat_selection/screens/seat_selection_screen.dart';

void main() {
  testWidgets('SeatVue initial launch smoke test renders sliding movie cards carousel',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SeatVueApp());
    await tester.pumpAndSettle();

    // Verify Title and Icons
    expect(find.text('Dune: Part Two'), findsWidgets);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsNothing);

    // Verify Info Button
    expect(find.text('Info'), findsOneWidget);

    // Verify Horizontally Sliding PageView
    expect(find.byType(PageView), findsOneWidget);
  });

  testWidgets('Tapping movie card navigates to cinema/date/showtime selection and on to seat selection',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SeatVueApp());
    await tester.pumpAndSettle();

    // Tap on the center movie card
    await tester.tap(find.byType(PageView));
    await tester.pumpAndSettle();

    // Verify Booking Selection Screen UI
    expect(find.byType(BookingSelectionScreen), findsOneWidget);
    expect(find.text('Select Date'), findsOneWidget);
    expect(find.text('Cinema Halls in Delhi'), findsOneWidget);
    expect(find.text('Continue to Seat Selection'), findsOneWidget);

    // Tap Continue to Seat Selection
    await tester.tap(find.text('Continue to Seat Selection'));
    await tester.pumpAndSettle();

    // Verify Seat Selection Screen UI
    expect(find.byType(SeatSelectionScreen), findsOneWidget);
    expect(find.text('S C R E E N'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('Direct SeatSelectionScreen renders properly with cinema and showtime',
      (WidgetTester tester) async {
    final movie = MockMovies.sampleMovies.first;
    final showtime = MockMovies.getShowtimesForMovie(movie.id).first;

    await tester.pumpWidget(
      MaterialApp(
        home: SeatSelectionScreen(
          movie: movie,
          showtime: showtime,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Meridian'), findsOneWidget);
    expect(find.text('16:45 IMAX'), findsNothing);
    expect(find.text('S C R E E N'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
