import "package:flutter/foundation.dart";

@immutable
sealed class MusicPlayerRepeatModeEvent {}

class MusicPlayerRepeatModeOffEvent extends MusicPlayerRepeatModeEvent {}

class MusicPlayerRepeatModeOneEvent extends MusicPlayerRepeatModeEvent {}

class MusicPlayerRepeatModeAllEvent extends MusicPlayerRepeatModeEvent {}
