import "package:flutter/foundation.dart";

@immutable
abstract class MusicPlayerVolumeState {}

class MusicPlayerVolumeMutedState extends MusicPlayerVolumeState {}

class MusicPlayerVolumeUnmutedState extends MusicPlayerVolumeState {}
