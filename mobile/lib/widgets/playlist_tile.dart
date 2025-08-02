import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wavelength/api/models/playlist.dart";

class PlaylistTile extends StatelessWidget {
  final Playlist playlist;

  const PlaylistTile({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final Widget innerUi = Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          if (playlist.coverImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: playlist.coverImage!,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                playlist.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 5),
              Text(
                playlist.authorName,
                style: TextStyle(color: Colors.grey, height: 1, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );

    if (Platform.isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => context.push("/playlist/${playlist.playlistId}"),
        child: innerUi,
      );
    } else {
      return MaterialButton(
        onPressed: () => context.push("/playlist/${playlist.playlistId}"),
        child: innerUi,
      );
    }
  }
}
