import "package:flutter/foundation.dart";
import "package:wavelength/audio/queueable_music.dart";

@immutable
class DownloadedTracksState {
  final List<QueueableMusic> downloads;

  const DownloadedTracksState({required this.downloads});
}
