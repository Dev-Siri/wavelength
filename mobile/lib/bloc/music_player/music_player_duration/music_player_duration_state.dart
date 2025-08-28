import "package:flutter/foundation.dart";

@immutable
sealed class MusicPlayerDurationState {}

class MusicPlayerDurationUnavailableState extends MusicPlayerDurationState {}

class MusicPlayerDurationAvailableState extends MusicPlayerDurationState {
  final Duration totalDuration;
  final Duration currentDuration;

  MusicPlayerDurationAvailableState({
    required this.totalDuration,
    required this.currentDuration,
  });
}
