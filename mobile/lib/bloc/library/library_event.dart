import "package:flutter/foundation.dart";

@immutable
sealed class LibraryEvent {}

class LibraryPlaylistsFetchEvent extends LibraryEvent {
  final String email;
  final String authToken;

  LibraryPlaylistsFetchEvent({required this.email, required this.authToken});
}
