import "package:flutter/foundation.dart";

@immutable
sealed class PublicPlaylistsEvent {}

class PublicPlaylistsFetchEvent extends PublicPlaylistsEvent {
  final String? query;

  PublicPlaylistsFetchEvent({this.query});
}
