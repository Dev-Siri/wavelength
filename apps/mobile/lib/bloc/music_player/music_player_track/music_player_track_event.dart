import "package:flutter/foundation.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";

@immutable
sealed class MusicPlayerTrackEvent {}

class MusicPlayerTrackAutoLoadEvent extends MusicPlayerTrackEvent {
  final QueueableMusic queueableMusic;

  MusicPlayerTrackAutoLoadEvent({required this.queueableMusic});
}

class MusicPlayerTrackLoadEvent extends MusicPlayerTrackEvent {
  final String? contextId;
  final List<QueueableMusic>? queueContext;
  final QueueableMusic queueableMusic;

  MusicPlayerTrackLoadEvent({
    required this.queueableMusic,
    this.contextId,
    this.queueContext,
  });
}
