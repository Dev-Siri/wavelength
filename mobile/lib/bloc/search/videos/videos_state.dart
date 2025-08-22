import "package:flutter/foundation.dart";
import "package:wavelength/api/models/video.dart";

@immutable
abstract class VideosState {}

class VideosDefaultState extends VideosState {}

class VideosFetchLoadingState extends VideosState {}

class VideosFetchErrorState extends VideosState {}

class VideosFetchSuccessState extends VideosState {
  final List<Video> videos;

  VideosFetchSuccessState({required this.videos});
}
