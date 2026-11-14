import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';

/// Cinema screen indicator with curved top arc and ambient glow matching reference video.
class ScreenCurveIndicator extends StatelessWidget {
  final String label;

  const ScreenCurveIndicator({
    super.key,
    this.label = 'SCREEN',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: const Size(double.infinity, 32),
          painter: _ScreenArcPainter(),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label.split('').join(' '),
          style: const TextStyle(
            color: Color(0xFF6E7280),
            letterSpacing: 4.0,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ScreenArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Glowing subtle gradient fill under screen
    final rect = Rect.fromLTWH(0, 0, width, height);
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final arcPath = Path()
      ..moveTo(width * 0.05, height * 0.85)
      ..quadraticBezierTo(
        width * 0.5,
        height * 0.05,
        width * 0.95,
        height * 0.85,
      );

    final fillPath = Path.from(arcPath)
      ..lineTo(width * 0.95, height)
      ..lineTo(width * 0.05, height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);

    // Soft outer glow line
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawPath(arcPath, glowPaint);

    // Crisp top line with gradient fading at ends
    final strokePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0.95),
          Colors.white.withValues(alpha: 0.95),
          Colors.white.withValues(alpha: 0.1),
        ],
        stops: const [0.0, 0.25, 0.75, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(arcPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
