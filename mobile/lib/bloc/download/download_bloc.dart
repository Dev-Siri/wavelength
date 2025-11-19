import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wavelength/bloc/download/download_event.dart";
import "package:wavelength/bloc/download/download_state.dart";
import "package:wavelength/cache.dart";
import "package:wavelength/constants.dart";

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  DownloadBloc()
    : super(const DownloadState(inQueue: [], isDownloading: false)) {
    on<DownloadAddToQueueEvent>(_addToDownloadQueue);
    on<DownloadTriggerDownloadEvent>(_triggerDownload);
  }

  Future<void> _startNextDownload(Emitter<DownloadState> emit) async {
    if (state.inQueue.isEmpty) return;

    final current = state.inQueue.first;

    emit(state.copyWith(isDownloading: true));

    await AudioCache.downloadAndCache(
      current.metadata.videoId,
      onProgress: (downloaded, total) {
        final progress = (downloaded / total) * 100;

        final updated = [
          current.copyWith(progress: progress),
          ...state.inQueue.skip(1),
        ];

        emit(state.copyWith(inQueue: updated));
      },
    );

    final updated = [...state.inQueue]..removeAt(0);

    emit(state.copyWith(inQueue: updated, isDownloading: false));

    await _startNextDownload(emit);
  }

  Future<void> _addToDownloadQueue(
    DownloadAddToQueueEvent event,
    Emitter<DownloadState> emit,
  ) async {
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

    if (!state.isDownloading && shouldDownload) {
      await _startNextDownload(emit);
    }
  }

  Future<void> _triggerDownload(
    DownloadTriggerDownloadEvent event,
    Emitter<DownloadState> emit,
  ) async {
    if (!state.isDownloading) {
      await _startNextDownload(emit);
    }
  }
}
