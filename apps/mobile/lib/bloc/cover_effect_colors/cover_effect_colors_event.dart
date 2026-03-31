import "package:flutter/foundation.dart";

@immutable
sealed class CoverEffectColorsEvent {}

class CoverEffectColorsFetchEvent extends CoverEffectColorsEvent {
  final String thumbnail;

  CoverEffectColorsFetchEvent({required this.thumbnail});
}
