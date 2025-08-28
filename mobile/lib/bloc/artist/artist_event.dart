import "package:flutter/foundation.dart";

@immutable
sealed class ArtistEvent {}

class ArtistFetchEvent extends ArtistEvent {
  final String browseId;

  ArtistFetchEvent({required this.browseId});
}
