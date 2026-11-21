import 'package:flutter/material.dart';
import '../data/mock_cinemas.dart';
import '../data/mock_movies.dart';
import '../features/booking_selection/screens/booking_selection_screen.dart';
import '../features/movie_details/screens/movie_details_screen.dart';
import '../features/movie_discovery/screens/movie_discovery_dashboard_screen.dart';
import '../features/seat_preview/screens/seat_preview_screen.dart';
import '../features/seat_selection/screens/seat_selection_screen.dart';
import '../features/seat_selection/state/seat_selection_controller.dart';
import '../models/cinema.dart';
import '../models/movie.dart';
import '../models/showtime.dart';

/// App route definitions.
class AppRoutes {
  AppRoutes._();

  static const String dashboard = '/';
  static const String movieDetails = '/movie-details';
  static const String bookingSelection = '/booking-selection';
  static const String seatSelection = '/seat-selection';
  static const String preview = '/preview';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final movie = MockMovies.sampleMovies.first;
    final showtime = MockMovies.getShowtimesForMovie(movie.id).first;
    final cinema = MockCinemas.delhiCinemas.first;

    switch (settings.name) {
      case preview:
        final controller = SeatSelectionController(
          basePrice: showtime.basePrice,
          reclinerPrice: 16.00,
        );
        controller.toggleSeat('I12');
        return MaterialPageRoute(
          builder: (_) => SeatPreviewScreen(
            movie: movie,
            showtime: showtime,
            seatController: controller,
          ),
          settings: settings,
        );

      case movieDetails:
        Movie targetMovie = movie;
        if (settings.arguments is Movie) targetMovie = settings.arguments as Movie;
        return MaterialPageRoute(
          builder: (_) => MovieDetailsScreen(movie: targetMovie),
          settings: settings,
        );

      case bookingSelection:
        Movie targetMovie = movie;
        if (settings.arguments is Movie) targetMovie = settings.arguments as Movie;
        return MaterialPageRoute(
          builder: (_) => BookingSelectionScreen(movie: targetMovie),
          settings: settings,
        );

      case seatSelection:
        Movie targetMovie = movie;
        Showtime targetShowtime = showtime;
        Cinema? targetCinema = cinema;

        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          if (args['movie'] is Movie) targetMovie = args['movie'] as Movie;
          if (args['showtime'] is Showtime) targetShowtime = args['showtime'] as Showtime;
          if (args['cinema'] is Cinema) targetCinema = args['cinema'] as Cinema;
        }

        return MaterialPageRoute(
          builder: (_) => SeatSelectionScreen(
            movie: targetMovie,
            showtime: targetShowtime,
            cinema: targetCinema,
          ),
          settings: settings,
        );

      case dashboard:
      default:
        return MaterialPageRoute(
          builder: (_) => const MovieDiscoveryDashboardScreen(
            initialMovies: MockMovies.sampleMovies,
          ),
          settings: settings,
        );
    }
  }
}
