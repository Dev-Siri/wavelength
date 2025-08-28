import "package:flutter/foundation.dart";

@immutable
sealed class TracksEvent {}

class TracksFetchEvent extends TracksEvent {
  final String query;

  TracksFetchEvent({required this.query});
}
