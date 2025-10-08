import "package:flutter/material.dart";
import "package:shimmer_animation/shimmer_animation.dart";

class PlaylistTileSkeleton extends StatelessWidget {
  const PlaylistTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Shimmer(child: const SizedBox(height: 50, width: 50)),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Shimmer(child: const SizedBox(height: 15, width: 200)),
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Shimmer(child: const SizedBox(height: 15, width: 100)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
