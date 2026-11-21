import 'package:flutter/material.dart';

/// Centralized color palette for the Seat View cinematic design system.
/// Refined with the Dribbble movie booking dark charcoal, blue-grey, and golden yellow reference.
class AppColors {
  AppColors._();

  // Dribbble Background and Surfaces
  static const Color background = Color(0xFF141721); // Dark charcoal blue-grey
  static const Color scaffold = Color(0xFF141721);
  static const Color surface = Color(0xFF1F2433); // Dark cards
  static const Color surfaceElevated = Color(0xFF282F44);
  static const Color surfaceHighlight = Color(0xFF333B54);
  static const Color surfaceBorder = Color(0xFF2E374D); // Subtle borders
  static const Color surfaceBorderLight = Color(0xFF3B4660);
  static const Color checkoutSurface = Color(0xFF181C28);
  static const Color metricSurface = Color(0xFF1F2433);

  // Golden / Yellow Primary Accent (Dribbble reference CTA)
  static const Color primary = Color(0xFFF5B935); // Golden Yellow
  static const Color primaryLight = Color(0xFFFCD34D);
  static const Color primaryDark = Color(0xFFD97706);
  static const Color primaryGlow = Color(0x55F5B935);
  static const Color gold = Color(0xFFF5B935);
  static const Color goldLight = Color(0xFFFCD34D);
  static const Color goldGlow = Color(0x66F5B935);

  // Primary Button Text (Dark charcoal on golden button)
  static const Color textInverse = Color(0xFF0F172A);
  static const Color accentText = Color(0xFF0F172A);

  // Accent & legacy compatibility
  static const Color accent = Color(0xFFF5B935);
  static const Color mintGreen = Color(0xFF4ADE80);
  static const Color mintGreenGlow = Color(0x664ADE80);

  // Pill Controls
  static const Color activePill = Color(0xFFF5B935);
  static const Color activePillText = Color(0xFF0F172A);
  static const Color inactivePill = Color(0xFF1F2433);
  static const Color inactivePillText = Color(0xFF94A3B8);

  // 3D Cinema Seat Material (PRESERVED)
  static const Color theaterSeat = Color(0xFFB91C1C); // Crimson red (#B91C1C)
  static const Color crimson = Color(0xFFB91C1C);
  static const Color secondary = Color(0xFF6366F1);
  static const Color secondaryLight = Color(0xFF818CF8);
  static const Color success = Color(0xFF4ADE80);

  // Seat States (PRESERVED for 2D Grid)
  static const Color availableFill = Color(0xFF1E1E24);
  static const Color availableBorder = Color(0xFF2E2E36);
  static const Color seatAvailable = Color(0xFF1E1E24);
  static const Color seatAvailableBorder = Color(0xFF2E2E36);

  static const Color takenFill = Color(0xFF111114);
  static const Color seatUnavailable = Color(0xFF111114);
  static const Color seatUnavailableBorder = Color(0xFF26262C);

  static const Color reclinerFill = Color(0xFF2A1C1E);
  static const Color seatRecliner = Color(0xFF2A1C1E);
  static const Color seatReclinerBorder = Color(0xFF3F262A);
  static const Color seatVip = Color(0xFF2A1C1E);
  static const Color seatVipBorder = Color(0xFF3F262A);

  static const Color seatSelected = Color(0xFF4ADE80);
  static const Color seatSelectedBorder = Color(0xFF86EFAC);
  static const Color seatSelectedGlow = Color(0x774ADE80);

  // Screen Indicator Glow (PRESERVED)
  static const Color screenArc = Color(0xFFE2E8F0);
  static const Color screenGlow = Color(0x33E2E8F0);

  // Typography
  static const Color textPrimary = Color(0xFFF8FAFC); // White
  static const Color textSecondary = Color(0xFF94A3B8); // Grey
  static const Color textMuted = Color(0xFF64748B);

  // Badges & Ratings
  static const Color ratingStar = Color(0xFFF5B935); // Golden Yellow Star
}
