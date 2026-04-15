import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

class AmplIconButton extends StatefulWidget {
  /// The icon to display inside the button.
  final Widget icon;

  /// The background color of the button.
  final Color? color;

  /// The callback that is called when the button is tapped or otherwise activated.
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  /// Whether to nullify both the [onLongPress] and [onPressed] callbacks.
  final bool disabled;

  final EdgeInsetsGeometry? padding;

  const AmplIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.disabled = false,
    this.onLongPress,
    this.color,
    this.padding,
  });

  @override
  State<AmplIconButton> createState() => _AmplIconButtonState();
}

class _AmplIconButtonState extends State<AmplIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.4,
      upperBound: 1.0,
      value: 1.0,
    );

    _scale = CurvedAnimation(parent: _controller, curve: Curves.ease);
  }

  void _handleTap() async {
    await _controller.reverse();
    await _controller.forward();
    widget.onPressed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.disabled ? null : _handleTap,
      onLongPress: widget.disabled ? null : widget.onLongPress,
      child: ScaleTransition(
        scale: _scale,
        child: Padding(
          padding: widget.padding ?? const EdgeInsets.all(8),
          child: widget.icon,
        ),
      ),
    );
  }
}
