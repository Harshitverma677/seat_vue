import '../core/config/tmdb_config.dart';

/// Actor / cast member from `GET /movie/{id}/credits`.
class CastMember {
  final int id;
  final String name;
  final String character;
  final String? profilePath;
  final int order;

  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    required this.order,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown Actor',
      character: json['character'] as String? ?? 'Character',
      profilePath: json['profile_path'] as String?,
      order: json['order'] as int? ?? 999,
    );
  }

  String? get profileUrl => TmdbConfig.getProfileUrl(profilePath, size: TmdbConfig.profileSmall);
}
