import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/repositories/diagnostics_repo.dart";
import "package:wavelength/audio/wavelength_audio_handler.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";

class MusicPlayerTrackBloc
    extends Bloc<MusicPlayerTrackEvent, MusicPlayerTrackState> {
  final WavelengthAudioHandler _audioHandler;

  MusicPlayerTrackBloc(this._audioHandler)
    : super(MusicPlayerTrackEmptyState()) {
    on<MusicPlayerTrackLoadEvent>(_loadTrack);
    on<MusicPlayerTrackAutoLoadEvent>(_autoLoad);
  }

  void _autoLoad(
    MusicPlayerTrackAutoLoadEvent event,
    Emitter<MusicPlayerTrackState> emit,
  ) => emit(
    MusicPlayerTrackPlayingNowState(
      metadata: event.metadata,
      playingNowTrack: event.queueableMusic,
    ),
  );

  Future<void> _loadTrack(
    MusicPlayerTrackLoadEvent event,
    Emitter<MusicPlayerTrackState> emit,
  ) async {
    try {
      final track = event.tracks.firstWhere(
        (track) => track.videoId == event.trackId,
      );

      emit(
        MusicPlayerTrackPlayingNowState(metadata: null, playingNowTrack: track),
      );
      await _audioHandler.playQueue(
        event.context,
        event.tracks,
        track,
        sourceLabel: event.sourceLabel,
      );
    } catch (error) {
      DiagnosticsRepo.reportError(
        error: error.toString(),
        source: "MusicPlayerTrackBloc._loadTrack",
      );
      emit(MusicPlayerTrackEmptyState());
    }
  }
}
