import "package:flutter/foundation.dart";

@immutable
sealed class MusicPlayerRepeatModeEvent {}

class MusicPlayerRepeatModeChangeRepeatModeEvent
    extends MusicPlayerRepeatModeEvent {}
