import "package:flutter/foundation.dart";

@immutable
sealed class LibraryEvent {}

class LibraryPlaylistsFetchEvent extends LibraryEvent {
  final String email;

  LibraryPlaylistsFetchEvent({required this.email});
}
