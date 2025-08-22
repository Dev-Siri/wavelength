import "package:flutter/foundation.dart";

@immutable
abstract class ArtistsEvent {}

class ArtistsFetchEvent extends ArtistsEvent {
  final String query;

  ArtistsFetchEvent({required this.query});
}
