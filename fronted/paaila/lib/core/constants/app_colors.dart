import 'package:flutter/material.dart';

class AppColors {
  // Primary brand greens (activity / success / ownership)
  /// Primary deep green used for buttons, active states and primary branding.
  static const Color primaryGreen = Color(0xFF2E7D32);

  /// Lighter variant of primaryGreen for surfaces or subtle highlights.
  static const Color primaryGreenLight = Color(0xFF66BB6A);

  /// Darker variant for app bars or elevated elements.
  static const Color primaryGreenDark = Color(0xFF1B5E20);

  // Accent colors (energy, social hints)
  /// Energetic orange used for call-to-action, streaks and activity nudges.
  static const Color energyOrange = Color(0xFFFF7043);

  /// Bright teal for special accents, badges and map pins.
  static const Color accentTeal = Color(0xFF00BFA5);

  /// Vibrant purple used to mark territory claims and map ownership highlights.
  static const Color claimPurple = Color(0xFF7C4DFF);

  /// Opponent/contested color used when a route is challenged or lost.
  static const Color contestedRed = Color(0xFFFF5252);

  // Progress & status
  /// Yellow/amber used for progress bars, partial completion and cautions.
  static const Color progressAmber = Color(0xFFFFD600);

  /// Success color (keeps backward compatibility with earlier green).
  static const Color successGreen = Color(0xFF4CAF50);

  /// Error color for failures and destructive actions.
  static const Color errorRed = Color(0xFFD32F2F);

  // Surfaces and text
  /// App background: soft off-white to reduce glare while keeping contrast.
  static const Color background = Color(0xFFF6F8F9);

  /// Surface color for cards and panels.
  static const Color surface = Color(0xFFFFFFFF);

  /// Pure white background.
  static const Color pureWhite = Color(0xFFFFFFFF);

  /// Primary text color: deep charcoal/ink for best readability.
  static const Color textPrimary = Color(0xFF0D1B2A);

  /// Secondary text / captions.
  static const Color textSecondary = Color(0xFF5B6B78);

  // Geography / theming for map and terrain
  /// Earth/terrain brown for trails, dirt paths and subtle map overlays.
  static const Color terrainBrown = Color(0xFF8D6E63);

  /// Friendly highlight used to tag friends, teammates or allied zones.
  static const Color friendGreen = Color(0xFF00E676);

  /// Semi-transparent shadow used across cards and popups.
  static Color shadow = Colors.black.withOpacity(0.15);

  // Utility grays
  /// Neutral gray used for dividers and disabled states.
  static const Color neutralGray = Color(0xFF9AA6B2);

  /// Subtle muted background for lists and empty states.
  static const Color mutedBackground = Color(0xFFF0F3F5);
}
