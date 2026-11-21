import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/movie.dart';
import '../../../models/seat.dart';
import '../../../models/showtime.dart';

/// Clean modal dialog presenting mock booking confirmation.
class BookingConfirmationDialog extends StatelessWidget {
  final Movie movie;
  final Showtime showtime;
  final Seat seat;

  const BookingConfirmationDialog({
    super.key,
    required this.movie,
    required this.showtime,
    required this.seat,
  });

  static Future<void> show(
    BuildContext context, {
    required Movie movie,
    required Showtime showtime,
    required Seat seat,
  }) {
    return showDialog(
      context: context,
      builder: (_) => BookingConfirmationDialog(
        movie: movie,
        showtime: showtime,
        seat: seat,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface, // #16161A
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.surfaceBorder, width: 1.0),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mint checkmark badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 1.5),
              ),
              child: const Icon(Icons.check_rounded, color: AppColors.accent, size: 32),
            ),
            const SizedBox(height: 16),

            const Text(
              'Reservation Confirmed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Mock booking completed for prototype',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 20),

            // Ticket Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.checkoutSurface, // #121215
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '€${seat.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 20),
                  _buildDetailRow('Cinema', 'Meridian · Hall 3'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Showtime', '${showtime.dateLabel} · ${showtime.time} (${showtime.experienceType})'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Seat', 'Row ${seat.rowLabel}, Seat ${seat.seatNumber} (${seat.type == SeatType.recliner ? 'Recliner' : 'Standard'})'),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Dismiss Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.accentText,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.roundedFull,
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8E929E), fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

