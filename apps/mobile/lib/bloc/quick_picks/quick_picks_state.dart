import "package:flutter/material.dart";
import "package:wavelength/api/models/quick_picks_item.dart";
import "package:wavelength/api/models/track.dart";

@immutable
sealed class QuickPicksState {}

class QuickPicksDefaultState extends QuickPicksState {}

class QuickPicksLoadingState extends QuickPicksState {}

class QuickPicksErrorState extends QuickPicksState {}

class QuickPicksSuccessState extends QuickPicksState {
  final List<QuickPicksItem> quickPicks;
  final List<Track> recentlyPlayed;

  QuickPicksSuccessState({
    required this.quickPicks,
    required this.recentlyPlayed,
  });
}
