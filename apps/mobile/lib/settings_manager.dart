import "package:wavelength/audio/stream_resolver.dart";
import "package:wavelength/constants.dart";
import "package:shared_preferences/shared_preferences.dart";

class SettingsManager {
  static Future<StreamingQuality> fetchPreferredWifiStreamingQuality() async {
    final key = "$settingsOptionPreferredStreamingQuality:wifi";
    final sharedPrefs = await SharedPreferences.getInstance();
    final existingState = sharedPrefs.getInt(key);

    if (existingState == null) {
      sharedPrefs.setInt(
        key,
        settingsOptionPreferredStreamingQualityDefaultValue,
      );
    }

    return StreamingQuality.values[existingState ?? 0];
  }

  static Future<StreamingQuality>
  fetchPreferredCellularStreamingQuality() async {
    final key = "$settingsOptionPreferredStreamingQuality:cellular";
    final sharedPrefs = await SharedPreferences.getInstance();
    final existingState = sharedPrefs.getInt(key);

    if (existingState == null) {
      sharedPrefs.setInt(
        key,
        settingsOptionPreferredStreamingQualityDefaultValue,
      );
    }

    return StreamingQuality.values[existingState ?? 0];
  }

  static Future<DownloadQuality> fetchPreferredDownloadQuality() async {
    final key = "$settingsOptionPreferredStreamingQuality:downloads";
    final sharedPrefs = await SharedPreferences.getInstance();
    final existingState = sharedPrefs.getInt(key);

    if (existingState == null) {
      sharedPrefs.setInt(
        key,
        settingsOptionPreferredStreamingQualityDefaultValue,
      );
    }

    return DownloadQuality.values[existingState ?? 0];
  }

  static Future<StreamingPreference> fetchPreferStreamingConnection() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final existingState = sharedPrefs.getInt(
      settingsOptionPreferStreamingOnConnection,
    );

    if (existingState == null) {
      sharedPrefs.setInt(
        settingsOptionPreferStreamingOnConnection,
        settingsOptionPreferStreamingOnConnectionDefaultValue,
      );
    }

    return StreamingPreference.values[existingState ?? 0];
  }

  static Future<bool> fetchPreferWifiDownloads() async {
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

    return existingState ?? true;
  }
}
