import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Surface ──
  static const Color background = Color(0xFFF0F0F3);

  // ── Brand ──
  static const Color accent = Color(0xFFFF6B00);
  static const Color accentPressed = Color(0xFFE55D00);

  // ── Text ──
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF8A8A8E);

  // ── Semantic ──
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);

  // ── Shadows ──
  static const Color shadowLight = Color(0xFFFFFFFF);
  static const Color shadowDark = Color(0xFFBEBEBE);

  // ── Extruded (outer / convex) ──
  static const List<BoxShadow> extrudedShadow = [
    BoxShadow(
      color: shadowDark,
      offset: Offset(5, 5),
      blurRadius: 15,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: shadowLight,
      offset: Offset(-5, -5),
      blurRadius: 15,
      spreadRadius: 1,
    ),
  ];

  // ── Inverted (inner / concave) ──
  // Flutter doesn't support inset BoxShadow natively.
  // We simulate with a subtle gradient + lighter outer shadows.
  static const List<BoxShadow> invertedShadowOuter = [
    BoxShadow(
      color: shadowDark,
      offset: Offset(2, 2),
      blurRadius: 4,
    ),
    BoxShadow(
      color: shadowLight,
      offset: Offset(-2, -2),
      blurRadius: 4,
    ),
  ];

  // Keep the old name around so existing refs don't break during migration
  static const List<BoxShadow> neumorphicShadowOuter = extrudedShadow;
}
