import "dart:io";
import "dart:typed_data";
import "package:path_provider/path_provider.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/repositories/streams_repo.dart";
import "package:wavelength/constants.dart";

class AudioCache {
  /// This methods check whether the user has enabled the option in settings
  /// which permits auto-saving streams with the help of this class. Use is external.
  static Future<bool> isAutoCachingPermitted() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final isPermitted = sharedPrefs.getBool(
      settingsOptionEnableAutoCacheStreams,
    );

    return isPermitted ?? settingsOptionEnableAutoCacheStreamsDefaultValue;
  }

  static Future<File> _getFile(String trackId) async {
    final dir = await getTemporaryDirectory();

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
    final dir = await getTemporaryDirectory();

    await for (final file in dir.list()) {
      if (file is File && file.path.endsWith(".mp4")) await file.delete();
    }
  }

  static Future<bool> downloadAndCache(String trackId) async {
    final stream = await StreamsRepo.fetchTrackStream(videoId: trackId);

    if (stream is! ApiResponseSuccess<Uint8List>) return false;

    await save(trackId, stream.data);

    return true;
  }

  static Future<int> calculateStorageUsage() async {
    final dir = await getTemporaryDirectory();
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
    final dir = await getTemporaryDirectory();
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
