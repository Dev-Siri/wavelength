class SearchRecommendationItem {
  final String thumbnail;
  final String title;
  final String subtitle;
  final String browseId;
  final bool isExplicit;
  final String type;

  SearchRecommendationItem({
    required this.thumbnail,
    required this.title,
    required this.subtitle,
    required this.browseId,
    required this.isExplicit,
    required this.type,
  });

  factory SearchRecommendationItem.fromJson(Map<String, dynamic> json) {
    return SearchRecommendationItem(
      thumbnail: json["thumbnail"] as String,
      title: json["title"] as String,
      subtitle: json["subtitle"] as String,
      browseId: json["browseId"] as String,
      isExplicit: json["isExplicit"] as bool,
      type: json["type"] as String,
    );
  }
}

class SearchRecommendations {
  final List<String> matchingQueries;
  final List<SearchRecommendationItem> matchingLinks;

  SearchRecommendations({
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
