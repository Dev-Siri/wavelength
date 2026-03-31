import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wavelength/api/models/search_recommendations.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class SearchSuggestedLink extends StatelessWidget {
  final SearchRecommendationItem suggestedLink;

  const SearchSuggestedLink({super.key, required this.suggestedLink});

  void _navigateToLink(BuildContext context) {
    switch (suggestedLink.type) {
      case "album":
        context.push("/album/${suggestedLink.browseId}");
        break;
      case "artist":
        context.push("/artist/${suggestedLink.browseId}");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 26, 26, 26),
      child: AmplListTile(
        onTap: () => _navigateToLink(context),
        leading: CachedNetworkImage(
          imageUrl: suggestedLink.thumbnail,
          height: 40,
          width: 40,
          fit: BoxFit.cover,
        ),
        title: SizedBox(
          width: MediaQuery.sizeOf(context).width - 200,
          child: Text(suggestedLink.title, overflow: TextOverflow.ellipsis),
        ),
        subtitle: SizedBox(
          width: MediaQuery.sizeOf(context).width - 200,
          child: Text(
            suggestedLink.subtitle,
            style: const TextStyle(
              color: Colors.grey,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
