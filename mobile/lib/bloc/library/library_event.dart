import "package:flutter/foundation.dart";

@immutable
sealed class LibraryEvent {}

class LibraryFetchEvent extends LibraryEvent {
  final String email;
  final String authToken;

  LibraryFetchEvent({required this.email, required this.authToken});
}
