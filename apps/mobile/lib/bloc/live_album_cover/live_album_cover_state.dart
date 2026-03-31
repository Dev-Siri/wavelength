import "package:flutter/foundation.dart";

@immutable
sealed class LiveAlbumCoverState {}

class LiveAlbumCoverFetchInitialState extends LiveAlbumCoverState {}

class LiveAlbumCoverFetchErrorState extends LiveAlbumCoverState {}

class LiveAlbumCoverFetchSuccessState extends LiveAlbumCoverState {
  final String? liveAlbumCoverUri;

  LiveAlbumCoverFetchSuccessState({required this.liveAlbumCoverUri});
}
