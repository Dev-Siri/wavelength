import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/audio/stream_resolver.dart";
import "package:wavelength/settings_manager.dart";
import "package:wavelength/widgets/app_bars/common_app_bar.dart";
import "package:wavelength/widgets/settings/setting_group.dart";
import "package:wavelength/widgets/settings/setting_option.dart";

const tipText =
    """Content downloaded previously will continue to play in the originally downloaded quality.""";

class AudioQualitySetting extends StatefulWidget {
  const AudioQualitySetting({super.key});

  @override
  State<AudioQualitySetting> createState() => _AudioQualitySettingState();
}

class _AudioQualitySettingState extends State<AudioQualitySetting> {
  StreamingQuality _cellularStreamingQuality = StreamingQuality.auto;
  StreamingQuality _wifiStreamingQuality = StreamingQuality.auto;
  DownloadQuality _downloadQuality = DownloadQuality.lossless;

  @override
  void initState() {
    super.initState();
    _fetchExistingPreferredQuality();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchExistingPreferredQuality();
  }

  Future<void> _fetchExistingPreferredQuality() async {
    final cellularStreamingQuality =
        await SettingsManager.fetchPreferredCellularStreamingQuality();
    final wifiStreamingQuality =
        await SettingsManager.fetchPreferredWifiStreamingQuality();
    final downloadQuality =
        await SettingsManager.fetchPreferredDownloadQuality();

    setState(() {
      _cellularStreamingQuality = cellularStreamingQuality;
      _wifiStreamingQuality = wifiStreamingQuality;
      _downloadQuality = downloadQuality;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Audio Quality"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingGroup(
                options: [
                  SettingOption(
                    title: "Cellular Streaming",
                    onPressed: () async {
                      await context.push(
                        "/settings/audio-quality/streaming/cellular",
                      );
                      await _fetchExistingPreferredQuality();
                    },
                    modifier: Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Row(
                        children: [
                          Text(
                            streamingQualityMap[_cellularStreamingQuality] ??
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
                  SettingOption(
                    title: "Wi-Fi Streaming",
                    onPressed: () async {
                      await context.push(
                        "/settings/audio-quality/streaming/wifi",
                      );
                      await _fetchExistingPreferredQuality();
                    },
                    modifier: Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Row(
                        children: [
                          Text(
                            streamingQualityMap[_wifiStreamingQuality] ?? "",
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
                  SettingOption(
                    title: "Downloads",
                    onPressed: () async {
                      await context.push("/settings/audio-quality/downloads");
                      await _fetchExistingPreferredQuality();
                    },
                    modifier: Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Row(
                        children: [
                          Text(
                            downloadQualityMap[_downloadQuality] ?? "",
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
              const Padding(
                padding: EdgeInsets.only(top: 6, bottom: 100),
                child: Text(
                  tipText,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
