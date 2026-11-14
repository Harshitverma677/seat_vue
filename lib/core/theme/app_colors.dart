import 'package:flutter/material.dart';

/// Centralized color palette for the Seat View cinematic design system.
/// Defined according to 04_STEP_02_THEME_AND_COMPONENTS.md.
class AppColors {
  AppColors._();

  // Background and Surfaces
  static const Color scaffold = Color(0xFF0A0A0C);
  static const Color background = Color(0xFF0A0A0C);
  static const Color surface = Color(0xFF16161A);
  static const Color surfaceElevated = Color(0xFF1B2030);
  static const Color surfaceHighlight = Color(0xFF262C42);
  static const Color surfaceBorder = Color(0xFF26262C);
  static const Color checkoutSurface = Color(0xFF121215);
  static const Color metricSurface = Color(0xFF1A1A1F);

  // Accents
  static const Color accent = Color(0xFF4ADE80); // Mint green (#4ADE80)
  static const Color accentText = Color(0xFF052E16);
  static const Color primary = Color(0xFF4ADE80);
  static const Color primaryLight = Color(0xFF7DE0AC);
  static const Color primaryDark = Color(0xFF22C55E);
  static const Color primaryGlow = Color(0x554ADE80);
  static const Color mintGreen = Color(0xFF4ADE80);
  static const Color mintGreenGlow = Color(0x664ADE80);

  // Pill Controls
  static const Color activePill = Color(0xFFFFFFFF);
  static const Color activePillText = Color(0xFF0A0A0C);

  // 3D Cinema Seat Material
  static const Color theaterSeat = Color(0xFFB91C1C); // Crimson red (#B91C1C)
  static const Color crimson = Color(0xFFB91C1C);
  static const Color secondary = Color(0xFF6366F1);
  static const Color secondaryLight = Color(0xFF818CF8);
  static const Color success = Color(0xFF4ADE80);

  // Seat States
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

  // Screen Indicator Glow
  static const Color screenArc = Color(0xFFE2E8F0);
  static const Color screenGlow = Color(0x33E2E8F0);

  // Typography
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF8E929E);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textInverse = Color(0xFF0A0A0C);

  // Badges & Ratings
  static const Color ratingStar = Color(0xFFFFC107);
}
