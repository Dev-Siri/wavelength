import "package:flutter/foundation.dart";

@immutable
class VideosEvent {}

class VideosFetchEvent extends VideosEvent {
  final String query;

  VideosFetchEvent({required this.query});
}
