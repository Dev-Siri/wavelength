class ChannelThumbnail {
  final String? url;
  final int? width;
  final int? height;

  const ChannelThumbnail({
    required this.url,
    required this.width,
    required this.height,
  });
}

class ChannelThumbnailDetails {
  /// API returns "default", renamed to "normal" to avoid name clashes.
  final ChannelThumbnail normal;
  final ChannelThumbnail high;
  final ChannelThumbnail medium;

  const ChannelThumbnailDetails({
    required this.normal,
    required this.high,
    required this.medium,
  });
}

class ChannelSnippet {
  final String? country;
  final String? customUrl;
  final String? defaultLanguage;
  final String? description;
  final String? publishedAt;
  final ChannelThumbnailDetails thumbnails;
  final String? title;

  const ChannelSnippet({
    required this.country,
    required this.customUrl,
    required this.defaultLanguage,
    required this.description,
    required this.publishedAt,
    required this.thumbnails,
    required this.title,
  });
}

class Channel {
  final String? id;
  final String? kind;
  final String? etag;
  final ChannelSnippet snippet;

  const Channel({
    required this.id,
    required this.kind,
    required this.etag,
    required this.snippet,
  });
}

class ArtistExtra {
  final String? etag;
  final String? eventId;
  final List<Channel> items;
  final String? kind;
  final String? visitorId;

  const ArtistExtra({
    required this.etag,
    required this.eventId,
    required this.items,
    required this.kind,
    required this.visitorId,
  });

  factory ArtistExtra.fromJson(Map<String, dynamic> json) {
    return ArtistExtra(
      etag: json["etag"] as String?,
      eventId: json["eventId"] as String?,
      items:
          ((json["items"] as List<dynamic>?)
                  ?.map(
                    (itemJson) => Channel(
                      id: itemJson["id"] as String?,
                      kind: itemJson["kind"] as String?,
                      etag: itemJson["etag"] as String?,
                      snippet: ChannelSnippet(
                        country: itemJson["snippet"]["country"] as String?,
                        customUrl: itemJson["snippet"]["customUrl"] as String?,
                        defaultLanguage:
                            itemJson["snippet"]["defaultLanguage"] as String?,
                        description:
                            itemJson["snippet"]["description"] as String?,
                        publishedAt:
                            itemJson["snippet"]["publishedAt"] as String?,
                        title: itemJson["snippet"]["title"] as String?,
                        thumbnails: ChannelThumbnailDetails(
                          high: ChannelThumbnail(
                            url:
                                itemJson["snippet"]["thumbnails"]["high"]["url"]
                                    as String?,
                            width:
                                itemJson["snippet"]["thumbnails"]["high"]["width"]
                                    as int?,
                            height:
                                itemJson["snippet"]["thumbnails"]["high"]["height"]
                                    as int?,
                          ),
                          normal: ChannelThumbnail(
                            url:
                                itemJson["snippet"]["thumbnails"]["default"]["url"]
                                    as String?,
                            width:
                                itemJson["snippet"]["thumbnails"]["default"]["width"]
                                    as int?,
                            height:
                                itemJson["snippet"]["thumbnails"]["default"]["height"]
                                    as int?,
                          ),
                          medium: ChannelThumbnail(
                            url:
                                itemJson["snippet"]["thumbnails"]["medium"]["url"]
                                    as String?,
                            width:
                                itemJson["snippet"]["thumbnails"]["medium"]["width"]
                                    as int?,
                            height:
                                itemJson["snippet"]["thumbnails"]["medium"]["height"]
                                    as int?,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList() ??
              List.empty()),
      kind: json["kind"] as String?,
      visitorId: json["visitorId"] as String?,
    );
  }
}
