import "package:flutter/foundation.dart";

@immutable
sealed class AlbumEvent {
  const AlbumEvent();
}

class AlbumFetchEvent extends AlbumEvent {
  final String browseId;

  const AlbumFetchEvent({required this.browseId});
}
