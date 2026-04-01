import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:wavelength/audio/queueable_music.dart";
import "package:wavelength/bloc/downloaded_tracks/downloaded_tracks_event.dart";
import "package:wavelength/bloc/downloaded_tracks/downloaded_tracks_state.dart";
import "package:wavelength/constants.dart";

class DownloadedTracksBloc
    extends Bloc<DownloadedTracksEvent, DownloadedTracksState> {
  DownloadedTracksBloc() : super(const DownloadedTracksState(downloads: [])) {
    on<DownloadedTracksFetchEvent>(_fetchDownloadedTracks);
  }

  Future<void> _fetchDownloadedTracks(
    DownloadedTracksFetchEvent event,
    Emitter<DownloadedTracksState> emit,
  ) async {
    final box = await Hive.openBox(hiveStreamsKey);
    final downloads = box.values.toList().cast<QueueableMusic>();

    emit(DownloadedTracksState(downloads: downloads));
  }
}
