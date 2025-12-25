import "package:flutter/foundation.dart";

@immutable
sealed class LikeCountEvent {}

class LikeCountFetchEvent extends LikeCountEvent {
  final String authToken;

  LikeCountFetchEvent({required this.authToken});
}
