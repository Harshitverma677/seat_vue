import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seat_vue/data/mock_movies.dart';
import 'package:seat_vue/features/seat_preview/screens/seat_preview_screen.dart';
import 'package:seat_vue/features/seat_selection/state/seat_selection_controller.dart';

void main() {
  testWidgets('SeatPreviewScreen renders matching the reference recording and toggles landscape fullscreen', (WidgetTester tester) async {
    final movie = MockMovies.sampleMovies.first;
    final showtime = MockMovies.getShowtimesForMovie(movie.id).first;
    final controller = SeatSelectionController(
      basePrice: showtime.basePrice,
      reclinerPrice: 16.00,
    );
    controller.toggleSeat('F8'); // Test seat from Reference video (Frame 7)

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

    // Verify Top Floating Label: "View from F8"
    expect(find.text('View from F8'), findsOneWidget);

    // Verify Category Badge: "SWEET SPOT"
    expect(find.text('SWEET SPOT'), findsOneWidget);

    // Verify Main Seat Label: "Row F, Seat 8"
    expect(find.text('Row F, Seat 8'), findsOneWidget);

    // Verify Metric Card Labels
    expect(find.text('to screen'), findsOneWidget);
    expect(find.text('field of view'), findsOneWidget);

    // Verify Action Buttons
    expect(find.text('Change seat'), findsOneWidget);
    expect(find.textContaining('Book · €12.50'), findsOneWidget);

    // Verify Fullscreen Button in top right corner
    final fullscreenBtn = find.byIcon(Icons.fullscreen_rounded);
    expect(fullscreenBtn, findsOneWidget);

    // Tap Fullscreen button to enter landscape fullscreen and hide bottom drawer
    await tester.tap(fullscreenBtn);
    await tester.pumpAndSettle();

    // Verify Exit button appears in fullscreen mode
    expect(find.byIcon(Icons.fullscreen_exit_rounded), findsOneWidget);
    expect(find.text('Exit Fullscreen'), findsOneWidget);

    // Verify normal portrait HUD is hidden in fullscreen mode
    expect(find.byIcon(Icons.fullscreen_rounded), findsNothing);

    // Tap Exit Fullscreen to return to normal portrait layout
    await tester.tap(find.byIcon(Icons.fullscreen_exit_rounded));
    await tester.pumpAndSettle();

    // Verify normal portrait HUD and Fullscreen button are restored
    expect(find.byIcon(Icons.fullscreen_rounded), findsOneWidget);
    expect(find.text('Change seat'), findsOneWidget);
    expect(find.textContaining('Book · €12.50'), findsOneWidget);
  });
}
