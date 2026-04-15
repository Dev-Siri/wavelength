import "dart:async";

import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/quick_picks_item.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/api/repositories/quick_picks_repo.dart";
import "package:wavelength/api/repositories/track_repo.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/quick_picks/quick_picks_event.dart";
import "package:wavelength/bloc/quick_picks/quick_picks_state.dart";

class QuickPicksBloc extends Bloc<QuickPicksEvent, QuickPicksState> {
  final FlutterSecureStorage _secureStorage;

  QuickPicksBloc(this._secureStorage) : super(QuickPicksDefaultState()) {
    on<QuickPicksFetchEvent>(_fetchQuickPicks);
  }

  Future<void> _fetchQuickPicks(
    QuickPicksFetchEvent event,
    Emitter<QuickPicksState> emit,
  ) async {
    emit(QuickPicksLoadingState());
    final quickPicks = await QuickPicksRepo.fetchQuickPicks(
      locale: event.locale,
    );

    if (quickPicks is ApiResponseSuccess<List<QuickPicksItem>>) {
      emit(
        QuickPicksSuccessState(
          quickPicks: quickPicks.data,
          recentlyPlayed: state is QuickPicksSuccessState
              ? (state as QuickPicksSuccessState).recentlyPlayed
              : [],
        ),
      );
    } else {
      emit(QuickPicksErrorState());
    }

    final authToken = await _secureStorage.read(key: AuthBloc.authTokenKey);

    if (authToken == null) return;
    final recentlyPlayed = await TrackRepo.fetchRecentlyPlayedTracks(
      authToken: authToken,
    );

    if (recentlyPlayed is ApiResponseSuccess<List<Track>>) {
      return emit(
        QuickPicksSuccessState(
          quickPicks: state is QuickPicksSuccessState
              ? (state as QuickPicksSuccessState).quickPicks
              : [],
          recentlyPlayed: recentlyPlayed.data,
        ),
      );
    }
  }
}
