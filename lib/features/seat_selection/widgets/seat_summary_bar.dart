import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/primary_button.dart';
import '../state/seat_selection_controller.dart';

/// Floating bottom summary bar showing selected seats, total amount, and 3D preview action.
class SeatSummaryBar extends StatelessWidget {
  final SeatSelectionController controller;
  final VoidCallback onOpen3DPreview;
  final VoidCallback onProceed;

  const SeatSummaryBar({
    super.key,
    required this.controller,
    required this.onOpen3DPreview,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final selectedSeats = controller.selectedSeats;
        final hasSelection = selectedSeats.isNotEmpty;
        final previewSeatId = controller.activePreviewSeatId ?? (hasSelection ? selectedSeats.last.id : null);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.96),
            border: const Border(
              top: BorderSide(color: AppColors.surfaceBorder, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Selected seat badges row
                if (hasSelection) ...[
                  Row(
                    children: [
                      Text(
                        'SELECTED SEATS (${selectedSeats.length}):',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: selectedSeats.map((seat) {
                              final isPreviewActive = seat.id == previewSeatId;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isPreviewActive ? AppColors.primary : AppColors.surfaceElevated,
                                    borderRadius: AppSpacing.roundedSm,
                                    border: Border.all(
                                      color: isPreviewActive ? AppColors.primary : AppColors.surfaceBorder,
                                    ),
                                  ),
                                  child: Text(
                                    seat.id,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: isPreviewActive ? AppColors.textInverse : AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],

                // Bottom actions and price
                Row(
                  children: [
                    // Total Price Column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasSelection ? 'Total Price' : 'Select Seat',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                        ),
                        Text(
                          hasSelection ? '\$${controller.totalPrice.toStringAsFixed(2)}' : '\$0.00',
                          style: AppTypography.titleLarge.copyWith(
                            color: hasSelection ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // 3D Preview Button
                    Expanded(
                      flex: 4,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: AppSpacing.roundedLg,
                          border: Border.all(
                            color: hasSelection ? AppColors.primary : AppColors.surfaceBorder,
                            width: 1.2,
                          ),
                        ),
                        child: OutlinedButton.icon(
                          onPressed: hasSelection ? onOpen3DPreview : null,
                          icon: Icon(
                            Icons.view_in_ar_rounded,
                            size: 20,
                            color: hasSelection ? AppColors.primary : AppColors.textMuted,
                          ),
                          label: Text(
                            hasSelection ? '3D View (${previewSeatId ?? ""})' : '3D View',
                            style: AppTypography.labelMedium.copyWith(
                              color: hasSelection ? AppColors.primary : AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppSpacing.roundedLg,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    // Mock Checkout Proceed Button
                    Expanded(
                      flex: 3,
                      child: PrimaryButton(
                        label: 'Book',
                        height: 52,
                        icon: Icons.check_circle_outline_rounded,
                        onPressed: hasSelection ? onProceed : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

