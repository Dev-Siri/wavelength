import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wavelength/widgets/ui/ampl_list_tile.dart";

class AlbumTile extends StatelessWidget {
  final String browseId;
  final String title;
  final String thumbnail;
  final String releaseDate;

  const AlbumTile({
    super.key,
    required this.browseId,
    required this.title,
    required this.thumbnail,
    required this.releaseDate,
  });

  @override
  Widget build(BuildContext context) {
    return AmplListTile(
      leading: Hero(
        tag: "$browseId-album",
        child: ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(12),
          child: CachedNetworkImage(
            imageUrl: thumbnail,
            height: 100,
            fit: BoxFit.cover,
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
      padding: const EdgeInsets.all(6),
      subtitle: Text(releaseDate),
      onTap: () => context.push("/album/$browseId"),
    );
  }
}
