import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seat_vue/data/mock_movies.dart';
import 'package:seat_vue/features/seat_preview/screens/seat_preview_screen.dart';
import 'package:seat_vue/features/seat_selection/state/seat_selection_controller.dart';

void main() {
  testWidgets('SeatPreviewScreen renders with realistic cinema UI elements', (WidgetTester tester) async {
    final movie = MockMovies.sampleMovies.first;
    final showtime = MockMovies.getShowtimesForMovie(movie.id).first;
    final controller = SeatSelectionController(basePrice: showtime.basePrice);
    controller.toggleSeat('F8'); // Test seat from Reference A

    await tester.pumpWidget(
      MaterialApp(
        home: SeatPreviewScreen(
          movie: movie,
          showtime: showtime,
          seatController: controller,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Reference A Top Bar elements
    expect(find.text('3D SEAT PREVIEW'), findsOneWidget);
    expect(find.text('Recenter'), findsOneWidget);

    // Verify Gesture Hint
    expect(find.text('Drag to look around · Tap a seat below to switch'), findsOneWidget);

    // Verify Reference A Bottom Sheet Info
    expect(find.text('F8'), findsWidgets); // Badge & selector
    expect(find.textContaining('Row F · Seat 8'), findsOneWidget);
    expect(find.text('2D Seat Map'), findsOneWidget);
  });
}
