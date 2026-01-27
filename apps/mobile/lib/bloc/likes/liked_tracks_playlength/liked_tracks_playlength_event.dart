import "package:flutter/foundation.dart";

@immutable
sealed class LikedTracksPlaylengthEvent {}

class LikedTracksPlaylengthFetchEvent extends LikedTracksPlaylengthEvent {
  final String authToken;

  LikedTracksPlaylengthFetchEvent({required this.authToken});
}
