import "package:flutter/foundation.dart";

@immutable
abstract class PublicPlaylistsEvent {}

class PublicPlaylistsFetchEvent extends PublicPlaylistsEvent {
  final String? query;

  PublicPlaylistsFetchEvent({this.query});
}
