import "package:flutter/foundation.dart";

@immutable
sealed class MusicPlayerShuffleModeEvent {}

class MusicPlayerShuffleModeOffEvent extends MusicPlayerShuffleModeEvent {}

class MusicPlayerShuffleModeAllEvent extends MusicPlayerShuffleModeEvent {}
