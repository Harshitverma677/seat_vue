import '../core/config/tmdb_config.dart';

/// Detailed information for a single movie from `GET /movie/{id}`.
class MovieDetails {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final List<String> genres;
  final int runtime; // in minutes
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final String originalLanguage;
  final String status;
  final String? tagline;

  const MovieDetails({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.genres,
    required this.runtime,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.originalLanguage,
    required this.status,
    this.tagline,
  });

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    final genreList = (json['genres'] as List<dynamic>?)
            ?.map((g) => (g as Map<String, dynamic>)['name'] as String? ?? '')
            .where((name) => name.isNotEmpty)
            .toList() ??
        [];

    return MovieDetails(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Untitled',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      genres: genreList,
      runtime: json['runtime'] as int? ?? 0,
      releaseDate: json['release_date'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      originalLanguage: json['original_language'] as String? ?? 'en',
      status: json['status'] as String? ?? 'Released',
      tagline: json['tagline'] as String?,
    );
  }

  String? get posterUrl => TmdbConfig.getPosterUrl(posterPath, size: TmdbConfig.posterLarge);
  String? get backdropUrl => TmdbConfig.getBackdropUrl(backdropPath, size: TmdbConfig.backdropLarge);

  String get formattedRuntime {
    if (runtime <= 0) return '2h 00m';
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  int get releaseYear {
    if (releaseDate.isNotEmpty && releaseDate.length >= 4) {
      return int.tryParse(releaseDate.substring(0, 4)) ?? DateTime.now().year;
    }
    return DateTime.now().year;
  }
}
