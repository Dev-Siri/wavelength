import "package:flutter/foundation.dart";

@immutable
abstract class MusicPlayerDurationEvent {}

class MusicPlayerDurationSeekToEvent extends MusicPlayerDurationEvent {
  final Duration totalDuration;
  final Duration newDuration;

  MusicPlayerDurationSeekToEvent({
    required this.totalDuration,
    required this.newDuration,
  });
}

class MusicPlayerDurationUpdateDurationEvent extends MusicPlayerDurationEvent {
  final Duration totalDuration;
  final Duration newDuration;

  MusicPlayerDurationUpdateDurationEvent({
    required this.totalDuration,
    required this.newDuration,
  });
}
