import "package:hive_flutter/adapters.dart";
import "package:wavelength/api/models/enums/lossless_availability.dart";

part "stream.g.dart";

@HiveType(typeId: 20)
class HlsStreamMetadata {
  @HiveField(0)
  final String streamId;
  @HiveField(1)
  final double bitrate;
  @HiveField(2)
  final String codec;
  @HiveField(3)
  final String container;
  @HiveField(4)
  final double durationSeconds;
  @HiveField(5)
  final bool isHifiAvailable;
  @HiveField(6)
  final LosslessAvailability? isLosslessAvailable;

  const HlsStreamMetadata({
    required this.streamId,
    required this.bitrate,
    required this.codec,
    required this.container,
    required this.durationSeconds,
    required this.isHifiAvailable,
    required this.isLosslessAvailable,
  });

  factory HlsStreamMetadata.fromJson(Map<String, dynamic> json) {
    final isLosslessAvailable = json["isLosslessAvailable"] as String?;

    return HlsStreamMetadata(
      streamId: json["streamId"] as String,
      bitrate: (json["bitrate"] as num).toDouble(),
      codec: json["codec"] as String,
      container: json["container"] as String,
      durationSeconds: (json["durationSeconds"] as num).toDouble(),
      isHifiAvailable: (json["isHifiAvailable"] as bool?) ?? false,
      isLosslessAvailable: isLosslessAvailable == null
          ? null
          : isLosslessAvailable == "24-bit"
          ? LosslessAvailability.bit24
          : LosslessAvailability.bit16,
    );
  }
}

@HiveType(typeId: 19)
class HlsStreamSource {
  @HiveField(0)
  final HlsStreamMetadata metadata;
  @HiveField(1)
  final String source;

  const HlsStreamSource({required this.metadata, required this.source});

  factory HlsStreamSource.fromJson(Map<String, dynamic> json) {
    return HlsStreamSource(
      metadata: HlsStreamMetadata.fromJson(json["metadata"]),
      source: json['source'],
    );
  }
}
