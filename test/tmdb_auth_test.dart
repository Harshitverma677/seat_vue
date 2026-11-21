import 'package:flutter_test/flutter_test.dart';
import 'package:seat_vue/services/tmdb_service.dart';

void main() {
  test('TMDB Authentication and Now Playing verified through TmdbService', () async {
    final service = TmdbService();
    try {
      final movies = await service.getNowPlayingMovies(region: 'IN');
      expect(movies, isNotEmpty);
      expect(movies.first.title, isNotEmpty);
      print('✓ TMDB Bearer authentication verified. First movie: ${movies.first.title}');
    } finally {
      service.dispose();
    }
  });
}
