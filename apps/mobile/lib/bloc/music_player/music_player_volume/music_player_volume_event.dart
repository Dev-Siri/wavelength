import "package:flutter/foundation.dart";

@immutable
sealed class MusicPlayerVolumeEvent {}

class MusicPlayerVolumeMuteEvent extends MusicPlayerVolumeEvent {}

class MusicPlayerVolumeUnmuteEvent extends MusicPlayerVolumeEvent {}
