import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wavelength/api/models/enums/album_type.dart";

class AlbumCard extends StatelessWidget {
  final String browseId;
  final String title;
  final String cover;
  final AlbumType albumType;

  const AlbumCard({
    super.key,
    required this.browseId,
    required this.title,
    required this.cover,
    required this.albumType,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push("/album/$browseId"),
      child: Stack(
        children: [
          Hero(
            tag: "$browseId-album",
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(imageUrl: cover, fit: BoxFit.cover),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withAlpha(179), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(153), // 60% opacity
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                albumType.toFormatted(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
