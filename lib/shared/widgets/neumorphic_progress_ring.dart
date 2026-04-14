import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/theme/colors.dart';

class NeumorphicProgressRing extends StatelessWidget {
  final double percent; // 0.0 to 1.0
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
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.background,
        boxShadow: AppColors.neumorphicShadowOuter,
      ),
      child: CircularPercentIndicator(
        radius: radius,
        lineWidth: 15.0,
        animation: true,
        percent: percent > 1.0 ? 1.0 : (percent < 0.0 ? 0.0 : percent),
        center: center,
        circularStrokeCap: CircularStrokeCap.round,
        backgroundColor: AppColors.background, // Invisible track basically due to neumorphic base
        progressColor: progressColor,
        animateFromLastPercent: true,
      ),
    );
  }
}
