import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/movie.dart';

/// Cinematic hero banner/carousel displaying featured movies.
class FeaturedCarousel extends StatefulWidget {
  final List<Movie> movies;
  final ValueChanged<Movie> onMovieSelected;

  const FeaturedCarousel({
    super.key,
    required this.movies,
    required this.onMovieSelected,
  });

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 380,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: widget.movies.length,
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    child: child,
                  );
                },
                child: _buildFeaturedCard(movie),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.movies.length, (index) {
            final isCurrent = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isCurrent ? 22 : 6,
              height: 5,
              decoration: BoxDecoration(
                color: isCurrent ? AppColors.primary : AppColors.surfaceBorder,
                borderRadius: AppSpacing.roundedFull,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(Movie movie) {
    return GestureDetector(
      onTap: () => widget.onMovieSelected(movie),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppSpacing.roundedXl,
          color: AppColors.surfaceElevated,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Backdrop Image
            Image.network(
              movie.backdropUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.surfaceElevated,
                child: const Center(
                  child: Icon(Icons.movie, size: 48, color: AppColors.textMuted),
                ),
              ),
            ),
            // Multi-stop Cinematic Gradient
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black.withValues(alpha: 0.98),
                  ],
                  stops: const [0.0, 0.4, 0.75, 1.0],
                ),
              ),
            ),
            // Featured Badge
            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppSpacing.roundedSm,
                ),
                child: Text(
                  'FEATURED PREMIERE',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textInverse,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            // Bottom Info
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    movie.title,
                    style: AppTypography.displayMedium.copyWith(fontSize: 24),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${movie.rating.toStringAsFixed(1)} / 10',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('•', style: TextStyle(color: AppColors.textMuted)),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        movie.duration,
                        style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('•', style: TextStyle(color: AppColors.textMuted)),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        movie.genres.take(2).join(', '),
                        style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
                      ),
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
