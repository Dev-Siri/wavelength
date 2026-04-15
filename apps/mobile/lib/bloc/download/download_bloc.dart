import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:hive/hive.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wavelength/bloc/download/download_event.dart";
import "package:wavelength/bloc/download/download_state.dart";
import "package:wavelength/audio/audio_manager.dart";
import "package:wavelength/constants.dart";

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final FlutterSecureStorage _secureStorage;

  DownloadBloc(this._secureStorage)
    : super(const DownloadState(inQueue: [], isDownloading: false)) {
    on<DownloadAddToQueueEvent>(_addToDownloadQueue);
    on<DownloadTriggerDownloadEvent>(_triggerDownload);
  }

  Future<void> _startNextDownload(Emitter<DownloadState> emit) async {
    if (state.inQueue.isEmpty) return;

    final current = state.inQueue.first;

    emit(state.copyWith(isDownloading: true));

    final streamsStore = await Hive.openBox(hiveStreamsKey);
    final streamsMetadataStore = await Hive.openBox(hiveStreamsMetadataKey);

    await streamsStore.put(current.metadata.videoId, current.metadata);
    final metadata = await AudioManager.download(
      current.metadata,
      _secureStorage,
      onProgress: (downloaded, total) {
        final progress = (downloaded / total) * 100;

        final updated = [
          current.copyWith(progress: progress),
          ...state.inQueue.skip(1),
        ];

        emit(state.copyWith(inQueue: updated));
      },
    );

    if (metadata != null) {
      streamsMetadataStore.put(current.metadata.videoId, metadata);
    }

    final updated = [...state.inQueue]..removeAt(0);

    emit(state.copyWith(inQueue: updated, isDownloading: false));

    await _startNextDownload(emit);
  }

  Future<void> _addToDownloadQueue(
    DownloadAddToQueueEvent event,
    Emitter<DownloadState> emit,
  ) async {
    final wasQueueEmpty = state.inQueue.isEmpty;
    emit(state.copyWith(inQueue: [...state.inQueue, event.newDownload]));

    final connectivity = Connectivity();
    final availableConnectivity = await connectivity.checkConnectivity();

    final sharedPrefs = await SharedPreferences.getInstance();
    final isPreferWifiDownloadsEnabled =
        sharedPrefs.getBool(settingsOptionPreferWifiForDownloads) ??
        settingsOptionPreferWifiForDownloadsDefaultValue;

    bool shouldDownload = true;

    if (isPreferWifiDownloadsEnabled) {
      shouldDownload = availableConnectivity.contains(ConnectivityResult.wifi);
    }

    if (wasQueueEmpty && shouldDownload) {
      await _startNextDownload(emit);
    }
  }

  Future<void> _triggerDownload(
    DownloadTriggerDownloadEvent event,
    Emitter<DownloadState> emit,
  ) async {
    if (!state.isDownloading && state.inQueue.isNotEmpty) {
      await _startNextDownload(emit);
    }
  }
}
