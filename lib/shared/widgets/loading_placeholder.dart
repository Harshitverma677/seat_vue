import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';

/// Reusable shimmer-like placeholder for loading states.
class LoadingPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const LoadingPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppSpacing.roundedMd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
      ),
    );
  }
}

