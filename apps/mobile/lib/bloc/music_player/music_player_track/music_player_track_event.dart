import "package:flutter/foundation.dart";
import "package:wavelength/audio/music_context_queue.dart";
import "package:wavelength/audio/queueable_music.dart";
import "package:wavelength/audio/stream_resolver.dart";

@immutable
sealed class MusicPlayerTrackEvent {}

class MusicPlayerTrackAutoLoadEvent extends MusicPlayerTrackEvent {
  final QueueableMusic queueableMusic;
  final PlayableStreamMetadata? metadata;

  MusicPlayerTrackAutoLoadEvent({
    required this.queueableMusic,
    required this.metadata,
  });
}

class MusicPlayerTrackLoadEvent extends MusicPlayerTrackEvent {
  final MusicContextType context;
  final List<QueueableMusic> tracks;
  final String trackId;
  final String? sourceLabel;

  MusicPlayerTrackLoadEvent({
    required this.context,
    required this.tracks,
    required this.trackId,
    required this.sourceLabel,
  });
}
