import "package:flutter/cupertino.dart";
import "package:wavelength/api/models/stream_download.dart";

@immutable
sealed class DownloadEvent {}

class DownloadAddToQueueEvent extends DownloadEvent {
  final StreamDownload newDownload;

  DownloadAddToQueueEvent({required this.newDownload});
}

class DownloadTriggerDownloadEvent extends DownloadEvent {}
