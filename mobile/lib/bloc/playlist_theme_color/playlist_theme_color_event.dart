import "package:flutter/foundation.dart";

@immutable
abstract class PlaylistThemeColorEvent {}

class PlaylistThemeColorFetchEvent extends PlaylistThemeColorEvent {
  final String playlistId;
  final String playlistImageUrl;

  PlaylistThemeColorFetchEvent({
    required this.playlistId,
    required this.playlistImageUrl,
  });
}
