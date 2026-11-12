import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Reusable pill chip for genre, rating, and feature tags.
class StatusChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final bool isSelected;
  final VoidCallback? onTap;

  const StatusChip({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor = AppColors.surfaceElevated,
    this.textColor = AppColors.textPrimary,
    this.borderColor,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = isSelected ? AppColors.primary : backgroundColor;
    final effectiveText = isSelected ? AppColors.textInverse : textColor;
    final effectiveBorder = isSelected ? AppColors.primary : (borderColor ?? AppColors.surfaceBorder);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: effectiveText),
          const SizedBox(width: AppSpacing.xs),
        ],
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: effectiveText,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.roundedFull,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: AppSpacing.roundedFull,
            border: Border.all(color: effectiveBorder, width: 1),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: content,
        ),
      ),
    );
  }
}
