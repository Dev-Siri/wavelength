import "package:flutter_bloc/flutter_bloc.dart";
import "package:just_audio/just_audio.dart";
import "package:just_audio_background/just_audio_background.dart";
import "package:wavelength/bloc/music_player/music_player_singleton.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/utils/url.dart";

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

    emit(MusicPlayerTrackLoadingState());

    try {
      await player.setAudioSource(
        AudioSource.uri(
          Uri.parse(
            getTrackPlaybackUrl(
              event.queueableMusic.videoId,
              StreamPlaybackType.audio,
            ),
          ),
          tag: MediaItem(
            id: event.queueableMusic.videoId,
            title: event.queueableMusic.title,
            album: event.queueableMusic.author,
            artUri: Uri.parse(event.queueableMusic.thumbnail),
          ),
        ),
      );

      await player.play();
      emit(
        MusicPlayerTrackPlayingNowState(playingNowTrack: event.queueableMusic),
      );
    } catch (err) {
      emit(MusicPlayerTrackEmptyState());
    }
  }
}
