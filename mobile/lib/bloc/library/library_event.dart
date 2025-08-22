import "package:flutter/foundation.dart";

@immutable
abstract class LibraryEvent {}

class LibraryPlaylistsFetchEvent extends LibraryEvent {
  final String email;

  LibraryPlaylistsFetchEvent({required this.email});
}
