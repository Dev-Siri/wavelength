import "package:flutter/foundation.dart";

@immutable
class SearchRecommendationItem {
  final String thumbnail;
  final String title;
  final String subtitle;
  final String browseId;
  final String type;

  const SearchRecommendationItem({
    required this.thumbnail,
    required this.title,
    required this.subtitle,
    required this.browseId,
    required this.type,
  });

  factory SearchRecommendationItem.fromJson(Map<String, dynamic> json) {
    return SearchRecommendationItem(
      thumbnail: json["thumbnail"] as String,
      title: json["title"] as String,
      subtitle: json["subtitle"] as String,
      browseId: json["browseId"] as String,
      type: json["type"] as String,
    );
  }
}

@immutable
class SearchRecommendations {
  final List<String> matchingQueries;
  final List<SearchRecommendationItem> matchingLinks;

  const SearchRecommendations({
    required this.matchingQueries,
    required this.matchingLinks,
  });

  factory SearchRecommendations.fromJson(Map<String, dynamic> json) {
    return SearchRecommendations(
      matchingQueries: (json["matchingQueries"] as List)
          .map((final query) => query as String)
          .toList(),
      matchingLinks: (json["matchingLinks"] as List)
          .map((final item) => SearchRecommendationItem.fromJson(item))
          .toList(),
    );
  }
}
