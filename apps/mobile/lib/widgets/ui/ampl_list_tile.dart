import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

class AmplListTile extends StatelessWidget {
  /// The primary content of the list tile.
  final Widget title;

  /// Additional content displayed below the title.
  final Widget? subtitle;

  /// Similar to [subtitle], an [additionalInfo] is used to display additional
  /// information. However, instead of being displayed below [title], it is
  /// displayed on the right, before [trailing].
  final Widget? additionalInfo;

  /// A widget to display before the title.
  final Widget? leading;

  /// A widget to display after the title.
  final Widget? trailing;

  /// Called when the user taps this list tile.
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double? leadingSize;
  final VisualDensity? visualDensity;

  const AmplListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.additionalInfo,
    this.leading,
    this.trailing,
    this.onTap,
    this.backgroundColor,
    this.padding,
    this.leadingSize,
    this.visualDensity,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoListTile(
        title: title,
        subtitle: subtitle,
        additionalInfo: additionalInfo,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        backgroundColor: backgroundColor,
        leadingSize: leadingSize ?? 28,
        padding: padding,
      );
    }

    return ListTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
      tileColor: backgroundColor,
      contentPadding: padding ?? const EdgeInsets.all(12),
      dense: true,
      visualDensity: visualDensity ?? VisualDensity.comfortable,
      minLeadingWidth: 0,
      minVerticalPadding: 0,
    );
  }
}
