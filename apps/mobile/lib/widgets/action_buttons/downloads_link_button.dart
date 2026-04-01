import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/bloc/download/download_bloc.dart";
import "package:wavelength/bloc/download/download_state.dart";
import "package:wavelength/bloc/downloaded_tracks/downloaded_tracks_bloc.dart";
import "package:wavelength/bloc/downloaded_tracks/downloaded_tracks_event.dart";
import "package:wavelength/bloc/downloaded_tracks/downloaded_tracks_state.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class DownloadsLinkButton extends StatefulWidget {
  const DownloadsLinkButton({super.key});

  @override
  State<DownloadsLinkButton> createState() => _DownloadsLinkButtonState();
}

class _DownloadsLinkButtonState extends State<DownloadsLinkButton> {
  @override
  void initState() {
    super.initState();
    context.read<DownloadedTracksBloc>().add(DownloadedTracksFetchEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadedTracksBloc, DownloadedTracksState>(
      builder: (context, downloadedTracksState) {
        final downloadsTextQuantity = downloadedTracksState.downloads.isEmpty
            ? "No"
            : downloadedTracksState.downloads.length.toString();
        final downloadsTextSuffix = downloadedTracksState.downloads.length == 1
            ? "download"
            : "downloads";
        final downloadsText = "$downloadsTextQuantity $downloadsTextSuffix";

        return BlocBuilder<DownloadBloc, DownloadState>(
          builder: (context, state) {
            return AmplButton(
              padding: EdgeInsets.zero,
              onPressed: () => context.push("/downloads"),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        LucideIcons.download,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Downloads",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          downloadsText,
                          style: const TextStyle(
                            color: Colors.grey,
                            height: 1,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
