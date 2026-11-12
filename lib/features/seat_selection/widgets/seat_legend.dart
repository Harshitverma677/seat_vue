import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Visual legend explaining seat states in the 2D auditorium.
class SeatLegend extends StatelessWidget {
  const SeatLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildItem(
            color: AppColors.seatAvailable,
            border: AppColors.seatAvailableBorder,
            label: 'Available',
          ),
          _buildItem(
            color: AppColors.seatSelected,
            border: AppColors.seatSelectedBorder,
            label: 'Selected',
            hasGlow: true,
          ),
          _buildItem(
            color: AppColors.seatUnavailable,
            border: AppColors.seatUnavailableBorder,
            label: 'Reserved',
          ),
          _buildItem(
            color: AppColors.seatVip,
            border: AppColors.seatVipBorder,
            label: 'VIP',
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required Color color,
    required Color border,
    required String label,
    bool hasGlow = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: border, width: 1),
            boxShadow: hasGlow
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
