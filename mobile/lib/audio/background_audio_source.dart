import "dart:typed_data";

import "package:hive_flutter/hive_flutter.dart";
import "package:http/http.dart" as http;
import "package:just_audio/just_audio.dart";
import "package:wavelength/cache.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/src/rust/api/tydle_caller.dart";
import "package:wavelength/utils/ttl_store.dart";

class BackgroundAudioSource extends StreamAudioSource {
  final String _trackId;
  String? _url;
  Uint8List? _bytesSource;

  int? _fullLength;
  BackgroundAudioSource(this._trackId, {super.tag});

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

    final urlCacheBox = await Hive.openBox(hiveTempUrlKey);
    final urlCacheStore = TtlStorage(
      urlCacheBox,
      ttl: const Duration(hours: ytStreamUrlSignValidityHours),
    );

    final String? cachedUrl = await urlCacheStore.get(_trackId);

    if (cachedUrl != null) {
      _url ??= cachedUrl;
    } else {
      _url ??= await fetchHighestAudioStreamUrl(videoId: _trackId);
      urlCacheStore.save(hiveTempUrlKey, _url);
    }

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

    return StreamAudioResponse(
      sourceLength: totalLength,
      contentLength: contentLength,
      offset: start ?? 0,
      contentType: req.headers["content-type"] ?? "audio/mp4",
      stream: req.stream,
    );
  }

  @override
  String toString() => "BackgroundAudioSource(\"$_trackId\", tag: $tag)";
}
