import '../models/cast_member.dart';
import '../models/movie.dart';
import '../models/movie_details.dart';
import '../models/movie_video.dart';
import '../models/tmdb_movie.dart';
import '../services/tmdb_service.dart';

/// Repository abstracting TMDB data fetching for UI components.
class MovieRepository {
  final TmdbService _service;

  static final MovieRepository instance = MovieRepository();

  MovieRepository({TmdbService? service}) : _service = service ?? TmdbService();

  Future<List<TmdbMovie>> getNowPlaying() async {
    final list = await _service.getNowPlayingMovies();
    return _deduplicate(list);
  }

  Future<List<TmdbMovie>> getUpcoming() async {
    final list = await _service.getUpcomingMovies();
    return _deduplicate(list);
  }

  Future<List<TmdbMovie>> getPopular() async {
    final list = await _service.getPopularMovies();
    return _deduplicate(list);
  }

  Future<List<TmdbMovie>> search(String query) async {
    final list = await _service.searchMovies(query);
    return _deduplicate(list);
  }

  List<TmdbMovie> _deduplicate(List<TmdbMovie> movies) {
    final seen = <int>{};
    return movies.where((m) => seen.add(m.id)).toList();
  }

  /// Fetches Indian release date and certification if available.
  Future<({String? releaseDate, String? certification})> getIndianReleaseInfo(int movieId) async {
    try {
      final data = await _service.getMovieReleaseDates(movieId);
      final results = data['results'] as List<dynamic>? ?? [];
      final inItem = results.firstWhere(
        (r) => (r as Map<String, dynamic>)['iso_3166_1'] == 'IN',
        orElse: () => null,
      );

      if (inItem != null) {
        final releaseDates = (inItem['release_dates'] as List<dynamic>? ?? []);
        if (releaseDates.isNotEmpty) {
          // Prefer theatrical release (type 3) or latest confirmed date
          final theatrical = releaseDates.firstWhere(
            (d) => d['type'] == 3,
            orElse: () => releaseDates.first,
          );
          final rawDate = theatrical['release_date'] as String?;
          final cert = theatrical['certification'] as String?;
          final date = rawDate != null && rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;
          return (releaseDate: date, certification: cert != null && cert.isNotEmpty ? cert : null);
        }
      }
    } catch (_) {}
    return (releaseDate: null, certification: null);
  }

  Future<MovieDetails> getDetails(int movieId) async {
    return _service.getMovieDetails(movieId);
  }

  Future<List<CastMember>> getCredits(int movieId) async {
    return _service.getMovieCredits(movieId);
  }

  Future<List<MovieVideo>> getVideos(int movieId) async {
    return _service.getMovieVideos(movieId);
  }

  /// Helper to fetch full movie details and return an updated `Movie` model
  /// with real runtime, genres, synopsis, and cast.
  Future<Movie> getEnrichedMovie(TmdbMovie tmdbMovie) async {
    try {
      final details = await getDetails(tmdbMovie.id);
      final credits = await getCredits(tmdbMovie.id);

      final castNames = credits.take(5).map((c) => c.name).toList();

      return Movie(
        id: tmdbMovie.id.toString(),
        title: details.title,
        posterUrl: details.posterUrl ?? tmdbMovie.posterUrl ?? '',
        backdropUrl: details.backdropUrl ?? tmdbMovie.backdropUrl ?? '',
        genres: details.genres.isNotEmpty ? details.genres : tmdbMovie.genres,
        duration: details.formattedRuntime,
        rating: details.voteAverage > 0 ? details.voteAverage : tmdbMovie.voteAverage,
        releaseYear: details.releaseYear,
        pgRating: 'U/A',
        certification: 'U/A',
        language: tmdbMovie.formattedLanguage,
        synopsis: details.overview.isNotEmpty ? details.overview : tmdbMovie.overview,
        director: 'Director',
        cast: castNames.isNotEmpty ? castNames : ['Cast'],
        isFeatured: details.voteAverage >= 7.5,
        isNowShowing: true,
      );
    } catch (_) {
      return tmdbMovie.toMovie();
    }
  }
}
