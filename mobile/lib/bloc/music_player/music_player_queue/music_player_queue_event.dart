import "package:flutter/foundation.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";

@immutable
sealed class MusicPlayerQueueEvent {}

class MusicPlayerReplaceQueueEvent extends MusicPlayerQueueEvent {
  final List<QueueableMusic> newQueue;

  MusicPlayerReplaceQueueEvent({required this.newQueue});
}

class MusicPlayerQueueAddToQueueEvent extends MusicPlayerQueueEvent {
  final QueueableMusic queueableMusic;

  MusicPlayerQueueAddToQueueEvent({required this.queueableMusic});
}
