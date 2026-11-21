/// Video / trailer item from `GET /movie/{id}/videos`.
class MovieVideo {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final bool official;

  const MovieVideo({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    required this.official,
  });

  factory MovieVideo.fromJson(Map<String, dynamic> json) {
    return MovieVideo(
      id: json['id'] as String? ?? '',
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? 'Trailer',
      site: json['site'] as String? ?? 'YouTube',
      type: json['type'] as String? ?? 'Trailer',
      official: json['official'] as bool? ?? false,
    );
  }

  bool get isYouTubeTrailer => site.toLowerCase() == 'youtube' && type.toLowerCase() == 'trailer';

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';
}
