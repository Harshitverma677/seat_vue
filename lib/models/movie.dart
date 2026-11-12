/// Typed data model representing a movie.
class Movie {
  final String id;
  final String title;
  final String posterUrl;
  final String backdropUrl;
  final List<String> genres;
  final String duration;
  final double rating;
  final int releaseYear;
  final String pgRating;
  final String synopsis;
  final String director;
  final List<String> cast;
  final bool isFeatured;
  final bool isNowShowing;

  const Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.backdropUrl,
    required this.genres,
    required this.duration,
    required this.rating,
    required this.releaseYear,
    required this.pgRating,
    required this.synopsis,
    required this.director,
    required this.cast,
    this.isFeatured = false,
    this.isNowShowing = true,
  });
}

