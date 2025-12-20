import "package:flutter_bloc/flutter_bloc.dart";
import "package:just_audio_background/just_audio_background.dart";
import "package:wavelength/api/repositories/diagnostics_repo.dart";
import "package:wavelength/audio/background_audio_source.dart";
import "package:wavelength/bloc/music_player/music_player_singleton.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";

class MusicPlayerTrackBloc
    extends Bloc<MusicPlayerTrackEvent, MusicPlayerTrackState> {
  final _musicPlayer = MusicPlayerSingleton();

  MusicPlayerTrackBloc() : super(MusicPlayerTrackEmptyState()) {
    on<MusicPlayerTrackLoadEvent>(_loadTrack);
    on<MusicPlayerTrackAutoLoadEvent>(_autoLoad);
  }

  void _autoLoad(
    MusicPlayerTrackAutoLoadEvent event,
    Emitter<MusicPlayerTrackState> emit,
  ) => emit(
    MusicPlayerTrackPlayingNowState(playingNowTrack: event.queueableMusic),
  );

  Future<void> _loadTrack(
    MusicPlayerTrackLoadEvent event,
    Emitter<MusicPlayerTrackState> emit,
  ) async {
    final player = _musicPlayer.player;

    emit(
      MusicPlayerTrackPlayingNowState(playingNowTrack: event.queueableMusic),
    );

    try {
      final queueContext = event.queueContext;

      if (queueContext != null) {
        final replacedSources = queueContext
            .map(
              (final queueableMusic) => BackgroundAudioSource(
                queueableMusic.videoId,
                tag: MediaItem(
                  id: queueableMusic.videoId,
                  title: queueableMusic.title,
                  artist: queueableMusic.author,
                  artUri: Uri.parse(queueableMusic.thumbnail),
                ),
              ),
            )
            .toList();

        await player.setAudioSources(replacedSources);
      }

      final existingTrackIndex = player.audioSources.indexWhere((track) {
        if (track is! BackgroundAudioSource) return false;

        final tag = track.tag;
        if (tag is! MediaItem) return false;

        return tag.id == event.queueableMusic.videoId;
      });

      if (existingTrackIndex == -1) {
        await player.setAudioSource(
          BackgroundAudioSource(
            event.queueableMusic.videoId,
            tag: MediaItem(
              id: event.queueableMusic.videoId,
              title: event.queueableMusic.title,
              artist: event.queueableMusic.author,
              artUri: Uri.parse(event.queueableMusic.thumbnail),
            ),
          ),
        );
      } else {
        await player.seek(Duration.zero, index: existingTrackIndex);
      }

      await player.play();
    } catch (err) {
      DiagnosticsRepo.reportError(
        error: err.toString(),
        source: "MusicPlayerTrackBloc._loadTrack",
      );
      emit(MusicPlayerTrackEmptyState());
    }
  }
}
