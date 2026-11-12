import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/movie.dart';

/// Reusable card displaying movie poster, title, rating, and duration.
class MoviePosterCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final double width;
  final double height;
  final bool showInfo;

  const MoviePosterCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.width = 150.0,
    this.height = 220.0,
    this.showInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poster Image with rounded corners and subtle border
            Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                borderRadius: AppSpacing.roundedLg,
                color: AppColors.surfaceElevated,
                border: Border.all(color: AppColors.surfaceBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    movie.posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.surfaceElevated,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.movie_outlined, size: 36, color: AppColors.textMuted),
                            const SizedBox(height: AppSpacing.xs),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                              child: Text(
                                movie.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  // Rating Badge in top right corner
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: AppSpacing.roundedSm,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 13, color: AppColors.primary),
                          const SizedBox(width: 3),
                          Text(
                            movie.rating.toStringAsFixed(1),
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (showInfo) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                movie.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleMedium.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    movie.duration,
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Text('•', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      movie.genres.isNotEmpty ? movie.genres.first : '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
