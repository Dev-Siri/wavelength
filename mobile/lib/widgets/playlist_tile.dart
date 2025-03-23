import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:wavelength/api/models/playlist.dart";

class PlaylistTile extends StatelessWidget {
  final Playlist playlist;

  const PlaylistTile({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              Text(
                playlist.authorName,
                style: TextStyle(color: Colors.grey, height: 1, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
