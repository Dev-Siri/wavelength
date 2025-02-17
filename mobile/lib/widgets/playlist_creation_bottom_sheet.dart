import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

class PlaylistCreationBottomSheet extends StatelessWidget {
  const PlaylistCreationBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child: ListTile(
              onTap: () => print("yoo"),
              leading: Icon(LucideIcons.listMusic),
              title: Text("Playlist"),
              subtitle: Text(
                "Create an empty playlist.",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
