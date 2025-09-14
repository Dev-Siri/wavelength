import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_queue/music_player_queue_event.dart";
import "package:wavelength/bloc/music_player/music_player_queue/music_player_queue_state.dart";

class MusicPlayerQueueBloc
    extends Bloc<MusicPlayerQueueEvent, MusicPlayerQueueState> {
  MusicPlayerQueueBloc() : super(MusicPlayerQueueState(tracksInQueue: [])) {
    on<MusicPlayerQueueAddToQueueEvent>(_addToQueue);
    on<MusicPlayerQueuePlayNextEvent>(_playNext);
    on<MusicPlayerReplaceQueueEvent>(_replaceQueue);
  }

  void _replaceQueue(
    MusicPlayerReplaceQueueEvent event,
    Emitter<MusicPlayerQueueState> emit,
  ) => emit(MusicPlayerQueueState(tracksInQueue: event.newQueue));

  void _addToQueue(
    MusicPlayerQueueAddToQueueEvent event,
    Emitter<MusicPlayerQueueState> emit,
  ) {
    // TODO: Use just_audio's queue and sync this queue to that.
    final trackAlreadyInQueueTest = state.tracksInQueue.where(
      (track) => track.videoId == event.queueableMusic.videoId,
    );

    if (trackAlreadyInQueueTest.isNotEmpty) return;

    emit(
      MusicPlayerQueueState(
        tracksInQueue: [...state.tracksInQueue, event.queueableMusic],
      ),
    );
  }

  void _playNext(
    MusicPlayerQueuePlayNextEvent event,
    Emitter<MusicPlayerQueueState> emit,
  ) {
    final trackAlreadyInQueueTest = state.tracksInQueue.where(
      (track) => track.videoId == event.queueableMusic.videoId,
    );

    if (trackAlreadyInQueueTest.isNotEmpty) return;

    emit(
      MusicPlayerQueueState(
        tracksInQueue: [event.queueableMusic, ...state.tracksInQueue],
      ),
    );
  }
}
