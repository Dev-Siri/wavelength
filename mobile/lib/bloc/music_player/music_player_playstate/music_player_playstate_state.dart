import "package:flutter/foundation.dart";

@immutable
sealed class MusicPlayerPlaystateState {}

class MusicPlayerPlaystatePlayingState extends MusicPlayerPlaystateState {}

class MusicPlayerPlaystatePausedState extends MusicPlayerPlaystateState {}
