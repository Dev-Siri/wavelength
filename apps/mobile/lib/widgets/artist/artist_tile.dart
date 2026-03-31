import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wavelength/widgets/ui/ampl_button.dart";

class ArtistTile extends StatelessWidget {
  final String browseId;
  final String title;
  final String thumbnail;
  final String? subtitle;

  const ArtistTile({
    super.key,
    required this.browseId,
    required this.title,
    required this.thumbnail,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AmplButton(
      padding: Platform.isAndroid ? const EdgeInsets.all(5) : EdgeInsets.zero,
      onPressed: () => context.push("/artist/$browseId"),
      child: Row(
        children: [
          Hero(
            tag: "$browseId-artist",
            child: CircleAvatar(
              radius: 40,
              foregroundImage: CachedNetworkImageProvider(thumbnail),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 10),
            width: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle ?? "",
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
