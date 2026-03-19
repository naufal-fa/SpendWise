import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFFF20DB9);

  // Backgrounds
  static const Color backgroundDark = Color(0xFF22101E);
  static const Color backgroundLight = Color(0xFFF8F5F8);
  static const Color surfaceDark = Color(0xFF2D1A28);

  // Accents
  static const Color successNeon = Color(0xFF39FF14);
  static const Color dangerRed = Color(0xFFEF4444);

  // Text
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Primary with opacity
  static Color primary5 = primary.withValues(alpha: 0.05);
  static Color primary10 = primary.withValues(alpha: 0.10);
  static Color primary20 = primary.withValues(alpha: 0.20);
  static Color primary30 = primary.withValues(alpha: 0.30);
  static Color primary40 = primary.withValues(alpha: 0.40);
  static Color primary60 = primary.withValues(alpha: 0.60);

  // Glow & Neon effects
  static List<BoxShadow> glowMagenta = [
    BoxShadow(
      color: primary.withValues(alpha: 0.4),
      blurRadius: 15,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> glowMagentaStrong = [
    BoxShadow(
      color: primary.withValues(alpha: 0.6),
      blurRadius: 25,
      spreadRadius: 0,
    ),
  ];

  static BoxDecoration neonBorder = BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: primary.withValues(alpha: 0.5)),
    boxShadow: [
      BoxShadow(
        color: primary.withValues(alpha: 0.2),
        blurRadius: 10,
        spreadRadius: 0,
      ),
    ],
  );
}
