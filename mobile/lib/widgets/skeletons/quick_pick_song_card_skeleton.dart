import "package:flutter/material.dart";
import "package:shimmer_animation/shimmer_animation.dart";

class QuickPickSongCardSkeleton extends StatelessWidget {
  const QuickPickSongCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: Colors.grey.shade900,
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: Shimmer(
              color: Colors.grey.shade400,
              child: SizedBox(
                height: 130,
                width: MediaQuery.sizeOf(context).width / 2.8,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: Shimmer(
              child: SizedBox(
                height: 20,
                width: MediaQuery.sizeOf(context).width / 2.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
