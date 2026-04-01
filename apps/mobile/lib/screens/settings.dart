import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wavelength/audio/stream_resolver.dart";
import "package:wavelength/bloc/location/location_bloc.dart";
import "package:wavelength/bloc/location/location_state.dart";
import "package:wavelength/audio_manager.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/settings_manager.dart";
import "package:wavelength/utils/format.dart";
import "package:wavelength/widgets/app_bars/common_app_bar.dart";
import "package:wavelength/widgets/settings/setting_group.dart";
import "package:wavelength/widgets/settings/setting_option.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  StreamingPreference _streamingPreference = StreamingPreference.always;
  bool _isPreferWifiForDownloadsEnabled = true;
  int _streamCacheFilesOccupiedSize = 0;

  @override
  void initState() {
    super.initState();
    _fetchExistingPreferWifiDownloadsState();
    _fetchStreamCacheOccupiedSize();
    _fetchExistingPreferStreamingState();
  }

  Future<void> _fetchStreamCacheOccupiedSize() async {
    final usedBytes = await AudioManager.calculateStorageUsage();

    setState(() => _streamCacheFilesOccupiedSize = usedBytes);
  }

  Future<void> _fetchExistingPreferWifiDownloadsState() async {
    final preferWifiDownloads =
        await SettingsManager.fetchPreferWifiDownloads();
    setState(() {
      _isPreferWifiForDownloadsEnabled = preferWifiDownloads;
    });
  }

  Future<void> _fetchExistingPreferStreamingState() async {
    final streamingPreference =
        await SettingsManager.fetchPreferStreamingConnection();
    setState(() => _streamingPreference = streamingPreference);
  }

  Future<void> _updatePreferWifiDownloadsState(bool enabled) async {
    setState(() => _isPreferWifiForDownloadsEnabled = enabled);

    final sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setBool(settingsOptionPreferWifiForDownloads, enabled);
  }

  Future<void> _clearDownloadedTracks() async {
    await AudioManager.clear();

    _fetchStreamCacheOccupiedSize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Audio",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SettingGroup(
                    options: [
                      SettingOption(
                        title: "Audio quality.",
                        description:
                            "Change Cellular, Wi-Fi, and Download quality.",
                        onPressed: () =>
                            context.push("/settings/audio-quality"),
                        modifier: const Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: Icon(
                            LucideIcons.chevronRight,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      SettingOption(
                        title: "Prefer streaming.",
                        description: "Prioritize streaming over downloads.",
                        onPressed: () =>
                            context.push("/settings/streaming-preference"),
                        modifier: Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Row(
                            children: [
                              Text(
                                streamingPreferenceMap[_streamingPreference] ??
                                    "",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              const Icon(
                                LucideIcons.chevronRight,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 20)),
                  const Text(
                    "Downloads",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SettingGroup(
                    options: [
                      SettingOption(
                        title: "Prefer Wi-Fi Downloads",
                        description: "Downloads paused on mobile data.",
                        modifier: Switch.adaptive(
                          value: _isPreferWifiForDownloadsEnabled,
                          activeTrackColor: Colors.blue,
                          onChanged: _updatePreferWifiDownloadsState,
                        ),
                      ),
                      SettingOption(
                        title: "Downloaded Size",
                        description: bytesToHumanReadableSize(
                          _streamCacheFilesOccupiedSize,
                        ),
                        modifier: Padding(
                          padding: EdgeInsets.only(
                            right: Platform.isIOS ? 5 : 0,
                          ),
                          child: AmplIconButton(
                            onPressed: _clearDownloadedTracks,
                            padding: const EdgeInsets.all(10),
                            icon: const Icon(
                              LucideIcons.trash,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Region",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  BlocBuilder<LocationBloc, LocationState>(
                    builder: (context, state) {
                      return Text(
                        countryCodeMap[state.countryCode] ?? defaultLocale,
                        style: TextStyle(color: Colors.grey.shade500),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
