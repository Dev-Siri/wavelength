import "package:flutter/foundation.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";

@immutable
abstract class MusicPlayerTrackState {}

class MusicPlayerTrackEmptyState extends MusicPlayerTrackState {}

class MusicPlayerTrackPlayingNowState extends MusicPlayerTrackState {
  final QueueableMusic playingNowTrack;

  MusicPlayerTrackPlayingNowState({required this.playingNowTrack});
}
