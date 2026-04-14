import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class NeumorphicBox extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final bool isPressed;

  const NeumorphicBox({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.isPressed = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16.0),
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        boxShadow: isPressed ? [] : AppColors.neumorphicShadowOuter,
      ),
      child: child,
    );
  }
}
