import "package:flutter/foundation.dart";

@immutable
abstract class PlaylistEvent {}

class PlaylistFetchEvent extends PlaylistEvent {
  final String playlistId;

  PlaylistFetchEvent({required this.playlistId});
}
