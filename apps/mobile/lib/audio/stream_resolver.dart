import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/enums/playability_status.dart";
import "package:wavelength/api/models/stream.dart";
import "package:wavelength/api/repositories/diagnostics_repo.dart";
import "package:wavelength/api/repositories/stream_repo.dart";
import "package:wavelength/audio/queueable_music.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/audio/audio_manager.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/settings_manager.dart";
import "package:wavelength/src/rust/api/tydle_caller.dart" as tydle_caller;
import "package:wavelength/utils/ttl_store.dart";

enum StreamingPreference { always, wifi, downloads }

enum StreamingQuality { auto, q320, q256, q128, lossless }

enum DownloadQuality { lossless, q320, q256, q128 }

final Map<StreamingQuality, String> streamingQualityMap = {
  StreamingQuality.auto: "Auto",
  StreamingQuality.q320: "Hi-Fi",
  StreamingQuality.q256: "High Quality",
  StreamingQuality.q128: "Standard",
  StreamingQuality.lossless: "Lossless",
};

final Map<DownloadQuality, String> downloadQualityMap = {
  DownloadQuality.q320: "Hi-Fi",
  DownloadQuality.q256: "High Quality",
  DownloadQuality.q128: "Standard",
  DownloadQuality.lossless: "Lossless",
};

final Map<StreamingPreference, String> streamingPreferenceMap = {
  StreamingPreference.always: "Always",
  StreamingPreference.wifi: "Wi-Fi only",
  StreamingPreference.downloads: "Never",
};

sealed class PlayableStreamMetadata {}

class PlayableStreamHlsMetadata extends PlayableStreamMetadata {
  final source = "Wavelength (HLS/m3u8: vnd.apple.mpegurl)";
  final HlsStreamMetadata metadata;

  PlayableStreamHlsMetadata({required this.metadata});
}

class PlayableStreamYouTubeMetadata extends PlayableStreamMetadata {
  final source = "YouTube (tydle)";
  final tydle_caller.StreamMetadata metadata;

  PlayableStreamYouTubeMetadata({required this.metadata});
}

class PlayableStream {
  final Uri source;
  final bool isLocalHls;
  final PlayableStreamMetadata? metadata;

  const PlayableStream({
    required this.source,
    required this.isLocalHls,
    this.metadata,
  });
}

class StreamResolver {
  final FlutterSecureStorage _secureStorage;

  StreamResolver(this._secureStorage);

  Future<String?> get _authToken =>
      _secureStorage.read(key: AuthBloc.authTokenKey);

  Future<PlayableStream> fetchStreamSource(
    QueueableMusic queueableMusic,
    DownloadQuality? downloadQuality,
  ) async {
    final streamingPreference =
        await SettingsManager.fetchPreferStreamingConnection();
    final connectivityResult = await Connectivity().checkConnectivity();
    final isDownloaded = await AudioManager.isTrackDownloaded(
      queueableMusic.videoId,
    );

    if (connectivityResult.contains(ConnectivityResult.none) && isDownloaded) {
      return _fetchDownloadedStream(queueableMusic);
    }

    if (streamingPreference != StreamingPreference.always) {
      final prefersDownloads =
          streamingPreference == StreamingPreference.downloads;
      final prefersWifiButNotOnWifi =
          (!connectivityResult.contains(ConnectivityResult.wifi) &&
          streamingPreference == StreamingPreference.wifi);

      if (isDownloaded && (prefersDownloads || prefersWifiButNotOnWifi)) {
        return _fetchDownloadedStream(queueableMusic);
      }
    }

    final playabilityStatus = await _fetchPlayabilityStatus(
      queueableMusic.videoId,
    );

    if (playabilityStatus == PlayabilityStatus.playable) {
      try {
        return _fetchNativeSource(queueableMusic, downloadQuality);
      } catch (error) {
        DiagnosticsRepo.reportError(
          error: error.toString(),
          source: "StreamResolver._fetchStreamSource",
        );
        return _fetchYouTubeSource(queueableMusic);
      }
    }

    _ensureNativePlayabilityForNext(playabilityStatus, queueableMusic.videoId);
    return _fetchYouTubeSource(queueableMusic);
  }

  Future<PlayableStream> _fetchDownloadedStream(
    QueueableMusic queueableMusic,
  ) async {
    final downloadedStream = await AudioManager.get(queueableMusic.videoId);
    final box = await Hive.openBox(hiveStreamsMetadataKey);
    final metadata = await box.get(queueableMusic.videoId);

    final source = Uri.file(downloadedStream!);

    return PlayableStream(
      source: source,
      isLocalHls: downloadedStream.contains("index.m3u8"),
      metadata: metadata != null
          ? PlayableStreamHlsMetadata(metadata: metadata)
          : null,
    );
  }

