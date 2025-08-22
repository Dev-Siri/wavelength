import "package:flutter/foundation.dart";

@immutable
abstract class MusicPlayerPlaystateState {}

class MusicPlayerPlaystatePlayingState extends MusicPlayerPlaystateState {}

class MusicPlayerPlaystatePausedState extends MusicPlayerPlaystateState {}
