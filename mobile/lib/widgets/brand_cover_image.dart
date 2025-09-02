import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";

class BrandCoverImage extends StatelessWidget {
  final Color? shadowColor;
  final String? imageUrl;

  const BrandCoverImage({super.key, this.shadowColor, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.grey.shade900,
        ),
        height: 300,
        width: 300,
      );
    }

    return Container(
      height: 300,
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          if (shadowColor != null)
            BoxShadow(color: shadowColor!, blurRadius: 90, spreadRadius: 1),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: CachedNetworkImage(imageUrl: imageUrl ?? "", fit: BoxFit.fill),
      ),
    );
  }
}
