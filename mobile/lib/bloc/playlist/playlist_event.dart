import "package:flutter/foundation.dart";

@immutable
sealed class PlaylistEvent {}

class PlaylistFetchEvent extends PlaylistEvent {
  final String playlistId;

  PlaylistFetchEvent({required this.playlistId});
}
