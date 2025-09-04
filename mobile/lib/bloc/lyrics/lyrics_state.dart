import "package:flutter/foundation.dart";
import "package:wavelength/api/models/lyric.dart";

@immutable
abstract class LyricsState {}

class LyricsInitialState extends LyricsState {}

class LyricsFetchLoadingState extends LyricsState {}

class LyricsFetchErrorState extends LyricsState {}

class LyricsFetchSuccessState extends LyricsState {
  final List<Lyric> lyrics;

  LyricsFetchSuccessState({required this.lyrics});
}
