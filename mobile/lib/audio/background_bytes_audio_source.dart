import "dart:typed_data";
import "package:just_audio/just_audio.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/repositories/streams_repo.dart";
import "package:wavelength/cache.dart";

class BackgroundBytesAudioSource extends StreamAudioSource {
  final String trackId;

  BackgroundBytesAudioSource(this.trackId, {super.tag});

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final stream = await AudioCache.getStream(trackId);
    Uint8List buffer;

    if (stream != null) {
      buffer = await stream.readAsBytes();
    } else {
      final stream = await StreamsRepo.fetchTrackStream(videoId: trackId);

      if (stream is! ApiResponseSuccess<Uint8List>) throw stream;

      buffer = stream.data;

      if (await AudioCache.isAutoCachingPermitted()) {
        await AudioCache.save(trackId, stream.data);
      }
    }

    return StreamAudioResponse(
      sourceLength: buffer.length,
      contentLength: (end ?? buffer.length) - (start ?? 0),
      offset: start ?? 0,
      stream: Stream.fromIterable([buffer.sublist(start ?? 0, end)]),
      contentType: "audio/mp4",
    );
  }
}
