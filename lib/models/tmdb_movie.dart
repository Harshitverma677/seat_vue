import '../core/config/tmdb_config.dart';
import 'movie.dart';
import 'tmdb_genre.dart';

/// Typed TMDB Movie model representing a movie item in list endpoints
/// (Now Playing, Upcoming, Popular, Search).
class TmdbMovie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String releaseDate;
  final List<int> genreIds;
  final String originalLanguage;
  final int voteCount;

  const TmdbMovie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.genreIds,
    required this.originalLanguage,
    this.voteCount = 0,
  });

  factory TmdbMovie.fromJson(Map<String, dynamic> json) {
    return TmdbMovie(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Untitled',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['release_date'] as String? ?? '',
      genreIds: (json['genre_ids'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      originalLanguage: json['original_language'] as String? ?? 'en',
      voteCount: json['vote_count'] as int? ?? 0,
    );
  }

  String? get posterUrl => TmdbConfig.getPosterUrl(posterPath, size: TmdbConfig.posterLarge);
  String? get backdropUrl => TmdbConfig.getBackdropUrl(backdropPath, size: TmdbConfig.backdropLarge);
  List<String> get genres => TmdbGenres.getGenreNames(genreIds);

  int get releaseYear {
    if (releaseDate.isNotEmpty && releaseDate.length >= 4) {
      return int.tryParse(releaseDate.substring(0, 4)) ?? DateTime.now().year;
    }
    return DateTime.now().year;
  }

  String get formattedLanguage {
    switch (originalLanguage.toLowerCase()) {
      case 'hi':
        return 'Hindi';
      case 'en':
        return 'English';
      case 'te':
        return 'Telugu';
      case 'ta':
        return 'Tamil';
      case 'ml':
        return 'Malayalam';
      case 'kn':
        return 'Kannada';
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'ja':
        return 'Japanese';
      case 'ko':
        return 'Korean';
      default:
        return originalLanguage.toUpperCase();
    }
  }

  /// Converts this TMDB movie into the core app `Movie` model
  /// to ensure 100% interoperability with SeatSelectionScreen and 3D preview.
  Movie toMovie({String duration = '2h 15m', String certification = 'U/A'}) {
    return Movie(
      id: id.toString(),
      title: title,
      posterUrl: posterUrl ?? '',
      backdropUrl: backdropUrl ?? '',
      genres: genres.isNotEmpty ? genres : ['Cinema'],
      duration: duration,
      rating: voteAverage,
      releaseYear: releaseYear,
      pgRating: certification,
      certification: certification,
      language: formattedLanguage,
      synopsis: overview.isNotEmpty ? overview : 'No synopsis available.',
      director: 'TMDB Film',
      cast: const ['Featured Cast'],
      isFeatured: voteAverage >= 7.5,
      isNowShowing: true,
    );
  }
}
