import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';

/// Clean horizontal seat status legend matching reference recording.
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
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.seatAvailable,
              borderRadius: BorderRadius.circular(3.5),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _buildItem(
          label: 'Taken',
          box: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(3.5),
              border: Border.all(color: const Color(0xFF353942), width: 1.4),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _buildItem(
          label: 'Recliner',
          box: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.seatRecliner,
              borderRadius: BorderRadius.circular(3.5),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _buildItem(
          label: 'Selected',
          box: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.mintGreen,
              borderRadius: BorderRadius.circular(3.5),
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
