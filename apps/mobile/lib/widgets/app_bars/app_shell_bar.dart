import "package:flutter/material.dart";
import "package:wavelength/widgets/user_leading_icon.dart";

class AppShellBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppShellBar({super.key, required this.title});

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: AppBar(
        centerTitle: false,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        actions: const [UserLeadingIcon()],
      ),
    );
  }
}
