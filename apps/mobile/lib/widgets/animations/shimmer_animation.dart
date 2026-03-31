import "package:flutter/material.dart";

class ShimmerAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShimmerAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 4),
  });

  @override
  State<ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<ShimmerAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final v = _controller.value;

        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-2 + (v * 4), -1),
              end: Alignment((v * 4), 1),
              colors: const [
                Color(0xFFDADADA),
                Color(0xFFDADADA),
                Colors.white,
                Color(0xFFDADADA),
                Color(0xFFDADADA),
                Color(0xFFDADADA),
              ],
              stops: const [-3.0, 0.0, 0.45, 0.5, 0.55, 3.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
