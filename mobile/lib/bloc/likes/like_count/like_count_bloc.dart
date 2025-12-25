import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:wavelength/api/models/api_response.dart';
import 'package:wavelength/api/repositories/track_repo.dart';
import 'package:wavelength/bloc/likes/like_count/like_count_event.dart';
import 'package:wavelength/bloc/likes/like_count/like_count_state.dart';
import 'package:wavelength/constants.dart';

class LikeCountBloc extends Bloc<LikeCountEvent, LikeCountState> {
  LikeCountBloc() : super(LikeCountInitialState()) {
    on<LikeCountFetchEvent>(_fetchLikeCount);
  }

  Future<void> _fetchLikeCount(
    LikeCountFetchEvent event,
    Emitter<LikeCountState> emit,
  ) async {
    emit(LikeCountLoadingState());

    final connectivityResult = await Connectivity().checkConnectivity();

    final box = await Hive.openBox(hiveLikeCountKey);

    final cachedLikeCount = box.get(hiveLikeCountKey) as int?;

    if (cachedLikeCount != null) {
      emit(LikeCountFetchSuccessState(likeCount: cachedLikeCount));
    } else if (connectivityResult.contains(ConnectivityResult.none)) {
      return emit(LikeCountFetchErrorState());
    }

    if (connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.mobile)) {
      final response = await TrackRepo.fetchTrackLikeCount(
        authToken: event.authToken,
      );

      if (response is ApiResponseSuccess<int>) {
        await box.put(hiveLikeCountKey, response.data);

        return emit(LikeCountFetchSuccessState(likeCount: response.data));
      }
    }

    emit(LikeCountFetchErrorState());
  }
}
