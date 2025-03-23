import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

class PlaylistCreationBottomSheet extends StatelessWidget {
  const PlaylistCreationBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final title = Text("Playlist", style: TextStyle(color: Colors.white));
    final subtitle = Text(
      "Create an empty playlist.",
      style: TextStyle(color: Colors.grey.shade600),
    );

    return Container(
      height: 80,
      width: double.infinity,
      margin: Platform.isIOS ? EdgeInsets.only(bottom: 20) : EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child:
                Platform.isIOS
                    ? CupertinoListTile(
                      onTap: () => print("yoo"),
                      leading: Icon(LucideIcons.listMusic),
                      padding: EdgeInsets.all(20),
                      title: title,
                      subtitle: subtitle,
                    )
                    : ListTile(
                      onTap: () => print("yoo"),
                      leading: Icon(LucideIcons.listMusic),
                      title: title,
                      subtitle: subtitle,
                    ),
          ),
        ],
      ),
    );
  }
}
