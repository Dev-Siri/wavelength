import "package:flutter/foundation.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";

@immutable
abstract class MusicPlayerQueueEvent {}

class MusicPlayerQueuePlayNextEvent extends MusicPlayerQueueEvent {
  final QueueableMusic queueableMusic;

  MusicPlayerQueuePlayNextEvent({required this.queueableMusic});
}

class MusicPlayerQueueAddToQueueEvent extends MusicPlayerQueueEvent {
  final QueueableMusic queueableMusic;

  MusicPlayerQueueAddToQueueEvent({required this.queueableMusic});
}
