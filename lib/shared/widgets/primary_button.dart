import 'package:flutter/material.dart';
import '../../core/constants/app_durations.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Reusable cinematic primary button with optional icon and loading indicator.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color backgroundColor;
  final Color textColor;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.textInverse,
    this.height = 54.0,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    final buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 20, color: textColor),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            label,
            style: AppTypography.labelLarge.copyWith(
              color: isEnabled ? textColor : AppColors.textMuted,
            ),
          ),
        ],
      ],
    );

    return AnimatedOpacity(
      duration: AppDurations.fast,
      opacity: isEnabled ? 1.0 : 0.5,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: AppSpacing.roundedLg,
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: backgroundColor.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: isEnabled ? backgroundColor : AppColors.surfaceElevated,
          borderRadius: AppSpacing.roundedLg,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: AppSpacing.roundedLg,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: buttonContent,
            ),
          ),
        ),
      ),
    );
  }
}

