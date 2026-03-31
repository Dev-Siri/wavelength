import "package:flutter/foundation.dart";

@immutable
sealed class IsAlbumLosslessEvent {}

class IsAlbumLosslessFetchEvent extends IsAlbumLosslessEvent {
  final String albumId;

  IsAlbumLosslessFetchEvent({required this.albumId});
}
