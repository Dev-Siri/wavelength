import "package:flutter/foundation.dart";

@immutable
sealed class AlbumsEvent {}

class AlbumsFetchEvent extends AlbumsEvent {
  final String query;

  AlbumsFetchEvent({required this.query});
}
