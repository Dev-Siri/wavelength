import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wavelength/bloc/location/location_bloc.dart";
import "package:wavelength/bloc/location/location_state.dart";
import "package:wavelength/cache.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/utils/format.dart";
import "package:wavelength/widgets/common_app_bar.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isPreferWifiForDownloadsEnabled = true;
  int _streamCacheFilesOccupiedSize = 0;

  @override
  void initState() {
    super.initState();
    _fetchExistingPreferWifiDownloadsState();
    _fetchStreamCacheOccupiedSize();
  }

  Future<void> _fetchStreamCacheOccupiedSize() async {
    final usedBytes = await AudioCache.calculateStorageUsage();

    setState(() => _streamCacheFilesOccupiedSize = usedBytes);
  }

  Future<void> _fetchExistingPreferWifiDownloadsState() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final existingState = sharedPrefs.getBool(
      settingsOptionPreferWifiForDownloads,
    );

    if (existingState == null) {
      sharedPrefs.setBool(
        settingsOptionPreferWifiForDownloads,
        settingsOptionPreferWifiForDownloadsDefaultValue,
      );
    }

    setState(() {
      _isPreferWifiForDownloadsEnabled = existingState ?? true;
    });
  }

  Future<void> _updatePreferWifiDownloadsState(bool enabled) async {
    setState(() => _isPreferWifiForDownloadsEnabled = enabled);

    final sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setBool(settingsOptionPreferWifiForDownloads, enabled);
  }

  Future<void> _clearDownloadedTracks() async {
    await AudioCache.clear();

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
                    "Storage",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 5,
                      top: 10,
                      bottom: 10,
                    ),
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade900,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 270,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Prefer Wi-Fi Downloads",
                                    style: TextStyle(fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "Downloads paused on mobile data.",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: _isPreferWifiForDownloadsEnabled,
                              activeTrackColor: Colors.blue,
                              onChanged: _updatePreferWifiDownloadsState,
                            ),
                          ],
                        ),
                        Container(
                          height: 1,
                          color: Colors.grey.shade800,
                          margin: const EdgeInsets.only(
                            right: 10,
                            top: 10,
                            bottom: 10,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 270,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Downloaded Size",
                                    style: TextStyle(fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    bytesToHumanReadableSize(
                                      _streamCacheFilesOccupiedSize,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                right: Platform.isIOS ? 5 : 0,
                              ),
                              child: AmplButton(
                                onPressed: _clearDownloadedTracks,
                                padding: const EdgeInsets.all(10),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
