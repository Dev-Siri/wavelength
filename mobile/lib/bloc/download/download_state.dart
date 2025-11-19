import "package:flutter/foundation.dart";
import "package:wavelength/api/models/stream_download.dart";

@immutable
final class DownloadState {
  final List<StreamDownload> inQueue;
  final bool isDownloading;

  const DownloadState({required this.inQueue, required this.isDownloading});

  DownloadState copyWith({List<StreamDownload>? inQueue, bool? isDownloading}) {
    return DownloadState(
      inQueue: inQueue ?? this.inQueue,
      isDownloading: isDownloading ?? this.isDownloading,
    );
  }
}
