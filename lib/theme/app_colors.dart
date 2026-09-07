import 'package:flutter/material.dart';

/// Central color palette so light & dark themes stay in sync
/// with the pink/rose "Rent House" brand look from the design.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFFD6336C); // deep rose/pink
  static const Color primaryLight = Color(0xFFF7C6D9);
  static const Color accentPeach = Color(0xFFFBD9B7);
  static const Color accentPink = Color(0xFFF7C9D8);

  // Light theme
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF7F7FA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1C1B1F);
  static const Color lightTextSecondary = Color(0xFF7A7A80);

  // Dark theme
  static const Color darkBackground = Color(0xFF121014);
  static const Color darkSurface = Color(0xFF1E1B20);
  static const Color darkCard = Color(0xFF262229);
  static const Color darkTextPrimary = Color(0xFFF5F1F3);
  static const Color darkTextSecondary = Color(0xFFB0AAB2);

  static const Color star = Color(0xFFFFB200);
  static const Color success = Color(0xFF2E9E5B);
}