  Future<PlayableStream> _fetchNativeSource(
    QueueableMusic queueableMusic,
    DownloadQuality? downloadQuality,
  ) async {
    final streamCacheBox = await Hive.openBox(hiveNativeCachedStreamsKey);
    final streamCacheStore = TtlStorage(
      streamCacheBox,
      ttl: const Duration(hours: streamUrlSignValidityHours),
    );

    final cacheKey = await _buildCacheKey(
      queueableMusic.videoId,
      downloadQuality,
    );
    final HlsStreamSource? cachedStream = await streamCacheStore.get(cacheKey);

    if (cachedStream != null) {
      final streamableUri = Uri.parse(cachedStream.source);

      return PlayableStream(
        source: streamableUri,
        isLocalHls: false,
        metadata: PlayableStreamHlsMetadata(metadata: cachedStream.metadata),
      );
    }

    final streamSource = await StreamRepo.fetchStreamSource(
      videoId: queueableMusic.videoId,
      authToken: await _authToken ?? "",
      preferredQuality: await _pickQuality(downloadQuality),
    );

    if (streamSource is! ApiResponseSuccess<HlsStreamSource>) {
      throw Exception(
        (streamSource as ApiResponseError<HlsStreamSource>).message,
      );
    }

    await streamCacheStore.save(cacheKey, streamSource.data);

    final streamableUri = Uri.parse(streamSource.data.source);

    return PlayableStream(
      source: streamableUri,
      isLocalHls: false,
      metadata: PlayableStreamHlsMetadata(metadata: streamSource.data.metadata),
    );
  }

  Future<PlayableStream> _fetchYouTubeSource(
    QueueableMusic queueableMusic,
  ) async {
    final stream = await tydle_caller.fetchHighestAudioStream(
      videoId: queueableMusic.videoId,
    );

    final streamableUri = Uri.parse(stream.url);

    return PlayableStream(
      source: streamableUri,
      isLocalHls: false,
      metadata: PlayableStreamYouTubeMetadata(metadata: stream.metadata),
    );
  }

  Future<PlayabilityStatus> _fetchPlayabilityStatus(String videoId) async {
    final box = await Hive.openBox(hivePlayabilityStatusKey);
    if (box.containsKey(videoId)) {
      return PlayabilityStatus.playable;
    }

    final playabilityStatusResponse =
        await StreamRepo.fetchStreamPlayabilityStatus(
          authToken: await _authToken ?? "",
          videoId: videoId,
        );

    if (playabilityStatusResponse is! ApiResponseSuccess<PlayabilityStatus>) {
      return PlayabilityStatus.unplayable;
    }

    if (playabilityStatusResponse.data == PlayabilityStatus.playable) {
      await box.put(videoId, true);
    }

    return playabilityStatusResponse.data;
  }

  Future<void> _ensureNativePlayabilityForNext(
    PlayabilityStatus playabilityStatus,
    String videoId,
  ) async {
    final playabilityStatusResponse =
        await StreamRepo.fetchStreamPlayabilityStatus(
          authToken: await _authToken ?? "",
          videoId: videoId,
        );

    if (playabilityStatusResponse is! ApiResponseSuccess<PlayabilityStatus>) {
      return;
    }

    if (playabilityStatusResponse.data == PlayabilityStatus.unavailable) {
      await StreamRepo.collectStream(videoId: videoId);
    }
  }

  Future<String> _pickQuality(DownloadQuality? downloadQuality) async {
    if (downloadQuality != null) {
      if (downloadQuality == DownloadQuality.lossless) {
        return "lossless";
      }

      return downloadQuality.name.substring(1);
    }

    final connectivity = Connectivity();
    final connectivityResult = await connectivity.checkConnectivity();

    final StreamingQuality preferredQuality;

    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      preferredQuality =
          await SettingsManager.fetchPreferredCellularStreamingQuality();
    } else {
      preferredQuality =
          await SettingsManager.fetchPreferredWifiStreamingQuality();
    }

    if (preferredQuality == StreamingQuality.auto) {
      return "auto";
    }

    if (preferredQuality == StreamingQuality.lossless) {
      return "lossless";
    }

    return preferredQuality.name.substring(1);
  }

  Future<String> _buildCacheKey(
    String videoId,
    DownloadQuality? downloadQuality,
  ) async {
    if (downloadQuality != null) {
      final quality = await _pickQuality(downloadQuality);
      return "$videoId|download|$quality";
    }

    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();

    final isMobile = result.contains(ConnectivityResult.mobile);

    final quality = await _pickQuality(downloadQuality);

    return "$videoId|${isMobile ? "mobile" : "wifi"}|$quality";
  }
}
