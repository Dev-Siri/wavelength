import "dart:io";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:http/http.dart" as http;
import "package:path_provider/path_provider.dart";
import "package:wavelength/api/models/stream.dart";
import "package:wavelength/api/repositories/diagnostics_repo.dart";
import "package:wavelength/audio/queueable_music.dart";
import "package:wavelength/audio/stream_resolver.dart";
import "package:wavelength/settings_manager.dart";

class AudioCache {
  static Future<File> _getFile(String trackId) async {
    final dir = await getApplicationDocumentsDirectory();

    return File("${dir.path}/stream_$trackId.mp4");
  }

  static Future<bool> exists(String trackId) async {
    final file = await _getFile(trackId);
    return file.exists();
  }

  static Future<void> save(String trackId, List<int> bytes) async {
    final file = await _getFile(trackId);
    await file.writeAsBytes(bytes);
  }

  static Future<String?> get(String trackId) async {
    final file = await _getFile(trackId);

    if (await file.exists()) return file.path;

    return null;
  }

  static Future<File?> getStream(String trackId) async {
    final file = await _getFile(trackId);

    if (await file.exists()) return file;

    return null;
  }

  static Future<void> clear() async {
    final dir = await getApplicationDocumentsDirectory();

    await for (final file in dir.list()) {
      if (file is File && file.path.endsWith(".mp4")) await file.delete();
    }
  }

  static Future<HlsStreamMetadata?> downloadAndCache(
    QueueableMusic queueableMusic,
    FlutterSecureStorage secureStorage, {
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      final downloadQuality =
          await SettingsManager.fetchPreferredDownloadQuality();
      final stream = await StreamResolver(
        secureStorage,
      ).fetchStreamSource(queueableMusic, downloadQuality);
      final isHls = stream.source.toString().contains("index.m3u8");

      if (isHls) {
        final playlistContent = await http.read(stream.source);

        String? initSegment;
        for (final line in playlistContent.split("\n")) {
          if (line.startsWith("#EXT-X-MAP")) {
            final match = RegExp(r'URI="([^"]+)"').firstMatch(line);
            if (match != null) {
              initSegment = match.group(1);
            }
          }
        }

        final lines = playlistContent
            .split("\n")
            .where((l) => l.isNotEmpty && !l.startsWith("#"))
            .toList();

        final file = await _getFile(queueableMusic.videoId);
        final sink = file.openWrite();

        int received = 0;
        int total = lines.length;

        if (initSegment != null) {
          final initUrl = stream.source.resolve(initSegment);
          final initBytes = (await http.get(initUrl)).bodyBytes;
          sink.add(initBytes);
        }

        for (final segmentUrl in lines) {
          final absoluteUrl = stream.source.resolve(segmentUrl);
          final segmentBytes = (await http.get(absoluteUrl)).bodyBytes;
          sink.add(segmentBytes);

          received++;
          if (onProgress != null) onProgress(received, total);
        }

        await sink.close();
      } else {
        final req = http.Request("GET", stream.source);
        final client = http.Client();

        final response = await client.send(req);
        final total = response.contentLength ?? 0;

        final file = await _getFile(queueableMusic.videoId);
        final sink = file.openWrite();

        int received = 0;

        await for (final chunk in response.stream) {
          received += chunk.length;
          sink.add(chunk);

          if (onProgress != null && total > 0) onProgress(received, total);
        }

        await sink.close();
        client.close();
      }

      final playableStreamMeta = stream.metadata;

      return playableStreamMeta is PlayableStreamHlsMetadata
          ? playableStreamMeta.metadata
          : null;
    } catch (error) {
      DiagnosticsRepo.reportError(
        error: error.toString(),
        source: "(static) AudioCache.downloadAndCache()",
      );
      return null;
    }
  }

  static Future<int> calculateStorageUsage() async {
    final dir = await getApplicationDocumentsDirectory();
    int accumulatedSize = 0;

    await for (final file in dir.list()) {
      if (!file.path.endsWith(".mp4")) continue;

      final fileStat = await file.stat();
      accumulatedSize += fileStat.size;
    }
    return accumulatedSize;
  }

  static Future<bool> isTrackDownloaded(String trackId) async {
    final dir = await getApplicationDocumentsDirectory();

    await for (final file in dir.list()) {
      if (!file.path.endsWith(".mp4")) continue;

      if (trackId ==
          file.uri.pathSegments.last
              .replaceFirst("stream_", "")
              .replaceFirst(".mp4", "")) {
        return true;
      }
    }

    return false;
  }

  static Future<void> deleteTrack(String trackId) async {
    final dir = await getApplicationDocumentsDirectory();

    await for (final file in dir.list()) {
      if (!file.path.endsWith(".mp4")) continue;

      if (trackId ==
          file.uri.pathSegments.last
              .replaceFirst("stream_", "")
              .replaceFirst(".mp4", "")) {
        await file.delete();
      }
    }
  }

  static Future<int> countDownloadedTracksInPlaylist(
    List<String> playlistTrackIds,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    int count = 0;

    await for (final file in dir.list()) {
      if (!file.path.endsWith(".mp4")) continue;

      if (playlistTrackIds.contains(
        file.uri.pathSegments.last
            .replaceFirst("stream_", "")
            .replaceFirst(".mp4", ""),
      )) {
        count++;
      }
    }

    return count;
  }
}
