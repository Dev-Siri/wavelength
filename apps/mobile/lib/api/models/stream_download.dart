import "package:flutter/foundation.dart";
import "package:wavelength/audio/queueable_music.dart";

@immutable
class StreamDownload {
  final String downloadId;
  final QueueableMusic metadata;

  /// Percentage of how much of the stream has been downloaded.
  final double progress;

  const StreamDownload({
    this.progress = 0,
    required this.downloadId,
    required this.metadata,
  });

  StreamDownload copyWith({
    String? downloadId,
    double? progress,
    QueueableMusic? metadata,
  }) {
    return StreamDownload(
      downloadId: downloadId ?? this.downloadId,
      progress: progress ?? this.progress,
      metadata: metadata ?? this.metadata,
    );
  }
}
