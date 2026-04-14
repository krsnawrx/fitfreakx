import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/theme/colors.dart';

/// A calorie progress ring seated inside a neumorphic circular surface.
class NeumorphicProgressRing extends StatelessWidget {
  final double percent;
  final double radius;
  final Widget center;
  final Color progressColor;

  const NeumorphicProgressRing({
    super.key,
    required this.percent,
    required this.radius,
    required this.center,
    this.progressColor = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercent = percent.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.background,
        boxShadow: AppColors.extrudedShadow,
      ),
      child: CircularPercentIndicator(
        radius: radius,
        lineWidth: 14,
        animation: true,
        animationDuration: 800,
        percent: clampedPercent,
        center: center,
        circularStrokeCap: CircularStrokeCap.round,
        backgroundColor: const Color(0xFFE0E0E3),
        progressColor: progressColor,
        animateFromLastPercent: true,
      ),
    );
  }
}
