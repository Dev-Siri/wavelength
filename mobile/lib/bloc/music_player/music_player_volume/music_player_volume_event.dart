import "package:flutter/foundation.dart";

@immutable
abstract class MusicPlayerVolumeEvent {}

class MusicPlayerVolumeMuteEvent extends MusicPlayerVolumeEvent {}

class MusicPlayerVolumeUnmuteEvent extends MusicPlayerVolumeEvent {}
