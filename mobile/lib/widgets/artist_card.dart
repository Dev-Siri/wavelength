import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:wavelength/api/models/artist.dart";

class ArtistCard extends StatelessWidget {
  final Artist artist;

  const ArtistCard({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => 1,
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            foregroundImage: CachedNetworkImageProvider(artist.thumbnail),
          ),
          Container(
            padding: EdgeInsets.only(left: 10),
            width: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist.title,
                  style: TextStyle(
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  artist.subscriberText,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
