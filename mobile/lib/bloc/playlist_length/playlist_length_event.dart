import "package:flutter/foundation.dart";

@immutable
sealed class PlaylistLengthEvent {}

class PlaylistLengthFetchEvent extends PlaylistLengthEvent {
  final String playlistId;

  PlaylistLengthFetchEvent({required this.playlistId});
}
