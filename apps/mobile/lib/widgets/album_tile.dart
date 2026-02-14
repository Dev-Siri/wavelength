import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wavelength/api/models/enums/album_type.dart";
import "package:wavelength/widgets/ui/ampl_list_tile.dart";

class AlbumTile extends StatelessWidget {
  final String browseId;
  final String title;
  final String thumbnail;
  final String releaseDate;
  final AlbumType albumType;

  const AlbumTile({
    super.key,
    required this.browseId,
    required this.title,
    required this.thumbnail,
    required this.releaseDate,
    required this.albumType,
  });

  @override
  Widget build(BuildContext context) {
    return AmplListTile(
      leading: Hero(
        tag: "$browseId-album",
        child: ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(12),
          child: AspectRatio(
            aspectRatio: 1,
            child: CachedNetworkImage(imageUrl: thumbnail, fit: BoxFit.cover),
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      leadingSize: 50,
      padding: Platform.isAndroid
          ? const EdgeInsets.symmetric(horizontal: 6)
          : const EdgeInsets.all(6),
      subtitle: Text(
        "$releaseDate • ${albumType.toFormatted()}",
        style: const TextStyle(color: Colors.grey),
      ),
      onTap: () => context.push("/album/$browseId"),
    );
  }
}
