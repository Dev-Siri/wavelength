import "package:flutter/widgets.dart";

Widget pageSlideUpTransition(context, animation, secondaryAnimation, child) {
  return SlideTransition(
    position: animation.drive(
      Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut)),
    ),
    child: child,
  );
}
