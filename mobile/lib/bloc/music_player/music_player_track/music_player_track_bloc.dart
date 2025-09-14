import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive/hive.dart";
import "package:just_audio/just_audio.dart";
import "package:just_audio_background/just_audio_background.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/playback_stream.dart";
import "package:wavelength/api/repositories/streams_repo.dart";
import "package:wavelength/bloc/music_player/music_player_singleton.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/utils/temp_storage.dart";

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

    final streamBox = await Hive.openBox(hiveStreamsKey);
    final tempStreamsStore = TempStorage(streamBox, ttl: Duration(hours: 4));
    final cacheTrackId = "v_stream-${event.queueableMusic.videoId}";

    try {
      final cachedStream = tempStreamsStore.get(cacheTrackId);

      PlaybackStream playbackStream;

      if (cachedStream == null) {
        final response = await StreamsRepo.fetchAudioStreamPlaybackUrl(
          videoId: event.queueableMusic.videoId,
        );

        if (response is ApiResponseSuccess<PlaybackStream>) {
          await tempStreamsStore.save(cacheTrackId, response.data);
          playbackStream = response.data;
        } else {
          return emit(MusicPlayerTrackEmptyState());
        }
      } else {
        playbackStream = cachedStream;
      }

      // Emit the state before further player changes
      // Which are irrelevent to the UI updates controlled by this bloc.
      emit(
        MusicPlayerTrackPlayingNowState(playingNowTrack: event.queueableMusic),
      );

      final totalDuration = Duration(seconds: playbackStream.duration);

      await player.setAudioSource(
        ClippingAudioSource(
          child: AudioSource.uri(Uri.parse(playbackStream.url)),
          duration: totalDuration,
          end: totalDuration,
          tag: MediaItem(
            id: event.queueableMusic.videoId,
            title: event.queueableMusic.title,
            album: event.queueableMusic.author,
            artUri: Uri.parse(event.queueableMusic.thumbnail),
          ),
        ),
      );

      await player.play();
    } catch (err) {
      emit(MusicPlayerTrackEmptyState());
    }
  }
}
