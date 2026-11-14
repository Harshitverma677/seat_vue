import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';

/// Clean horizontal seat status legend matching 06_STEP_04_SEAT_MAP_AND_CHECKOUT.md.
class SeatLegend extends StatelessWidget {
  const SeatLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildItem(
          label: 'Available',
          box: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: AppColors.availableFill,
              borderRadius: BorderRadius.circular(3.0),
              border: Border.all(color: AppColors.availableBorder, width: 1.0),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _buildItem(
          label: 'Taken',
          box: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: AppColors.takenFill,
              borderRadius: BorderRadius.circular(3.0),
              border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _buildItem(
          label: 'Recliner',
          box: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: AppColors.reclinerFill,
              borderRadius: BorderRadius.circular(3.0),
              border: Border.all(color: AppColors.seatReclinerBorder, width: 1.0),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _buildItem(
          label: 'Selected',
          box: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(3.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem({required String label, required Widget box}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        box,
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8E929E),
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
