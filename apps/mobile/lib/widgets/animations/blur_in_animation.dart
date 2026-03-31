import "dart:ui";

import "package:flutter/material.dart";

class BlurInAnimation extends StatelessWidget {
  final Widget child;

  const BlurInAnimation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 12.0, end: 0.0),
      builder: (context, blur, child) {
        return ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Opacity(opacity: 1 - (blur / 12), child: child),
        );
      },
      child: child,
    );
  }
}
