class VideoId {
  final String kind;
  final String videoId;

  const VideoId({required this.kind, required this.videoId});
}

class VideoThumbnail {
  final String? url;
  final int? width;
  final int? height;

  const VideoThumbnail({
    required this.url,
    required this.width,
    required this.height,
  });
}

class VideoThumbnailTypes {
  /// API returns "default", renamed to "normal" to avoid name clashes.
  final VideoThumbnail normal;
  final VideoThumbnail medium;
  final VideoThumbnail high;

  const VideoThumbnailTypes({
    required this.normal,
    required this.medium,
    required this.high,
  });
}

class VideoSnippet {
  final String? publishedAt;
  final String? channelId;
  final String? title;
  final String? description;
  final VideoThumbnailTypes thumbnails;
  final String? channelTitle;
  final String? liveBroadcastContent;
  final String? publishTime;

  const VideoSnippet({
    required this.publishedAt,
    required this.channelId,
    required this.title,
    required this.description,
    required this.thumbnails,
    required this.channelTitle,
    required this.liveBroadcastContent,
    required this.publishTime,
  });
}

class Video {
  final String? kind;
  final String? etag;
  final VideoId id;
  final VideoSnippet snippet;

  const Video({
    required this.kind,
    required this.etag,
    required this.id,
    required this.snippet,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      kind: json["kind"] as String?,
      etag: json["etag"] as String?,
      id: VideoId(kind: json["id"]["kind"], videoId: json["id"]["videoId"]),
      snippet: VideoSnippet(
        publishedAt: json["snippet"]["publishedAt"] as String?,
        channelId: json["snippet"]["channelId"] as String?,
        title: json["snippet"]["title"] as String?,
        description: json["snippet"]["description"] as String?,
        thumbnails: VideoThumbnailTypes(
          normal: VideoThumbnail(
            url: json["snippet"]["thumbnails"]["default"]["url"] as String?,
            width: json["snippet"]["thumbnails"]["default"]["width"] as int?,
            height: json["snippet"]["thumbnails"]["default"]["height"] as int?,
          ),
          medium: VideoThumbnail(
            url: json["snippet"]["thumbnails"]["medium"]["url"] as String?,
            width: json["snippet"]["thumbnails"]["medium"]["width"] as int?,
            height: json["snippet"]["thumbnails"]["medium"]["height"] as int?,
          ),
          high: VideoThumbnail(
            url: json["snippet"]["thumbnails"]["high"]["url"] as String?,
            width: json["snippet"]["thumbnails"]["high"]["width"] as int?,
            height: json["snippet"]["thumbnails"]["high"]["height"] as int?,
          ),
        ),
        channelTitle: json["snippet"]["channelTitle"] as String?,
        liveBroadcastContent:
            json["snippet"]["liveBroadcastContent"] as String?,
        publishTime: json["snippet"]["publishTime"] as String?,
      ),
    );
  }
}
