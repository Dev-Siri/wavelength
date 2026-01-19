import "package:flutter/material.dart";
import "package:wavelength/api/models/artist.dart";
import "package:wavelength/widgets/artist_card.dart";

class FollowedArtistsCarousel extends StatelessWidget {
  final List<FollowedArtist> follows;
  const FollowedArtistsCarousel({super.key, required this.follows});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: CarouselView.builder(
        itemExtent: 100,
        itemCount: follows.length,
        itemBuilder: (context, index) {
          final followedArtist = follows[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ArtistCard(
              browseId: followedArtist.browseId,
              title: followedArtist.name,
              thumbnail: followedArtist.thumbnail,
            ),
          );
        },
      ),
    );
  }
}
