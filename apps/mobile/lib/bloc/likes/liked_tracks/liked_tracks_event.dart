import "package:flutter/foundation.dart";

@immutable
sealed class LikedTracksEvent {}

class LikedTracksFetchEvent extends LikedTracksEvent {
  final String authToken;
  final String email;

  LikedTracksFetchEvent({required this.authToken, required this.email});
}
