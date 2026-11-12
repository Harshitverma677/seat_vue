import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Cinema screen indicator with curved top arc and ambient glow.
class ScreenCurveIndicator extends StatelessWidget {
  final String label;

  const ScreenCurveIndicator({
    super.key,
    this.label = 'SCREEN',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomPaint(
          size: const Size(double.infinity, 38),
          painter: _ScreenArcPainter(),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.blur_on_rounded, size: 14, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 3.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScreenArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Glowing subtle gradient fill under screen
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final fillPath = Path()
      ..moveTo(size.width * 0.08, size.height * 0.9)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.1,
        size.width * 0.92,
        size.height * 0.9,
      )
      ..lineTo(size.width * 0.92, size.height)
      ..lineTo(size.width * 0.08, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);

    // Glow line
    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final linePath = Path()
      ..moveTo(size.width * 0.08, size.height * 0.9)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.1,
        size.width * 0.92,
        size.height * 0.9,
      );

    canvas.drawPath(linePath, glowPaint);

    // Crisp top line
    final strokePaint = Paint()
      ..color = AppColors.screenArc
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
