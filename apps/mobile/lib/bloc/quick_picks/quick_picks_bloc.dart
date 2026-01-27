import "dart:async";

import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/quick_picks_item.dart";
import "package:wavelength/api/repositories/quick_picks_repo.dart";
import "package:wavelength/bloc/quick_picks/quick_picks_event.dart";
import "package:wavelength/bloc/quick_picks/quick_picks_state.dart";

class QuickPicksBloc extends Bloc<QuickPicksEvent, QuickPicksState> {
  QuickPicksBloc() : super(QuickPicksDefaultState()) {
    on<QuickPicksFetchEvent>(_fetchQuickPicks);
  }

  Future<void> _fetchQuickPicks(
    QuickPicksFetchEvent event,
    Emitter<QuickPicksState> emit,
  ) async {
    emit(QuickPicksLoadingState());
    final response = await QuickPicksRepo.fetchQuickPicks(locale: event.locale);

    if (response is ApiResponseSuccess<List<QuickPicksItem>>) {
      return emit(QuickPicksSuccessState(quickPicks: response.data));
    }

    emit(QuickPicksErrorState());
  }
}
