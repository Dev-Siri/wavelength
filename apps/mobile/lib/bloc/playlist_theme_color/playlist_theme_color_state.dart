import "package:flutter/foundation.dart";
import "package:wavelength/api/models/theme_color.dart";

@immutable
sealed class PlaylistThemeColorState {}

class PlaylistThemeColorInitialState extends PlaylistThemeColorState {}

class PlaylistThemeColorLoadingState extends PlaylistThemeColorState {}

class PlaylistThemeColorErrorState extends PlaylistThemeColorState {}

class PlaylistThemeColorSuccessState extends PlaylistThemeColorState {
  final ThemeColor playlistThemeColor;

  PlaylistThemeColorSuccessState({required this.playlistThemeColor});
}
