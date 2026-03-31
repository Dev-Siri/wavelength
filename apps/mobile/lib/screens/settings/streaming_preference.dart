import "dart:io";

import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wavelength/audio/stream_resolver.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/settings_manager.dart";
import "package:wavelength/widgets/app_bars/common_app_bar.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class StreamingPreferenceSetting extends StatefulWidget {
  const StreamingPreferenceSetting({super.key});

  @override
  State<StreamingPreferenceSetting> createState() =>
      _StreamingPreferenceSettingState();
}

class _StreamingPreferenceSettingState
    extends State<StreamingPreferenceSetting> {
  StreamingPreference _streamingPreference = StreamingPreference.always;

  @override
  void initState() {
    super.initState();
    _fetchExistingPreferStreamingState();
  }

  Future<void> _fetchExistingPreferStreamingState() async {
    final streamingPreference =
        await SettingsManager.fetchPreferStreamingConnection();
    setState(() => _streamingPreference = streamingPreference);
  }

  Future<void> _updateStreamingPreference(StreamingPreference value) async {
    setState(() => _streamingPreference = value);
    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setInt(
      settingsOptionPreferStreamingOnConnection,
      value.index,
    );
  }

  Widget _getSelectedBadge(StreamingPreference activePreference) {
    return AnimatedScale(
      scale: _streamingPreference == activePreference ? 1 : 0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      child: const Padding(
        padding: EdgeInsets.only(right: 5),
        child: Icon(LucideIcons.check600, size: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Prefer Streaming"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  AmplListTile(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: Platform.isIOS ? 12 : 4,
                    ),
                    onTap: () =>
                        _updateStreamingPreference(StreamingPreference.always),
                    title: const Text("Always", style: TextStyle(fontSize: 18)),
                    subtitle: const Text(
                      "Stream even for a downloaded song.",
                      style: TextStyle(color: Colors.grey),
                    ),
                    trailing: _getSelectedBadge(StreamingPreference.always),
                  ),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.grey.shade800,
                  ),
                  AmplListTile(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: Platform.isIOS ? 12 : 4,
                    ),
                    onTap: () =>
                        _updateStreamingPreference(StreamingPreference.wifi),
                    title: const Text(
                      "Wi-Fi Only",
                      style: TextStyle(fontSize: 18),
                    ),
                    subtitle: const Text(
                      "Stream over Wi-Fi only.",
                      style: TextStyle(color: Colors.grey),
                    ),
                    trailing: _getSelectedBadge(StreamingPreference.wifi),
                  ),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.grey.shade800,
                  ),
                  AmplListTile(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: Platform.isIOS ? 12 : 4,
                    ),
                    onTap: () => _updateStreamingPreference(
                      StreamingPreference.downloads,
                    ),
                    title: const Text("Never", style: TextStyle(fontSize: 18)),
                    subtitle: const Text(
                      "Avoid streaming for a downloaded song.",
                      style: TextStyle(color: Colors.grey),
                    ),
                    trailing: _getSelectedBadge(StreamingPreference.downloads),
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
