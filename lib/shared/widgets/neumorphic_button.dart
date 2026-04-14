import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

/// A neumorphic button that animates flat on press.
/// Set [isAccent] to fill with the orange brand colour.
class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool isAccent;
  final double? width;

  const NeumorphicButton({
    super.key,
    required this.child,
    required this.onTap,
    this.padding,
    this.borderRadius,
    this.isAccent = false,
    this.width,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isAccent ? AppColors.accent : AppColors.background;
    final radius = widget.borderRadius ?? BorderRadius.circular(12);

    final shadows = widget.isAccent
        ? [
            BoxShadow(
              color: AppColors.accent.withAlpha(128),
              offset: const Offset(5, 5),
              blurRadius: 15,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.white.withAlpha(77),
              offset: const Offset(-5, -5),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ]
        : AppColors.extrudedShadow;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width,
        padding: widget.padding ??
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: _pressed
              ? (widget.isAccent ? AppColors.accentPressed : AppColors.background)
              : bgColor,
          borderRadius: radius,
          boxShadow: _pressed ? [] : shadows,
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}
