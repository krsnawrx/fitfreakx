import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

enum NeumorphicType { extruded, inverted }

/// A unified neumorphic container that can render either an
/// **extruded** (raised) or **inverted** (recessed) surface.
class NeumorphicContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final NeumorphicType type;
  final bool flat; // true = no shadows (pressed state)

  const NeumorphicContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.type = NeumorphicType.extruded,
    this.flat = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);

    if (type == NeumorphicType.inverted) {
      return _buildInverted(radius);
    }
    return _buildExtruded(radius);
  }

  Widget _buildExtruded(BorderRadius radius) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: radius,
        boxShadow: flat ? [] : AppColors.extrudedShadow,
      ),
      child: child,
    );
  }

  Widget _buildInverted(BorderRadius radius) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: AppColors.background,
        boxShadow: flat ? [] : AppColors.invertedShadowOuter,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE6E6E9), // slightly darker  → illusion of depth
            Color(0xFFF0F0F3), // base
            Color(0xFFF8F8FB), // slightly lighter → illusion of depth
          ],
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
