import "dart:ui";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:go_router/go_router.dart";
import "package:vector_graphics/vector_graphics.dart";
import "package:wavelength/api/models/enums/lossless_availability.dart";
import "package:wavelength/api/models/stream.dart";
import "package:wavelength/audio/stream_resolver.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_state.dart";
import "package:wavelength/widgets/animations/shimmer_animation.dart";
import "package:wavelength/widgets/ui/ampl_button.dart";

class HifiBadge extends StatelessWidget {
  const HifiBadge({super.key});

  String _getDetailedExtendedQualityText(HlsStreamMetadata metadata) {
    if (metadata.bitrate >= 1200000 && metadata.isLosslessAvailable != null) {
      String bit;
      if (metadata.isLosslessAvailable == LosslessAvailability.bit24) {
        bit = "24-bit";
      } else {
        bit = "16-bit";
      }

      return "$bit/44.1kHz FLAC";
    } else if (metadata.bitrate == 256000) {
      return "256kb/s AAC • 44.1kHz";
    } else if (metadata.bitrate == 320000) {
      return "320kb/s AAC • 44.1kHz";
    } else if (metadata.bitrate == 128) {
      return "128kb/s ${metadata.codec[0].toUpperCase()}${metadata.codec.substring(1)}";
    }

    return "${metadata.bitrate.toStringAsFixed(2)}kb/s ${metadata.codec[0].toUpperCase()}${metadata.codec.substring(1)}";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicPlayerTrackBloc, MusicPlayerTrackState>(
      builder: (context, state) {
        if (state is! MusicPlayerTrackPlayingNowState) {
          return const SizedBox.shrink();
        }

        final streamMetadata = state.metadata;
        if (streamMetadata is! PlayableStreamHlsMetadata) {
          return const SizedBox.shrink();
        }

        if ((streamMetadata.metadata.bitrate) < 256000) {
          return const SizedBox.shrink();
        }

        final detailedQuality = streamMetadata.metadata.bitrate >= 1200000
            ? "Lossless"
            : streamMetadata.metadata.bitrate == 320000
            ? "Hi-Fi Audio"
            : "High Quality";

        return ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: GestureDetector(
              onTap: () => showAdaptiveDialog(
                context: context,
                builder: (context) {
                  return AlertDialog.adaptive(
                    title: const SvgPicture(
                      AssetBytesLoader("assets/vectors/lambda.svg.vec"),
                      height: 100,
                      width: 100,
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          detailedQuality,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _getDetailedExtendedQualityText(
                            streamMetadata.metadata,
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    actionsAlignment: MainAxisAlignment.center,
                    actions: [
                      SizedBox(
                        width: double.infinity,
                        child: AmplButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await context.push("/settings/audio-quality");
                          },
                          child: const Text("Audio Quality Settings"),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: AmplButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ),
                    ],
                  );
                },
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withAlpha(20),
                  border: Border.all(
                    color: Colors.white.withAlpha(46),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "λ",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ShimmerAnimation(
                      child: Text(
                        streamMetadata.metadata.bitrate >= 1200000
                            ? "Hi-Fi Lossless"
                            : streamMetadata.metadata.bitrate == 320000
                            ? "Hi-Fi Audio"
                            : "HD Audio",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
