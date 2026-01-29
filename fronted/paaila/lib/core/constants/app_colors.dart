import 'package:flutter/material.dart';

class AppColors {
  // ─────────────────────────────────────────────────────────────────────────
  // PRIMARY BRAND - Soft, calming green (health & wellness focused)
  // ─────────────────────────────────────────────────────────────────────────
  /// Primary green - used sparingly for key actions and highlights
  static const Color primary = Color.fromARGB(255, 49, 135, 54);

  /// Lighter tint for subtle backgrounds and hover states
  static const Color primaryLight = Color(0xFFE8F5E9);

  /// Very subtle tint for large surface areas
  static const Color primarySoft = Color(0xFFF1F8F2);

  // ─────────────────────────────────────────────────────────────────────────
  // ACCENT COLORS - Used minimally for emphasis
  // ─────────────────────────────────────────────────────────────────────────
  /// Warm accent for streaks, achievements, energy
  static const Color accent = Color(0xFFFF8A65);

  /// Accent light tint
  static const Color accentLight = Color(0xFFFFF3E0);

  /// Blue accent for informational elements
  static const Color accentBlue = Color(0xFF5C9CE5);

  /// Blue light tint
  static const Color accentBlueLight = Color(0xFFE3F2FD);

  // ─────────────────────────────────────────────────────────────────────────
  // STATUS COLORS
  // ─────────────────────────────────────────────────────────────────────────
  /// Success state
  static const Color success = Color(0xFF43A047);

  /// Warning/caution state
  static const Color warning = Color(0xFFFFA726);

  /// Error/destructive state
  static const Color error = Color(0xFFE53935);

  // ─────────────────────────────────────────────────────────────────────────
  // SURFACES & BACKGROUNDS - Clean, minimal, light
  // ─────────────────────────────────────────────────────────────────────────
  /// Main app background - warm white
  static const Color background = Color(0xFFFAFAFA);

  /// Card/surface background - pure white
  static const Color surface = Color(0xFFFFFFFF);

  /// Slightly elevated surface
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  /// Muted background for sections
  static const Color surfaceMuted = Color(0xFFF5F5F5);

  // ─────────────────────────────────────────────────────────────────────────
  // TEXT COLORS - High contrast, readable
  // ─────────────────────────────────────────────────────────────────────────
  /// Primary text - near black for readability
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Secondary text - softer for descriptions
  static const Color textSecondary = Color(0xFF6B6B6B);

  /// Tertiary/hint text
  static const Color textTertiary = Color(0xFF9E9E9E);

  /// Inverted text on dark backgrounds
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─────────────────────────────────────────────────────────────────────────
  // BORDERS & DIVIDERS
  // ─────────────────────────────────────────────────────────────────────────
  /// Subtle border for cards
  static const Color border = Color(0xFFE8E8E8);

  /// Stronger border for inputs
  static const Color borderStrong = Color(0xFFD0D0D0);

  /// Divider color
  static const Color divider = Color(0xFFF0F0F0);

  // ─────────────────────────────────────────────────────────────────────────
  // RANKING & GAMIFICATION
  // ─────────────────────────────────────────────────────────────────────────
  /// Gold for first place
  static const Color rankGold = Color(0xFFFFB300);

  /// Silver for second place
  static const Color rankSilver = Color(0xFF9E9E9E);

  /// Bronze for third place
  static const Color rankBronze = Color(0xFFBF8040);

  // ─────────────────────────────────────────────────────────────────────────
  // DIFFICULTY INDICATORS
  // ─────────────────────────────────────────────────────────────────────────
  /// Easy difficulty
  static const Color difficultyEasy = Color(0xFF66BB6A);

  /// Medium difficulty
  static const Color difficultyMedium = Color(0xFFFFB74D);

  /// Hard difficulty
  static const Color difficultyHard = Color(0xFFEF5350);

  // ─────────────────────────────────────────────────────────────────────────
  // SHADOWS & OVERLAYS
  // ─────────────────────────────────────────────────────────────────────────
  /// Soft shadow for cards
  static Color shadow = Colors.black.withOpacity(0.04);

  /// Medium shadow for elevated elements
  static Color shadowMedium = Colors.black.withOpacity(0.08);

  // ─────────────────────────────────────────────────────────────────────────
  // LEGACY COMPATIBILITY
  // ─────────────────────────────────────────────────────────────────────────
  static const Color primaryGreen = primary;
  static const Color primaryGreenLight = primaryLight;
  static const Color primaryGreenDark = Color(0xFF1B5E20);
  static const Color energyOrange = accent;
  static const Color accentTeal = Color(0xFF00BFA5);
  static const Color claimPurple = Color(0xFF7C4DFF);
  static const Color contestedRed = error;
  static const Color progressAmber = warning;
  static const Color successGreen = success;
  static const Color errorRed = error;
  static const Color pureWhite = surface;
  static const Color neutralGray = textTertiary;
  static const Color mutedBackground = surfaceMuted;
  static const Color terrainBrown = Color(0xFF8D6E63);
  static const Color friendGreen = Color(0xFF00E676);
}
