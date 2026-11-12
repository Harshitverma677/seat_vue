import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/showtime.dart';

/// Interactive showtime and date selector widget.
class ShowtimeSelector extends StatelessWidget {
  final List<Showtime> showtimes;
  final Showtime? selectedShowtime;
  final ValueChanged<Showtime> onShowtimeSelected;

  const ShowtimeSelector({
    super.key,
    required this.showtimes,
    required this.selectedShowtime,
    required this.onShowtimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Unique dates
    final dates = showtimes.map((s) => s.dateLabel).toSet().toList();
    final activeDate = selectedShowtime?.dateLabel ?? (dates.isNotEmpty ? dates.first : '');
    final dateShowtimes = showtimes.where((s) => s.dateLabel == activeDate).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Selector Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'SELECT DATE',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = date == activeDate;
              return GestureDetector(
                onTap: () {
                  final firstForDate = showtimes.firstWhere((s) => s.dateLabel == date);
                  onShowtimeSelected(firstForDate);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
                    borderRadius: AppSpacing.roundedMd,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      date,
                      style: AppTypography.labelMedium.copyWith(
                        color: isSelected ? AppColors.textInverse : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Showtime Cards Grid / List
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'AVAILABLE SHOWTIMES',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: dateShowtimes.map((st) {
              final isSelected = selectedShowtime?.id == st.id;
              return GestureDetector(
                onTap: () => onShowtimeSelected(st),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
                    borderRadius: AppSpacing.roundedMd,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: isSelected ? AppColors.textInverse : AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            st.time,
                            style: AppTypography.titleMedium.copyWith(
                              fontSize: 16,
                              color: isSelected ? AppColors.textInverse : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        st.experienceType,
                        style: AppTypography.labelSmall.copyWith(
                          color: isSelected ? AppColors.textInverse.withValues(alpha: 0.8) : AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${st.basePrice.toStringAsFixed(2)}',
                        style: AppTypography.labelSmall.copyWith(
                          color: isSelected ? AppColors.textInverse : AppColors.primaryLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
