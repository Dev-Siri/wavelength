import "dart:typed_data";

import "package:flutter_bloc/flutter_bloc.dart";
import "package:just_audio/just_audio.dart";
import "package:just_audio_background/just_audio_background.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/repositories/streams_repo.dart";
import "package:wavelength/bloc/music_player/music_player_singleton.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/audio/bytes_audio_source.dart";
import "package:wavelength/cache.dart";

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
      final cachedQueueableMusic = await AudioCache.get(
        event.queueableMusic.videoId,
      );

      if (cachedQueueableMusic != null) {
        await player.setAudioSource(
          AudioSource.file(
            cachedQueueableMusic,
            tag: MediaItem(
              id: event.queueableMusic.videoId,
              title: event.queueableMusic.title,
              album: event.queueableMusic.author,
              artUri: Uri.parse(event.queueableMusic.thumbnail),
            ),
          ),
        );
      } else {
        final stream = await StreamsRepo.fetchTrackStream(
          videoId: event.queueableMusic.videoId,
        );

        if (stream is ApiResponseSuccess<Uint8List>) {
          await player.setAudioSource(
            BytesAudioSource(
              stream.data,
              tag: MediaItem(
                id: event.queueableMusic.videoId,
                title: event.queueableMusic.title,
                album: event.queueableMusic.author,
                artUri: Uri.parse(event.queueableMusic.thumbnail),
              ),
            ),
          );

          if (await AudioCache.isAutoCachingPermitted()) {
            await AudioCache.save(event.queueableMusic.videoId, stream.data);
          }
        }
      }

      await player.play();
      emit(
        MusicPlayerTrackPlayingNowState(playingNowTrack: event.queueableMusic),
      );
    } catch (err) {
      emit(MusicPlayerTrackEmptyState());
    }
  }
}
