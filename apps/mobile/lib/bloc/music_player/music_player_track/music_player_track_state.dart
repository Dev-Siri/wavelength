import "package:flutter/foundation.dart";
import "package:wavelength/audio/queueable_music.dart";
import "package:wavelength/audio/stream_resolver.dart";

@immutable
sealed class MusicPlayerTrackState {}

class MusicPlayerTrackEmptyState extends MusicPlayerTrackState {}

class MusicPlayerTrackLoadingState extends MusicPlayerTrackState {}

class MusicPlayerTrackPlayingNowState extends MusicPlayerTrackState {
  final PlayableStreamMetadata? metadata;
  final QueueableMusic playingNowTrack;

  MusicPlayerTrackPlayingNowState({
    required this.metadata,
    required this.playingNowTrack,
  });
}
