import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wavelength/audio/stream_resolver.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/settings_manager.dart";
import "package:wavelength/widgets/app_bars/common_app_bar.dart";
import "package:wavelength/widgets/settings/setting_option.dart";

const tipText = """
Lossless streaming will lead to significantly more data usage.
Auto provides an adaptive streaming quality between Standard, High Quality, and Hi-Fi streaming, depending upon the bandwidth the device can transmit.
""";

class CellularStreamingQualitySetting extends StatefulWidget {
  const CellularStreamingQualitySetting({super.key});

  @override
  State<CellularStreamingQualitySetting> createState() =>
      _CellularStreamingQualitySettingState();
}

class _CellularStreamingQualitySettingState
    extends State<CellularStreamingQualitySetting> {
  StreamingQuality _cellularStreamingQuality = StreamingQuality.auto;

  @override
  void initState() {
    super.initState();
    _fetchExistingPreferredStreamingQualityState();
  }

  Future<void> _fetchExistingPreferredStreamingQualityState() async {
    final cellularStreamingQuality =
        await SettingsManager.fetchPreferredCellularStreamingQuality();

    setState(() {
      _cellularStreamingQuality = cellularStreamingQuality;
    });
  }

  Future<void> _updatePreferredStreamingQuality(StreamingQuality value) async {
    setState(() => _cellularStreamingQuality = value);
    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setInt(
      "$settingsOptionPreferredStreamingQuality:cellular",
      value.index,
    );
  }

  Widget _getSelectedBadge(StreamingQuality activeQuality) {
    final isSelected = _cellularStreamingQuality == activeQuality;
    return AnimatedScale(
      scale: isSelected ? 1 : 0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      child: const Padding(
        padding: EdgeInsets.only(right: 15),
        child: Icon(LucideIcons.check600, size: 18),
      ),
    );
  }

  List<Widget> _getStreamingOptions() {
    return [
      SettingOption(
        onPressed: () =>
            _updatePreferredStreamingQuality(StreamingQuality.auto),
        title: "Auto",
        description: "Adjust quality to suit your connection speed.",
        modifier: _getSelectedBadge(StreamingQuality.auto),
      ),
      Container(height: 1, width: double.infinity, color: Colors.grey.shade800),
      SettingOption(
        onPressed: () =>
            _updatePreferredStreamingQuality(StreamingQuality.q320),
        title: "Hi-Fi",
        description: "AAC 320kbps",
        modifier: _getSelectedBadge(StreamingQuality.q320),
      ),
      Container(height: 1, width: double.infinity, color: Colors.grey.shade800),
      SettingOption(
        onPressed: () =>
            _updatePreferredStreamingQuality(StreamingQuality.q256),
        title: "High Quality",
        description: "AAC 256kbps",
        modifier: _getSelectedBadge(StreamingQuality.q256),
      ),
      Container(height: 1, width: double.infinity, color: Colors.grey.shade800),
      SettingOption(
        onPressed: () =>
            _updatePreferredStreamingQuality(StreamingQuality.q128),
        title: "Standard",
        description: "Opus/AAC ~128kbps",
        modifier: _getSelectedBadge(StreamingQuality.q128),
      ),
      Container(height: 1, width: double.infinity, color: Colors.grey.shade800),
      SettingOption(
        onPressed: () =>
            _updatePreferredStreamingQuality(StreamingQuality.lossless),
        title: "Lossless",
        description: "FLAC up to 24-bit/44.1KHz",
        modifier: _getSelectedBadge(StreamingQuality.lossless),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Cellular Streaming"),
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
