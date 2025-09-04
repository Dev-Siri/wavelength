import "package:flutter/foundation.dart";

@immutable
sealed class LyricsEvent {}

class LyricsFetchEvent extends LyricsEvent {
  final String trackId;

  LyricsFetchEvent({required this.trackId});
}
