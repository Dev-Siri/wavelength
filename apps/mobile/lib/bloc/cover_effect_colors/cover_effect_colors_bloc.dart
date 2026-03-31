import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_flutter/adapters.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/theme_color.dart";
import "package:wavelength/api/repositories/image_repo.dart";
import "package:wavelength/bloc/cover_effect_colors/cover_effect_colors_event.dart";
import "package:wavelength/bloc/cover_effect_colors/cover_effect_colors_state.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/utils/url.dart";

class CoverEffectColorsBloc
    extends Bloc<CoverEffectColorsEvent, CoverEffectColorsState> {
  CoverEffectColorsBloc() : super(CoverEffectColorsInitialState()) {
    on<CoverEffectColorsFetchEvent>(_coverEffectColorsFetch);
  }

  Future<void> _coverEffectColorsFetch(
    CoverEffectColorsFetchEvent event,
    Emitter<CoverEffectColorsState> emit,
  ) async {
    final box = await Hive.openBox(hiveCoverEffectColorsKey);
    final storedThemeColor = (box.get(event.thumbnail) as List?)
        ?.cast<ThemeColor>();

    if (storedThemeColor != null) {
      return emit(CoverEffectColorsSuccessState(colors: storedThemeColor));
    }

    final colorResponse = await ImageRepo.fetchImageCoverEffectColors(
      url: getUpscaledTrackThumbnail(event.thumbnail),
    );

    if (colorResponse is ApiResponseSuccess<List<ThemeColor>>) {
      box.put(event.thumbnail, colorResponse.data);
      return emit(CoverEffectColorsSuccessState(colors: colorResponse.data));
    }

    emit(CoverEffectColorsErrorState());
  }
}
