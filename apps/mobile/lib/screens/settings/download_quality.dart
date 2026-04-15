import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wavelength/audio/stream_resolver.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/settings_manager.dart";
import "package:wavelength/widgets/app_bars/common_app_bar.dart";
import "package:wavelength/widgets/settings/setting_option.dart";

const tipText = """
When available, Wavelength will download the songs in the selected quality. Lossless files will use significantly more space on your device.

10GB of space could store approximately:
- 3,000 songs at High Quality
- 1,500 songs at Hi-Fi
- 500 songs with Lossless
""";

class DownloadQualitySetting extends StatefulWidget {
  const DownloadQualitySetting({super.key});

  @override
  State<DownloadQualitySetting> createState() => _DownloadQualitySettingState();
}

class _DownloadQualitySettingState extends State<DownloadQualitySetting> {
  DownloadQuality _downloadQuality = DownloadQuality.lossless;

  @override
  void initState() {
    super.initState();
    _fetchExistingPreferredStreamingQualityState();
  }

  Future<void> _fetchExistingPreferredStreamingQualityState() async {
    final downloadQuality =
        await SettingsManager.fetchPreferredDownloadQuality();

    setState(() => _downloadQuality = downloadQuality);
  }

  Future<void> _updatePreferredDownloadQuality(DownloadQuality value) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setInt(
      "$settingsOptionPreferredStreamingQuality:downloads",
      value.index,
    );
    setState(() => _downloadQuality = value);
  }

  Widget _getSelectedBadge(DownloadQuality activeQuality) {
    return AnimatedScale(
      scale: _downloadQuality == activeQuality ? 1 : 0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      child: const Padding(
        padding: EdgeInsets.only(right: 5),
        child: Icon(LucideIcons.check600, size: 18),
      ),
    );
  }

  List<Widget> _getStreamingOptions() {
    return [
      SettingOption(
        onPressed: () => _updatePreferredDownloadQuality(DownloadQuality.q320),
        title: "Hi-Fi",
        description: "AAC 320kbps",
        modifier: _getSelectedBadge(DownloadQuality.q320),
      ),
      Container(height: 1, width: double.infinity, color: Colors.grey.shade800),
      SettingOption(
        onPressed: () => _updatePreferredDownloadQuality(DownloadQuality.q256),
        title: "High Quality",
        description: "AAC 256kbps",
        modifier: _getSelectedBadge(DownloadQuality.q256),
      ),
      Container(height: 1, width: double.infinity, color: Colors.grey.shade800),
      SettingOption(
        onPressed: () => _updatePreferredDownloadQuality(DownloadQuality.q128),
        title: "Standard",
        description: "Opus/AAC ~128kbps",
        modifier: _getSelectedBadge(DownloadQuality.q128),
      ),
      Container(height: 1, width: double.infinity, color: Colors.grey.shade800),
      SettingOption(
        onPressed: () =>
            _updatePreferredDownloadQuality(DownloadQuality.lossless),
        title: "Lossless",
        description: "FLAC up to 24-bit/192kHz",
        modifier: _getSelectedBadge(DownloadQuality.lossless),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Download Quality"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(children: _getStreamingOptions()),
              ),
              const SizedBox(height: 10),
              const Text(
                tipText,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
