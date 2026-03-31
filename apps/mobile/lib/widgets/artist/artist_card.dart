import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wavelength/widgets/ui/ampl_button.dart";

class ArtistCard extends StatelessWidget {
  final String browseId;
  final String title;
  final String thumbnail;

  const ArtistCard({
    super.key,
    required this.browseId,
    required this.title,
    required this.thumbnail,
  });

  @override
  Widget build(BuildContext context) {
    return AmplButton(
      height: 50,
      borderRadius: BorderRadius.circular(50),
      padding: EdgeInsets.zero,
      onPressed: () => context.push("/artist/$browseId"),
      child: Semantics(
        label: title,
        image: true,
        child: Hero(
          tag: "$browseId-artist",
          child: CircleAvatar(
            radius: 50,
            foregroundImage: CachedNetworkImageProvider(thumbnail),
          ),
        ),
      ),
    );
  }
}
