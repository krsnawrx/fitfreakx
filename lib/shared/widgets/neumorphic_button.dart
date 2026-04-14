import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final bool isAccent;

  const NeumorphicButton({
    super.key,
    required this.child,
    required this.onTap,
    this.padding,
    this.borderRadius,
    this.isAccent = false,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isAccent ? AppColors.accent : AppColors.background;
    
    final shadows = widget.isAccent 
      ? [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.5),
            offset: const Offset(4.0, 4.0),
            blurRadius: 10.0,
            spreadRadius: 1.0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            offset: const Offset(-4.0, -4.0),
            blurRadius: 10.0,
            spreadRadius: 1.0,
          ),
        ]
      : AppColors.neumorphicShadowOuter;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          boxShadow: _isPressed ? [] : shadows,
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}
