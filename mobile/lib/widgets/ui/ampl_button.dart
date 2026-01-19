import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

class AmplButton extends StatelessWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// The background color of the button.
  final Color? color;

  /// The callback that is called when the button is tapped or otherwise activated.
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  /// Whether to nullify both the [onLongPress] and [onPressed] callbacks.
  final bool disabled;

  /// Whether to nullify both the [onLongPress] and [onPressed] callbacks.
  final EdgeInsetsGeometry? padding;

  /// Whether to nullify both the [onLongPress] and [onPressed] callbacks.
  final BorderRadius? borderRadius;

  final double? minWidth;
  final double? height;

  final CupertinoButtonSize sizeStyle;

  const AmplButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.disabled = false,
    this.onLongPress,
    this.padding,
    this.borderRadius,
    this.minWidth,
    this.height,
    this.color,
    this.sizeStyle = CupertinoButtonSize.large,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoButton(
        padding: padding,
        onPressed: disabled ? null : onPressed,
        onLongPress: disabled ? null : onLongPress,
        borderRadius: borderRadius,
        color: color,
        sizeStyle: sizeStyle,
        child: child,
      );
    }

    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      padding: padding,
      onPressed: disabled ? null : onPressed,
      onLongPress: disabled ? null : onLongPress,
      height: height,
      minWidth: minWidth,
      color: color,
      child: child,
    );
  }
}
