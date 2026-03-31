import "package:flutter/foundation.dart";

@immutable
sealed class IsAlbumLosslessState {}

class IsAlbumLosslessInitialState extends IsAlbumLosslessState {}

class IsAlbumLosslessSuccessState extends IsAlbumLosslessState {
  final bool isLossless;

  IsAlbumLosslessSuccessState({required this.isLossless});
}
