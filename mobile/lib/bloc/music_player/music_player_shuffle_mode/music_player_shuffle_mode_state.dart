import "package:flutter/foundation.dart";

@immutable
sealed class MusicPlayerShuffleModeState {}

class MusicPlayerShuffleModeShuffleOffState
    extends MusicPlayerShuffleModeState {}

class MusicPlayerShuffleModeShuffleAllState
    extends MusicPlayerShuffleModeState {}
