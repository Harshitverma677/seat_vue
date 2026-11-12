import 'package:flutter/material.dart';

/// Centralized color palette for the SeatVue dark cinematic design system.
class AppColors {
  AppColors._();

  // Background and Surfaces
  static const Color background = Color(0xFF090A0F);
  static const Color surface = Color(0xFF121520);
  static const Color surfaceElevated = Color(0xFF1B2030);
  static const Color surfaceHighlight = Color(0xFF262C42);
  static const Color surfaceBorder = Color(0xFF282F48);

  // Accents
  static const Color primary = Color(0xFFFFB300); // Amber Gold
  static const Color primaryLight = Color(0xFFFFCA28);
  static const Color primaryDark = Color(0xFFFF8F00);
  static const Color primaryGlow = Color(0x4DFFB300);

  static const Color secondary = Color(0xFF6366F1); // Indigo / Neon Purple
  static const Color secondaryLight = Color(0xFF818CF8);

  static const Color crimson = Color(0xFFEF4444); // Cinema Crimson
  static const Color success = Color(0xFF10B981); // Emerald Green

  // Seat States
  static const Color seatAvailable = Color(0xFF2F374E);
  static const Color seatAvailableBorder = Color(0xFF475375);
  static const Color seatSelected = Color(0xFFFFB300);
  static const Color seatSelectedBorder = Color(0xFFFFD54F);
  static const Color seatSelectedGlow = Color(0x66FFB300);
  static const Color seatUnavailable = Color(0xFF161924);
  static const Color seatUnavailableBorder = Color(0xFF1F2433);
  static const Color seatVip = Color(0xFFA855F7);
  static const Color seatVipBorder = Color(0xFFC084FC);

  // Screen Indicator Glow
  static const Color screenArc = Color(0xFFE2E8F0);
  static const Color screenGlow = Color(0x33E2E8F0);

  // Typography
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textInverse = Color(0xFF090A0F);

  // Badges & Ratings
  static const Color ratingStar = Color(0xFFFFC107);
}

