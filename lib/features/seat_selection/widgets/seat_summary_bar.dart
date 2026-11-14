import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../state/seat_selection_controller.dart';

/// Floating bottom booking checkout bar matching 06_STEP_04_SEAT_MAP_AND_CHECKOUT.md.
class SeatSummaryBar extends StatelessWidget {
  final SeatSelectionController controller;
  final VoidCallback onContinue;

  const SeatSummaryBar({
    super.key,
    required this.controller,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final activeSeat = controller.activePreviewSeat ??
            (controller.selectedSeats.isNotEmpty ? controller.selectedSeats.last : null);

        final hasSelection = activeSeat != null;
        final seatLabel = hasSelection
            ? 'Row ${activeSeat.rowLabel} · Seat ${activeSeat.seatNumber}'
            : 'Select a seat';
        final priceLabel = hasSelection
            ? '€${activeSeat.price.toStringAsFixed(2)}'
            : '€0.00';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.checkoutSurface, // #121215
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.surfaceBorder, width: 1.0), // #26262C
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left: Row/Seat info & Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      seatLabel,
                      style: const TextStyle(
                        color: Color(0xFF8E929E),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      priceLabel,
                      style: TextStyle(
                        color: hasSelection ? Colors.white : const Color(0xFF6E7280),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Mint Green Continue Button
              ElevatedButton(
                onPressed: hasSelection ? onContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent, // #4ADE80
                  disabledBackgroundColor: const Color(0xFF1E2822),
                  foregroundColor: AppColors.accentText, // #052E16
                  disabledForegroundColor: const Color(0xFF43524A),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.roundedFull,
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
