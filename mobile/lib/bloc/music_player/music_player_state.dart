import "package:flutter/foundation.dart";

@immutable
class MusicPlayerState {
  final bool isPlaying;

  const MusicPlayerState({this.isPlaying = false});
}
