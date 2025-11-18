import "package:flutter_bloc/flutter_bloc.dart";
import "package:just_audio_background/just_audio_background.dart";
import "package:wavelength/audio/background_audio_source.dart";
import "package:wavelength/bloc/music_player/music_player_queue/music_player_queue_event.dart";
import "package:wavelength/bloc/music_player/music_player_queue/music_player_queue_state.dart";
import "package:wavelength/bloc/music_player/music_player_singleton.dart";

class MusicPlayerQueueBloc
    extends Bloc<MusicPlayerQueueEvent, MusicPlayerQueueState> {
  MusicPlayerQueueBloc()
    : super(const MusicPlayerQueueState(tracksInQueue: [])) {
    on<MusicPlayerQueueAddToQueueEvent>(_addToQueue);
    on<MusicPlayerReplaceQueueEvent>(_replaceQueue);
  }

  Future<void> _replaceQueue(
    MusicPlayerReplaceQueueEvent event,
    Emitter<MusicPlayerQueueState> emit,
  ) async {
    final player = MusicPlayerSingleton().player;

    emit(MusicPlayerQueueState(tracksInQueue: event.newQueue));

    await player.clearAudioSources();

    for (final queueableMusic in event.newQueue) {
      await player.addAudioSource(
        BackgroundAudioSource(
          queueableMusic.videoId,
          tag: MediaItem(
            id: queueableMusic.videoId,
            title: queueableMusic.title,
            album: queueableMusic.author,
            artUri: Uri.parse(queueableMusic.thumbnail),
          ),
        ),
      );
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

    player.addAudioSource(
      BackgroundAudioSource(
        event.queueableMusic.videoId,
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
  }
}
