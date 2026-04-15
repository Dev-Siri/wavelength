import "dart:io";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:hive_flutter/adapters.dart";
import "package:http/http.dart" as http;
import "package:path_provider/path_provider.dart";
import "package:wavelength/api/models/stream.dart";
import "package:wavelength/api/repositories/diagnostics_repo.dart";
import "package:wavelength/audio/queueable_music.dart";
import "package:wavelength/audio/stream_resolver.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/settings_manager.dart";

class AudioManager {
  static Future<File> _getFile(String trackId) async {
    final dir = await getApplicationDocumentsDirectory();

    return File("${dir.path}/stream_$trackId.m4a");
  }

  static Future<String?> get(String trackId) async {
    final dir = await getApplicationDocumentsDirectory();

    final hlsDir = Directory("${dir.path}/stream_$trackId");
    if (await hlsDir.exists()) {
      final playlist = File("${hlsDir.path}/index.m3u8");
      if (await playlist.exists()) {
        return playlist.path;
      }
    }

    final file = await _getFile(trackId);
    if (await file.exists()) return file.path;

    return null;
  }

  static Future<void> clear() async {
    final dir = await getApplicationDocumentsDirectory();
    final box = await Hive.openBox(hiveStreamsKey);

    await for (final file in dir.list()) {
      if (file is File && file.path.endsWith(".m4a")) {
        await file.delete();
      } else if (file is Directory && file.path.contains("stream_")) {
        await file.delete(recursive: true);
      }
    }

    await box.clear();
  }

  static Future<HlsStreamMetadata?> download(
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
        final dir = await getApplicationDocumentsDirectory();
        final hlsDir = Directory(
          "${dir.path}/stream_${queueableMusic.videoId}",
        );
        await hlsDir.create(recursive: true);
        final playlistFile = File("${hlsDir.path}/index.m3u8");
        final initFile = File("${hlsDir.path}/init.mp4");

        final playlistContent = await http.read(stream.source);
        final rewrittenLines = <String>[];
        final originalLines = playlistContent.split("\n");

        // Keep header tags (except ENDLIST, we’ll append it later)
        for (final line in originalLines) {
          if (line.startsWith("#EXTM3U") ||
              line.startsWith("#EXT-X-VERSION") ||
              line.startsWith("#EXT-X-TARGETDURATION") ||
              line.startsWith("#EXT-X-MEDIA-SEQUENCE")) {
            rewrittenLines.add(line);
          }
        }

        String? initSegment;
        for (final line in playlistContent.split("\n")) {
          if (line.startsWith("#EXT-X-MAP")) {
            final match = RegExp(r'URI="([^"]+)"').firstMatch(line);
            if (match != null) {
              initSegment = match.group(1);
            }
          }
        }

        final segmentPairs = <MapEntry<String, String>>[];
        String? currentExtinf;

        for (final line in originalLines) {
          if (line.startsWith("#EXTINF")) {
            currentExtinf = line;
          } else if (line.isNotEmpty && !line.startsWith("#")) {
            if (currentExtinf != null) {
              segmentPairs.add(MapEntry(currentExtinf, line));
              currentExtinf = null;
            }
          }
        }

        int received = 0;
        int total = segmentPairs.length;

        if (initSegment != null) {
          final initUrl = stream.source.resolve(initSegment);
          final initBytes = (await http.get(initUrl)).bodyBytes;
          await initFile.writeAsBytes(initBytes);

          rewrittenLines.add('#EXT-X-MAP:URI="init.mp4"');
        }

        for (final pair in segmentPairs) {
          final extinf = pair.key;
          final segmentUrl = pair.value;

          final segFile = File("${hlsDir.path}/seg_$received.m4s");

          final absoluteUrl = stream.source.resolve(segmentUrl);
          final segmentBytes = (await http.get(absoluteUrl)).bodyBytes;

          await segFile.writeAsBytes(segmentBytes);

          rewrittenLines.add(extinf);
          rewrittenLines.add("seg_$received.m4s");

          received++;
          if (onProgress != null) onProgress(received, total);
        }

        rewrittenLines.add("#EXT-X-ENDLIST");
        await playlistFile.writeAsString(rewrittenLines.join("\n"));
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
        source: "(static) AudioCache.download()",
      );
      return null;
    }
  }

  static Future<int> calculateStorageUsage() async {
    final dir = await getApplicationDocumentsDirectory();
    int accumulatedSize = 0;

    await for (final file in dir.list()) {
      if (file is File && file.path.endsWith(".m4a")) {
        final stat = await file.stat();
        accumulatedSize += stat.size;
      } else if (file is Directory && file.path.contains("stream_")) {
        await for (final inner in file.list(recursive: true)) {
          if (inner is File) {
            final stat = await inner.stat();
            accumulatedSize += stat.size;
          }
        }
      }
    }
    return accumulatedSize;
  }

  static Future<bool> isTrackDownloaded(String trackId) async {
    final dir = await getApplicationDocumentsDirectory();

    final hlsDir = Directory("${dir.path}/stream_$trackId");
    if (await hlsDir.exists()) {
      final playlist = File("${hlsDir.path}/index.m3u8");
      if (await playlist.exists()) return true;
    }

    final file = await _getFile(trackId);
    return await file.exists();
  }

  static Future<void> deleteTrack(String trackId) async {
    final dir = await getApplicationDocumentsDirectory();

    final hlsDir = Directory("${dir.path}/stream_$trackId");
    if (await hlsDir.exists()) {
      await hlsDir.delete(recursive: true);
    }

    final file = await _getFile(trackId);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<int> countDownloadedTracksInPlaylist(
    List<String> playlistTrackIds,
  ) async {
    int count = 0;

    for (final trackId in playlistTrackIds) {
      if (await isTrackDownloaded(trackId)) {
        count++;
      }
    }

    return count;
  }
}
