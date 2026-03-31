import "dart:convert";

import "package:audio_service/audio_service.dart";
import "package:just_audio/just_audio.dart";
import "package:wavelength/api/models/enums/video_type.dart";
import "package:wavelength/audio/queueable_music.dart";
import "package:wavelength/utils/format.dart";

MediaItem constructMediaItem(QueueableMusic queueableMusic) {
  final album = queueableMusic.album?.toJson();
  return MediaItem(
    id: queueableMusic.videoId,
    title: queueableMusic.title,
    artist: formatList(
      queueableMusic.artists.map((artist) => artist.title).toList(),
    ),
    artUri: Uri.parse(queueableMusic.thumbnail),
    duration: Duration(seconds: queueableMusic.duration),
    extras: {
      "videoType": queueableMusic.videoType.toGrpc(),
      "embedded": {
        "artists": jsonEncode(
          queueableMusic.artists.map((artist) => artist.toJson()).toList(),
        ),
        "album": album != null ? jsonEncode(album) : null,
      },
    },
  );
}

AudioProcessingState mapProcessingState(ProcessingState state) {
  switch (state) {
    case ProcessingState.idle:
      return AudioProcessingState.idle;
    case ProcessingState.loading:
      return AudioProcessingState.loading;
    case ProcessingState.buffering:
      return AudioProcessingState.buffering;
    case ProcessingState.ready:
      return AudioProcessingState.ready;
    case ProcessingState.completed:
      return AudioProcessingState.completed;
  }
}
