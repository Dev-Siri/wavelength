import "dart:io";
import "package:http/http.dart" as http;
import "package:path_provider/path_provider.dart";
import "package:wavelength/src/rust/api/tydle_caller.dart";

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

  static Future<bool> downloadAndCache(String trackId) async {
    try {
      final streamUrl = await fetchHighestAudioStreamUrl(videoId: trackId);
      final stream = await http.get(Uri.parse(streamUrl));

      await save(trackId, stream.bodyBytes);
      return true;
    } catch (_) {
      return false;
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
