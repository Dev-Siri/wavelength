import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:wavelength/bloc/music_player/music_player_singleton.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_event.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/utils/temp_storage.dart";
import "package:youtube_explode_dart/youtube_explode_dart.dart";
import "package:just_audio/just_audio.dart";
import "package:just_audio_background/just_audio_background.dart";

class MusicPlayerTrackBloc
    extends Bloc<MusicPlayerTrackEvent, MusicPlayerTrackState> {
  final _musicPlayer = MusicPlayerSingleton();

  MusicPlayerTrackBloc() : super(MusicPlayerTrackEmptyState()) {
    on<MusicPlayerTrackLoadEvent>(_loadTrack);
  }

  Future<void> _loadTrack(
    MusicPlayerTrackLoadEvent event,
    Emitter<MusicPlayerTrackState> emit,
  ) async {
    final yt = _musicPlayer.yt;
    final player = _musicPlayer.player;

    emit(MusicPlayerTrackLoadingState());

    final streamBox = await Hive.openBox(hiveStreamsKey);
    final tempStreamsStore = TempStorage(streamBox, ttl: Duration(hours: 4));
    final cacheTrackId = "v_stream-${event.queueableMusic.videoId}";

    try {
      final cachedStreamUrl = tempStreamsStore.get(cacheTrackId);

      String url;

      if (cachedStreamUrl == null) {
        final manifest = await yt.videos.streamsClient.getManifest(
          event.queueableMusic.videoId,
        );

        final audioStreamInfo = manifest.audioOnly
            .where((s) => s.container == StreamContainer.mp4)
            .withHighestBitrate();
        final audioStreamUrl = audioStreamInfo.url.toString();

        await tempStreamsStore.save(cacheTrackId, audioStreamUrl);
        url = audioStreamUrl;
      } else {
        url = cachedStreamUrl;
      }

      // Emit the state before further player changes
      // Which are irrelevent to the UI updates controlled by this bloc.
      emit(
        MusicPlayerTrackPlayingNowState(playingNowTrack: event.queueableMusic),
      );

      await player.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
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
