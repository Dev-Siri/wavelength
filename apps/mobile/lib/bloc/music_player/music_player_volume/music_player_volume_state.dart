import "package:flutter/foundation.dart";

@immutable
sealed class MusicPlayerVolumeState {}

class MusicPlayerVolumeMutedState extends MusicPlayerVolumeState {}

class MusicPlayerVolumeUnmutedState extends MusicPlayerVolumeState {}
