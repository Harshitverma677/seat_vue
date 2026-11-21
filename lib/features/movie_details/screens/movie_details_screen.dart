import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/cast_member.dart';
import '../../../models/movie.dart';
import '../../../models/movie_details.dart';
import '../../../models/movie_video.dart';
import '../../../repositories/movie_repository.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../booking_selection/screens/booking_selection_screen.dart';

/// Redesigned Movie Details Screen matching the Dribbble reference:
/// Features large curved poster backdrop, floating back button, pill genre tags,
/// rating with vote counts, trailer launcher, expandable "About the movie" (read more),
/// round cast avatars, and a prominent golden "Select seats" CTA button.
class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  MovieDetails? _tmdbDetails;

  /// Procedural gradient fallback when backdrop is loading or unavailable
  LinearGradient _getPosterGradient(String id) {
    final hash = id.hashCode.abs();
    final hues = [
      [const Color(0xFFD97706), const Color(0xFF78350F), const Color(0xFF1E1B18)],
      [const Color(0xFF2563EB), const Color(0xFF1E1B4B), const Color(0xFF0F172A)],
      [const Color(0xFFDC2626), const Color(0xFF7F1D1D), const Color(0xFF18181B)],
      [const Color(0xFF0284C7), const Color(0xFF075985), const Color(0xFF0F172A)],
      [const Color(0xFFEA580C), const Color(0xFF9A3412), const Color(0xFF18181B)],
    ];
    final picked = hues[hash % hues.length];
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: picked,
    );
  }

  Widget _buildPosterPlaceholder(String id, String title) {
    return Container(
      decoration: BoxDecoration(gradient: _getPosterGradient(id)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie_filter_rounded, size: 54, color: Colors.white70),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  List<CastMember> _cast = [];
  MovieVideo? _officialTrailer;
  bool _isLoadingTmdb = false;
  bool _isSynopsisExpanded = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadTmdbData();
  }

  Future<void> _loadTmdbData() async {
    final tmdbId = int.tryParse(widget.movie.id);
    if (tmdbId == null) return;

    setState(() => _isLoadingTmdb = true);
    try {
      final repo = MovieRepository.instance;
      final detailsFuture = repo.getDetails(tmdbId);
      final creditsFuture = repo.getCredits(tmdbId);
      final videosFuture = repo.getVideos(tmdbId);

      final results = await Future.wait([detailsFuture, creditsFuture, videosFuture]);

      if (mounted) {
        final details = results[0] as MovieDetails;
        final cast = results[1] as List<CastMember>;
        final videos = results[2] as List<MovieVideo>;

        final trailer = videos.firstWhere(
          (v) => v.isYouTubeTrailer && v.official,
          orElse: () => videos.firstWhere(
            (v) => v.isYouTubeTrailer,
            orElse: () => videos.isNotEmpty
                ? videos.first
                : const MovieVideo(id: '', key: '', name: '', site: '', type: '', official: false),
          ),
        );

        setState(() {
          _tmdbDetails = details;
          _cast = cast;
          _officialTrailer = trailer.key.isNotEmpty ? trailer : null;
          _isLoadingTmdb = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingTmdb = false);
      }
    }
  }

  void _onProceedToBooking() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingSelectionScreen(movie: widget.movie),
      ),
    );
  }

  void _openTrailerDialog() {
    if (_officialTrailer == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppColors.surfaceBorder, width: 1.5)),
        ),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _officialTrailer!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.ondemand_video_rounded, color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Official YouTube Trailer',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _officialTrailer!.youtubeUrl,
                            style: const TextStyle(color: AppColors.primary, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Close',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final String? tmdbBackdrop = _tmdbDetails?.backdropUrl;
    final String backdropUrl = (tmdbBackdrop != null && tmdbBackdrop.isNotEmpty)
        ? tmdbBackdrop
        : (movie.backdropUrl.isNotEmpty ? movie.backdropUrl : movie.posterUrl);
    final title = _tmdbDetails?.title ?? movie.title;
    final synopsis = _tmdbDetails?.overview.isNotEmpty == true ? _tmdbDetails!.overview : movie.synopsis;
    final duration = _tmdbDetails != null && _tmdbDetails!.runtime > 0 ? _tmdbDetails!.formattedRuntime : movie.duration;
    final rating = _tmdbDetails != null && _tmdbDetails!.voteAverage > 0 ? _tmdbDetails!.voteAverage : movie.rating;
    final genres = _tmdbDetails?.genres.isNotEmpty == true ? _tmdbDetails!.genres : movie.genres;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Curved Poster Header matching Dribbble reference
                Stack(
                  children: [
                    // Backdrop container with curved bottom
                    Container(
                      height: 410,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (backdropUrl.isNotEmpty)
                            Image.network(
                              backdropUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPosterPlaceholder(movie.id, title),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return _buildPosterPlaceholder(movie.id, title);
                              },
                            )
                          else
                            _buildPosterPlaceholder(movie.id, title),

                          // Dramatic dark gradient overlay
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.55),
                                  Colors.transparent,
                                  AppColors.background.withValues(alpha: 0.65),
                                  AppColors.background,
                                ],
                                stops: const [0.0, 0.35, 0.75, 1.0],
                              ),
                            ),
                          ),

                          // Watch Trailer Button Overlay
                          if (_officialTrailer != null)
                            Center(
                              child: GestureDetector(
                                onTap: _openTrailerDialog,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(color: AppColors.primary, width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.3),
                                        blurRadius: 16,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 24),
                                      SizedBox(width: 6),
                                      Text(
                                        'Watch Trailer',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Top Action Buttons (Back + Favorite)
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.black.withValues(alpha: 0.5),
                              radius: 20,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.black.withValues(alpha: 0.5),
                              radius: 20,
                              child: IconButton(
                                icon: Icon(
                                  _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                                  color: _isBookmarked ? AppColors.primary : Colors.white,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isBookmarked = !_isBookmarked;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // 2. Movie Title, Genre Pills & Metadata
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Movie Title
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Pill Genre Chips matching Dribbble reference
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: genres.map((g) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
                            ),
                            child: Text(
                              g,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // Rating & Stats Row: ★ 8.7/10 • 2h 42m • U/A
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 20, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            '${rating.toStringAsFixed(1)}/10',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text('•', style: TextStyle(color: AppColors.textMuted)),
                          const SizedBox(width: 10),
                          Text(
                            duration,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text('•', style: TextStyle(color: AppColors.textMuted)),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Text(
                              movie.certification,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),
                      const Divider(color: AppColors.surfaceBorder, height: 1),
                      const SizedBox(height: 18),

                      // 3. About the Movie with Expandable "read more"
                      const Text(
                        'About the movie',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        synopsis,
                        maxLines: _isSynopsisExpanded ? null : 3,
                        overflow: _isSynopsisExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      if (synopsis.length > 120) ...[
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSynopsisExpanded = !_isSynopsisExpanded;
                            });
                          },
                          child: Text(
                            _isSynopsisExpanded ? 'Show less' : 'Read more',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 22),

                      // 4. Cast Section with Round Profile Avatars
                      const Text(
                        'Cast',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (_isLoadingTmdb)
                        const SizedBox(
                          height: 90,
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            ),
                          ),
                        )
                      else if (_cast.isNotEmpty)
                        SizedBox(
                          height: 115,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _cast.take(12).length,
                            separatorBuilder: (_, __) => const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final member = _cast[index];
                              return SizedBox(
                                width: 72,
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: AppColors.surfaceElevated,
                                      backgroundImage: member.profileUrl != null
                                          ? NetworkImage(member.profileUrl!)
                                          : null,
                                      child: member.profileUrl == null
                                          ? const Icon(Icons.person, color: AppColors.textMuted, size: 28)
                                          : null,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      member.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      member.character,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      else ...[
                        Text(
                          movie.cast.join(', '),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],

                      // Bottom spacing for sticky button
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 5. Bottom Sticky Golden CTA: "Select seats"
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.96),
                border: const Border(
                  top: BorderSide(color: AppColors.surfaceBorder, width: 1.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.65),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _onProceedToBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textInverse,
                      elevation: 4,
                      shadowColor: AppColors.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Select seats',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
