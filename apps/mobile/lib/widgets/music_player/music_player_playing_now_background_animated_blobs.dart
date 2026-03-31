// I have no idea what is happening here. Ts is just a bunch of math 🫩
import "dart:async";
import "dart:math";
import "dart:ui";

import "package:flutter/material.dart";

Widget buildBackgroundBlobs(List<Color> colors) {
  return Stack(
    children: [
      ...colors.map((c) {
        final size = 200 + Random().nextDouble() * 300;

        return ColorBlob(
          color: c.withAlpha(129),
          size: size,
          offset: Offset(
            Random().nextDouble() * 300,
            Random().nextDouble() * 600,
          ),
        );
      }),
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(color: Colors.transparent),
      ),
    ],
  );
}

class ColorBlob extends StatelessWidget {
  final Color color;
  final double size;
  final Offset offset;

  const ColorBlob({
    super.key,
    required this.color,
    required this.size,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class MusicPlayerPlayingNowBackgroundAnimatedBlobs extends StatefulWidget {
  final Color color;

  const MusicPlayerPlayingNowBackgroundAnimatedBlobs({
    super.key,
    required this.color,
  });

  @override
  State<MusicPlayerPlayingNowBackgroundAnimatedBlobs> createState() =>
      _MusicPlayerPlayingNowBackgroundAnimatedBlobsState();
}

class _MusicPlayerPlayingNowBackgroundAnimatedBlobsState
    extends State<MusicPlayerPlayingNowBackgroundAnimatedBlobs>
    with SingleTickerProviderStateMixin {
  late double x;
  late double y;
  late double vx;
  late double vy;
  final _rand = Random();

  double screenW = 0;
  double screenH = 0;

  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();
    x = _rand.nextDouble() * 400;
    y = _rand.nextDouble() * 800;

    vx = (_rand.nextDouble() - 0.5) * 0.8;
    vy = (_rand.nextDouble() - 0.5) * 0.8;

    _startDrift();
  }

  void _startDrift() {
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        x += vx;
        y += vy;

        vx += (_rand.nextDouble() - 0.5) * 0.02;
        vy += (_rand.nextDouble() - 0.5) * 0.02;

        vx = vx.clamp(-1.2, 1.2);
        vy = vy.clamp(-1.2, 1.2);

        if (x < -200 || x > screenW + 200) vx = -vx;
        if (y < -200 || y > screenH + 200) vy = -vy;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    screenW = size.width;
    screenH = size.height;
    return AnimatedPositioned(
      duration: const Duration(seconds: 14),
      curve: Curves.easeInOut,
      left: x,
      top: y,
      child: FadeTransition(
        opacity: _opacity,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              color: widget.color.withAlpha(153),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
