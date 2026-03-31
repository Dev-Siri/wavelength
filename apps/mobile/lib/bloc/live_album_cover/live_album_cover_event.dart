import "package:flutter/foundation.dart";

@immutable
sealed class LiveAlbumCoverEvent {}

class LiveAlbumCoverFetchEvent extends LiveAlbumCoverEvent {
  final String videoId;
  final String albumId;

  LiveAlbumCoverFetchEvent({required this.albumId, required this.videoId});
}
