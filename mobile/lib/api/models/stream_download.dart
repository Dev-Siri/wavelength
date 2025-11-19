import "package:wavelength/api/models/track.dart";

class StreamDownload {
  final String downloadId;
  final Track metadata;

  /// Percentage of how much of the stream has been downloaded.
  final double progress;

  StreamDownload({
    this.progress = 0,
    required this.downloadId,
    required this.metadata,
  });

  StreamDownload copyWith({
    String? downloadId,
    double? progress,
    Track? metadata,
  }) {
    return StreamDownload(
      downloadId: downloadId ?? this.downloadId,
      progress: progress ?? this.progress,
      metadata: metadata ?? this.metadata,
    );
  }
}
