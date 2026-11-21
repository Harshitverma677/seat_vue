import 'package:flutter_test/flutter_test.dart';
import 'package:seat_vue/services/tmdb_service.dart';

void main() {
  late TmdbService service;

  setUp(() {
    service = TmdbService();
  });

  tearDown(() {
    service.dispose();
  });

  group('TMDB Live API Endpoints Verification', () {
    test('1. Fetch Now Playing Movies in IN', () async {
      final movies = await service.getNowPlayingMovies(region: 'IN');
      expect(movies, isNotEmpty);
      expect(movies.first.title, isNotEmpty);
      expect(movies.first.voteAverage, isA<double>());
      print('✓ Now Playing: ${movies.length} movies loaded. First: ${movies.first.title}');
    });

    test('2. Fetch Upcoming Movies in IN', () async {
      final movies = await service.getUpcomingMovies(region: 'IN');
      expect(movies, isNotEmpty);
      expect(movies.first.title, isNotEmpty);
      print('✓ Upcoming: ${movies.length} movies loaded. First: ${movies.first.title}');
    });

    test('3. Fetch Popular Movies', () async {
      final movies = await service.getPopularMovies();
      expect(movies, isNotEmpty);
      expect(movies.first.title, isNotEmpty);
      print('✓ Popular: ${movies.length} movies loaded. First: ${movies.first.title}');
    });

    test('4. Search Movies by title', () async {
      final results = await service.searchMovies('Interstellar');
      expect(results, isNotEmpty);
      final found = results.any((m) => m.title.toLowerCase().contains('interstellar'));
      expect(found, isTrue);
      print('✓ Search: Found ${results.length} results for "Interstellar"');
    });

    test('5. Fetch Movie Details & Runtime', () async {
      // Test with Interstellar TMDB ID 157336
      final details = await service.getMovieDetails(157336);
      expect(details.title, 'Interstellar');
      expect(details.runtime, greaterThan(0));
      expect(details.formattedRuntime, contains('h'));
      expect(details.genres, isNotEmpty);
      print('✓ Movie Details: ${details.title}, Runtime: ${details.formattedRuntime}');
    });

    test('6. Fetch Movie Credits (Cast)', () async {
      final cast = await service.getMovieCredits(157336);
      expect(cast, isNotEmpty);
      expect(cast.any((c) => c.name.contains('Matthew McConaughey')), isTrue);
      print('✓ Cast: ${cast.length} members. Top: ${cast.first.name} as ${cast.first.character}');
    });

    test('7. Fetch Movie Videos (Trailers)', () async {
      final videos = await service.getMovieVideos(157336);
      expect(videos, isNotEmpty);
      final trailers = videos.where((v) => v.isYouTubeTrailer).toList();
      expect(trailers, isNotEmpty);
      print('✓ Videos: ${trailers.length} YouTube trailers available. URL: ${trailers.first.youtubeUrl}');
    });
  });
}
