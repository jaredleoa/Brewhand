// Animated scale widget for tap feedback
import 'package:flutter/material.dart';

class AnimatedScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const AnimatedScaleOnTap({required this.child, required this.onTap});
  @override
  State<AnimatedScaleOnTap> createState() => AnimatedScaleOnTapState();
}

class AnimatedScaleOnTapState extends State<AnimatedScaleOnTap> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}
