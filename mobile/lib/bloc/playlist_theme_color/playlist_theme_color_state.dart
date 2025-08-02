import "package:flutter/foundation.dart";
import "package:wavelength/api/models/playlist_theme_color.dart";

@immutable
abstract class PlaylistThemeColorState {}

class PlaylistThemeColorInitialState extends PlaylistThemeColorState {}

class PlaylistThemeColorLoadingState extends PlaylistThemeColorState {}

class PlaylistThemeColorErrorState extends PlaylistThemeColorState {}

class PlaylistThemeColorSuccessState extends PlaylistThemeColorState {
  final PlaylistThemeColor playlistThemeColor;

  PlaylistThemeColorSuccessState({required this.playlistThemeColor});
}
