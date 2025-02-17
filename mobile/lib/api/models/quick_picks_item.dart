class QuickPicksItem {
  final String videoId;
  final String title;
  final String thumbnail;
  final String author;

  const QuickPicksItem({
    required this.videoId,
    required this.title,
    required this.thumbnail,
    required this.author,
  });

  factory QuickPicksItem.fromJson(Map<String, dynamic> json) {
    return QuickPicksItem(
      videoId: json["videoId"] as String,
      title: json["title"] as String,
      thumbnail: json["thumbnail"] as String,
      author: json["author"] as String,
    );
  }
}
