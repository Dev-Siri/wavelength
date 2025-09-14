import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:just_audio/just_audio.dart";
import "package:just_audio_background/just_audio_background.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/playback_stream.dart";
import "package:wavelength/api/repositories/streams_repo.dart";
import "package:wavelength/bloc/music_player/music_player_queue/music_player_queue_event.dart";
import "package:wavelength/bloc/music_player/music_player_queue/music_player_queue_state.dart";
import "package:wavelength/bloc/music_player/music_player_singleton.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/utils/temp_storage.dart";

class MusicPlayerQueueBloc
    extends Bloc<MusicPlayerQueueEvent, MusicPlayerQueueState> {
  MusicPlayerQueueBloc() : super(MusicPlayerQueueState(tracksInQueue: [])) {
    on<MusicPlayerQueueAddToQueueEvent>(_addToQueue);
    on<MusicPlayerReplaceQueueEvent>(_replaceQueue);
  }

  Future<void> _replaceQueue(
    MusicPlayerReplaceQueueEvent event,
    Emitter<MusicPlayerQueueState> emit,
  ) async {
    final player = MusicPlayerSingleton().player;

    final streamBox = await Hive.openBox(hiveStreamsKey);
    final tempStreamsStore = TempStorage(streamBox, ttl: Duration(hours: 4));

    final previousQueue = state.tracksInQueue;

    emit(MusicPlayerQueueState(tracksInQueue: event.newQueue));

    await player.clearAudioSources();

    for (final queueableMusic in event.newQueue) {
      final cacheTrackId = "v_stream-${queueableMusic.videoId}";

      try {
        final cachedStream = tempStreamsStore.get(cacheTrackId);

        PlaybackStream playbackStream;

        if (cachedStream == null) {
          final response = await StreamsRepo.fetchAudioStreamPlaybackUrl(
            videoId: queueableMusic.videoId,
          );

          if (response is ApiResponseSuccess<PlaybackStream>) {
            await tempStreamsStore.save(cacheTrackId, response.data);
            playbackStream = response.data;
          } else {
            return emit(MusicPlayerQueueState(tracksInQueue: previousQueue));
          }
        } else {
          playbackStream = cachedStream;
        }

        final totalDuration = Duration(seconds: playbackStream.duration);

        await player.addAudioSource(
          ClippingAudioSource(
            child: AudioSource.uri(Uri.parse(playbackStream.url)),
            duration: totalDuration,
            end: totalDuration,
            tag: MediaItem(
              id: queueableMusic.videoId,
              title: queueableMusic.title,
              album: queueableMusic.author,
              artUri: Uri.parse(queueableMusic.thumbnail),
            ),
          ),
        );
      } catch (_) {
        emit(MusicPlayerQueueState(tracksInQueue: previousQueue));
      }
    }
  }

  Future<void> _addToQueue(
    MusicPlayerQueueAddToQueueEvent event,
    Emitter<MusicPlayerQueueState> emit,
  ) async {
    final trackAlreadyInQueueTest = state.tracksInQueue.where(
      (track) => track.videoId == event.queueableMusic.videoId,
    );

    if (trackAlreadyInQueueTest.isNotEmpty) return;

    final player = MusicPlayerSingleton().player;

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
          return emit(
            MusicPlayerQueueState(tracksInQueue: state.tracksInQueue),
          );
        }
      } else {
        playbackStream = cachedStream;
      }

      final totalDuration = Duration(seconds: playbackStream.duration);

      player.addAudioSource(
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

      emit(
        MusicPlayerQueueState(
          tracksInQueue: [...state.tracksInQueue, event.queueableMusic],
        ),
      );
    } catch (_) {
      emit(MusicPlayerQueueState(tracksInQueue: state.tracksInQueue));
    }
  }
}
