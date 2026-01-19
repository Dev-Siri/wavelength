import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_flutter/adapters.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/bloc/download/download_bloc.dart";
import "package:wavelength/bloc/download/download_event.dart";
import "package:wavelength/bloc/download/download_state.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/widgets/common_app_bar.dart";
import "package:wavelength/widgets/queued_track_tile.dart";
import "package:wavelength/widgets/track_tile.dart";

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  bool _isDownloadStalledForWifi = false;
  List<Track> _downloads = [];

  @override
  void initState() {
    _connectivityChangeListener();
    _fetchAllDownloadedTracks();
    super.initState();
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
    final downloads = box.values.toList().cast<Track>();

    setState(() => _downloads = downloads);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      backgroundColor: Colors.black,
      body: BlocBuilder<DownloadBloc, DownloadState>(
        builder: (context, state) {
          return Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
              children: [
                if (state.inQueue.isNotEmpty)
                  const Text(
                    "Active Downloads",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                if (state.inQueue.isNotEmpty) const SizedBox(height: 10),
                if (_isDownloadStalledForWifi)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      "Downloads are paused because Wi-Fi is not available. If you prefer downloading over mobile data anyway, disable the setting for Wi-Fi only downloads.",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                ...state.inQueue.map(
                  (queuedDownload) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: QueuedTrackTile(queuedDownload: queuedDownload),
                  ),
                ),
                const Text(
                  "Downloads",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                if (_downloads.isEmpty)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: MediaQuery.sizeOf(context).height / 4),
                      const Icon(LucideIcons.cloudDownload, size: 40),
                      const SizedBox(height: 10),
                      const Text(
                        "Your downloads are empty.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                for (final download in _downloads) TrackTile(track: download),
              ],
            ),
          );
        },
      ),
    );
  }
}
