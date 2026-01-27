import "package:flutter/foundation.dart";

@immutable
sealed class MusicPlayerRepeatModeState {}

class MusicPlayerRepeatModeRepeatOffState extends MusicPlayerRepeatModeState {}

class MusicPlayerRepeatModeRepeatAllState extends MusicPlayerRepeatModeState {}

class MusicPlayerRepeatModeRepeatOneState extends MusicPlayerRepeatModeState {}
