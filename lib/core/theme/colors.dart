import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF0F0F3);
  static const Color accent = Color(0xFFFF6B00); // Fit Freak Orange
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF8A8A8E);

  // Shadows
  static const Color shadowHighlight = Color(0xFFFFFFFF);
  static const Color shadowDepth = Color(0xFFBEBEBE);

  // Generic Outer Neumorphic Shadow (Convex)
  static const List<BoxShadow> neumorphicShadowOuter = [
    BoxShadow(
      color: shadowDepth,
      offset: Offset(4.0, 4.0),
      blurRadius: 10.0,
      spreadRadius: 1.0,
    ),
    BoxShadow(
      color: shadowHighlight,
      offset: Offset(-4.0, -4.0),
      blurRadius: 10.0,
      spreadRadius: 1.0,
    ),
  ];
}
