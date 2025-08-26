import "package:flutter/foundation.dart";
import "package:wavelength/api/models/representations/queueable_music.dart";

@immutable
class MusicPlayerQueueState {
  final List<QueueableMusic> tracksInQueue;

  const MusicPlayerQueueState({required this.tracksInQueue});
}
