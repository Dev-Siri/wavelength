import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/svg.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:vector_graphics/vector_graphics.dart";
import "package:wavelength/bloc/download/download_bloc.dart";
import "package:wavelength/bloc/download/download_event.dart";
import "package:wavelength/bloc/download/download_state.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/widgets/queued_track_tile.dart";

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  bool _isDownloadStalledForWifi = false;

  @override
  void initState() {
    _connectivityChangeListener();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(onPressed: () => context.pop()),
        centerTitle: true,
        title: const SvgPicture(
          AssetBytesLoader("assets/vectors/lambda.svg.vec"),
          height: 45,
          width: 45,
        ),
      ),
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        children: [
          const Text("Downloads", style: TextStyle(fontSize: 28)),
          const SizedBox(height: 10),
          BlocBuilder<DownloadBloc, DownloadState>(
            builder: (context, state) {
              if (state.inQueue.isEmpty) {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture(
                          AssetBytesLoader("assets/vectors/lambda.svg.vec"),
                          height: 200,
                          width: 200,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 80, bottom: 80),
                          child: Icon(
                            LucideIcons.bookmarkCheck400,
                            color: Colors.blue,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "No active downloads.",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                );
              }

              return Column(
                children: [
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
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
