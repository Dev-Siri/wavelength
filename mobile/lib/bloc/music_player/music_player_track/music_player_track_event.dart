import "package:flutter/foundation.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";

@immutable
abstract class MusicPlayerTrackEvent {}

class MusicPlayerTrackLoadEvent extends MusicPlayerTrackEvent {
  final QueueableMusic queueableMusic;

  MusicPlayerTrackLoadEvent({required this.queueableMusic});
}
