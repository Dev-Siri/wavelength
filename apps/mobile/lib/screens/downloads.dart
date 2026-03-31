import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_flutter/adapters.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/audio/music_context_queue.dart";
import "package:wavelength/audio/queueable_music.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_state.dart";
import "package:wavelength/bloc/download/download_bloc.dart";
import "package:wavelength/bloc/download/download_event.dart";
import "package:wavelength/bloc/download/download_state.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/widgets/app_bars/common_app_bar.dart";
import "package:wavelength/widgets/music_player_preview/music_player_preview.dart";
import "package:wavelength/widgets/track/queued_track_tile.dart";
import "package:wavelength/widgets/track/track_tile.dart";

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  bool _isDownloadStalledForWifi = false;
  List<QueueableMusic> _downloads = [];

  @override
  void initState() {
    super.initState();
    _connectivityChangeListener();
    _fetchAllDownloadedTracks();
  }

  Future<void> _connectivityChangeListener() async {
    final downloadBloc = context.read<DownloadBloc>();
    final connectivity = Connectivity();
    final availableConnectivity = await connectivity.checkConnectivity();

    final sharedPrefs = await SharedPreferences.getInstance();
    final isPreferWifiDownloadsEnabled =
        sharedPrefs.getBool(settingsOptionPreferWifiForDownloads) ??
        settingsOptionPreferWifiForDownloadsDefaultValue;

    setState(
      () => _isDownloadStalledForWifi =
          isPreferWifiDownloadsEnabled &&
          !availableConnectivity.contains(ConnectivityResult.wifi),
    );

    if (availableConnectivity.contains(ConnectivityResult.wifi)) {
      downloadBloc.add(DownloadTriggerDownloadEvent());
    }
  }

  Future<void> _fetchAllDownloadedTracks() async {
    final box = await Hive.openBox(hiveStreamsKey);
    final downloads = box.values.toList().cast<QueueableMusic>();

    setState(() => _downloads = downloads);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Downloads"),
      backgroundColor: Colors.black,
      body: BlocBuilder<DownloadBloc, DownloadState>(
        builder: (context, state) {
          return ListView(
            children: [
              if (state.inQueue.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "Active Downloads",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              if (state.inQueue.isNotEmpty) const SizedBox(height: 10),
              if (_isDownloadStalledForWifi)
                const Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: Text(
                    "Downloads are paused because Wi-Fi is not available. If you prefer downloading over mobile data anyway, disable the Wi-Fi only downloads in settings.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ...state.inQueue.map(
                (queuedDownload) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: QueuedTrackTile(queuedDownload: queuedDownload),
                ),
              ),
              if (_downloads.isEmpty)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height / 4),
                    const Icon(
                      LucideIcons.folder,
                      size: 40,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Your downloads are empty.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              for (final download in _downloads)
                TrackTile(
                  musicContext: MusicContextTypeDownloads(),
                  sourceLabel: "Downloads",
                  tracks: _downloads,
                  track: Track(
                    videoId: download.videoId,
                    title: download.title,
                    thumbnail: download.thumbnail,
                    artists: download.artists,
                    duration: download.duration,
                    isExplicit: download.isExplicit,
                    album: download.album,
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<AppBottomSheetBloc, AppBottomSheetState>(
        builder: (context, state) {
          if (state is AppBottomSheetClosedState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              child: const MusicPlayerPreview(),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
