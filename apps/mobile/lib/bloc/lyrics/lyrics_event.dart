import "package:flutter/foundation.dart";

@immutable
sealed class LyricsEvent {}

class LyricsFetchEvent extends LyricsEvent {
  final String title;
  final String artist;
  final String trackId;

  LyricsFetchEvent({
    required this.title,
    required this.artist,
    required this.trackId,
  });
}
