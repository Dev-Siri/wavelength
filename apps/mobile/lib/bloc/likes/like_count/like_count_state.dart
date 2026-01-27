import "package:flutter/foundation.dart";

@immutable
sealed class LikeCountState {}

class LikeCountInitialState extends LikeCountState {}

class LikeCountLoadingState extends LikeCountState {}

class LikeCountFetchSuccessState extends LikeCountState {
  final int likeCount;

  LikeCountFetchSuccessState({required this.likeCount});
}

class LikeCountFetchErrorState extends LikeCountState {}
