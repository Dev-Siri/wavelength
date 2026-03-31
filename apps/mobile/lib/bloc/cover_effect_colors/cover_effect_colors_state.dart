import "package:flutter/foundation.dart";
import "package:wavelength/api/models/theme_color.dart";

@immutable
sealed class CoverEffectColorsState {}

class CoverEffectColorsInitialState extends CoverEffectColorsState {}

class CoverEffectColorsErrorState extends CoverEffectColorsState {}

class CoverEffectColorsSuccessState extends CoverEffectColorsState {
  final List<ThemeColor> colors;

  CoverEffectColorsSuccessState({required this.colors});
}
