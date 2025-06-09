import "package:flutter/foundation.dart";

@immutable
class ArtistsEvent {}

class ArtistsFetchEvent extends ArtistsEvent {
  final String query;

  ArtistsFetchEvent({required this.query});
}
