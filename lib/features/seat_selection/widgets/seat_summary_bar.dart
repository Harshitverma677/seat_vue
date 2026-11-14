import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../state/seat_selection_controller.dart';

/// Floating bottom booking panel matching reference recording.
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
            color: const Color(0xFF14161B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF242732), width: 1.0),
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
                      style: const TextStyle(
                        color: Colors.white,
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
                  backgroundColor: AppColors.mintGreen,
                  disabledBackgroundColor: const Color(0xFF283630),
                  foregroundColor: Colors.black,
                  disabledForegroundColor: const Color(0xFF5A6660),
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
