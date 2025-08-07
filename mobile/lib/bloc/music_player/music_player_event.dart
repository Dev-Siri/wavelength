import "package:flutter/foundation.dart";

@immutable
abstract class MusicPlayerEvent {}

class MusicPlayerPlayMusicEvent extends MusicPlayerEvent {}

class MusicPlayerPauseMusicEvent extends MusicPlayerEvent {}

class MusicPlayerStopMusicEvent extends MusicPlayerEvent {}
