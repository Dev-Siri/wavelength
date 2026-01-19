import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

class AmplIconButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoButton(
        onPressed: disabled ? null : onPressed,
        onLongPress: disabled ? null : onLongPress,
        padding: padding,
        child: icon,
      );
    }

    return IconButton(
      onPressed: disabled ? null : onPressed,
      onLongPress: disabled ? null : onLongPress,
      padding: padding,
      color: color,
      icon: icon,
    );
  }
}
