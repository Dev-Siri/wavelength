import "package:flutter/foundation.dart";

@immutable
sealed class RecommendedSongsEvent {}

class RecommendedSongsFetchEvent extends RecommendedSongsEvent {
  final String playlistId;

  RecommendedSongsFetchEvent({required this.playlistId});
}
