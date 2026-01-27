import "package:flutter/material.dart";
import "package:shimmer_animation/shimmer_animation.dart";

class ArtistTileSkeleton extends StatelessWidget {
  const ArtistTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Shimmer(child: const SizedBox(height: 80, width: 80)),
        ),
        Container(
          padding: const EdgeInsets.only(left: 10),
          width: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Shimmer(
                  child: SizedBox(
                    height: 10,
                    width: MediaQuery.sizeOf(context).width / 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Shimmer(
                  child: SizedBox(
                    height: 10,
                    width: MediaQuery.sizeOf(context).width / 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
