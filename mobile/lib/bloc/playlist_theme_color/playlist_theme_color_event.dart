import "package:flutter/foundation.dart";

@immutable
sealed class PlaylistThemeColorEvent {}

class PlaylistThemeColorFetchEvent extends PlaylistThemeColorEvent {
  final String playlistImageUrl;

  PlaylistThemeColorFetchEvent({required this.playlistImageUrl});
}
