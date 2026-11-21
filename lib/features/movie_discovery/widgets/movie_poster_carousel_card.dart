import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/movie.dart';

/// Large, prominent, rounded movie poster card designed for the horizontally
/// swipeable PageView carousel with independent Watch Trailer and Info actions.
class MoviePosterCarouselCard extends StatelessWidget {
  final Movie movie;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onWatchTrailerTap;
  final VoidCallback? onInfoTap;

  const MoviePosterCarouselCard({
    super.key,
    required this.movie,
    required this.isActive,
    required this.onTap,
    this.onWatchTrailerTap,
    this.onInfoTap,
  });

  /// Procedural cinematic gradient fallback based on movie ID/title.
  LinearGradient _getPosterGradient(String id) {
    switch (id) {
      case 'm1':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD97706), Color(0xFF78350F), Color(0xFF1E1B18)],
        );
      case 'm2':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2563EB), Color(0xFF1E1B4B), Color(0xFF0F172A)],
        );
      case 'm3':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDC2626), Color(0xFF7F1D1D), Color(0xFF18181B)],
        );
      default:
        final hash = id.hashCode.abs();
        final hues = [
          [const Color(0xFFEAB308), const Color(0xFF713F12), const Color(0xFF18181B)],
          [const Color(0xFFA855F7), const Color(0xFF6B21A8), const Color(0xFF1E1B4B)],
          [const Color(0xFFEC4899), const Color(0xFF831843), const Color(0xFF09090B)],
          [const Color(0xFF10B981), const Color(0xFF065F46), const Color(0xFF064E3B)],
        ];
        final picked = hues[hash % hues.length];
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: picked,
        );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: _getPosterGradient(movie.id),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_filter_rounded,
              size: 52,
              color: Colors.white.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                movie.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  letterSpacing: 0.2,
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isActive ? AppColors.surfaceBorderLight : AppColors.surfaceBorder,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isActive ? 0.55 : 0.25),
              blurRadius: isActive ? 22 : 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Poster Image
            if (movie.posterUrl.isNotEmpty)
              Image.network(
                movie.posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _buildPlaceholder();
                },
              )
            else
              _buildPlaceholder(),

            // Subtle gradient overlay at bottom
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),

            // Card Bottom Details (Title + Language/Certification + Real Duration)
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      shadows: [
                        Shadow(color: Colors.black, blurRadius: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          movie.certification,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (movie.duration.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          movie.duration,
                          style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
