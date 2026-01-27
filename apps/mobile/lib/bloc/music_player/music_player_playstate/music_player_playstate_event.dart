import "package:flutter/foundation.dart";

@immutable
sealed class MusicPlayerPlaystateEvent {}

class MusicPlayerPlaystatePlayEvent extends MusicPlayerPlaystateEvent {}

class MusicPlayerPlaystatePauseEvent extends MusicPlayerPlaystateEvent {}

class MusicPlayerPlaystateToggleEvent extends MusicPlayerPlaystateEvent {}
