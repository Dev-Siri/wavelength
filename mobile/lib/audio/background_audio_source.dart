import "dart:typed_data";

import "package:http/http.dart" as http;
import "package:just_audio/just_audio.dart";
import "package:wavelength/cache.dart";
import "package:wavelength/src/rust/api/tydle_caller.dart";

class BackgroundAudioSource extends StreamAudioSource {
  final String _trackId;
  final BytesBuilder _buffer = BytesBuilder(copy: false);
  bool _didSave = false;

  String? _url;
  Uint8List? _bytesSource;

  int? _fullLength;
  BackgroundAudioSource(this._trackId, {super.tag});

  Future<void> _ensureUrl() async {
    _url ??= await fetchHighestAudioStreamUrl(videoId: _trackId);
  }

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    if (_bytesSource == null) {
      final cachedAudioStream = await AudioCache.getStream(_trackId);

      if (cachedAudioStream != null) {
        _bytesSource = await cachedAudioStream.readAsBytes();
      }
    }

    if (_bytesSource != null) {
      return StreamAudioResponse(
        sourceLength: _bytesSource!.length,
        contentLength: _bytesSource!.length,
        offset: start ?? 0,
        stream: Stream.fromIterable([_bytesSource!.sublist(start ?? 0, end)]),
        contentType: "audio/mp4",
      );
    }

    _url ??= await fetchHighestAudioStreamUrl(videoId: _trackId);

    await _ensureUrl();

    final uri = Uri.parse(_url!);

    final Map<String, String> rangeHeader = (start != null)
        ? {"Range": "bytes=$start-${end != null ? end - 1 : ""}"}
        : {};

    final req = await http.Client().send(
      http.Request("GET", uri)..headers.addAll(rangeHeader),
    );

    int? totalLength = _fullLength;

    if (totalLength == null &&
        req.headers["content-range"] != null &&
        req.headers["content-range"]!.contains("/")) {
      final parts = req.headers["content-range"]!.split("/");
      totalLength = int.tryParse(parts.last);
      _fullLength = totalLength;
    }

    final contentLength = req.contentLength ?? totalLength;

    final stream = req.stream.asyncExpand((chunk) async* {
      if (!_didSave) {
        _buffer.add(chunk);

        if (_fullLength != null && _buffer.length == _fullLength) {
          _didSave = true;

          if (await AudioCache.isAutoCachingPermitted()) {
            await AudioCache.save(_trackId, _buffer.takeBytes());
          }
        }
      }

      yield chunk;
    });

    return StreamAudioResponse(
      sourceLength: totalLength,
      contentLength: contentLength,
      offset: start ?? 0,
      contentType: req.headers["content-type"] ?? "audio/mp4",
      stream: stream,
    );
  }
}
