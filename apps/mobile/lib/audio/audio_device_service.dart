import "dart:async";
import "package:flutter/services.dart";

enum AudioDeviceType {
  speaker,
  bluetooth,
  wiredHeadset,
  wiredHeadphones,
  hdmi,
  usbDevice,
  usbHeadset,
  other,
  unknown,
}

class AudioDevice {
  final String name;
  final AudioDeviceType type;
  final int? id;

  const AudioDevice({required this.name, required this.type, this.id});

  factory AudioDevice.fromMap(Map<dynamic, dynamic> map) {
    return AudioDevice(
      name: map["name"] ?? "Unknown",
      type: _parseType(map["type"]),
      id: int.tryParse(map["id"]?.toString() ?? "null"),
    );
  }

  static AudioDeviceType _parseType(String? type) {
    switch (type) {
      case "speaker":
        return AudioDeviceType.speaker;
      case "bluetooth":
        return AudioDeviceType.bluetooth;
      case "wiredHeadset":
        return AudioDeviceType.wiredHeadset;
      case "wiredHeadphones":
        return AudioDeviceType.wiredHeadphones;
      case "usbDevice":
        return AudioDeviceType.usbDevice;
      case "usbHeadset":
        return AudioDeviceType.usbHeadset;
      case "hdmi":
        return AudioDeviceType.hdmi;
      case "other":
        return AudioDeviceType.other;
      default:
        return AudioDeviceType.unknown;
    }
  }

  @override
  String toString() => "$name ($type)";
}

class AudioDeviceService {
  static const MethodChannel _channel = MethodChannel(
    "siri.dev.wavelength/audio_output",
  );

  static const EventChannel _eventChannel = EventChannel(
    "siri.dev.wavelength/audio_output_events",
  );

  static Future<AudioDevice> getCurrentDevice() async {
    try {
      final map = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        "getCurrentDevice",
      );
      if (map == null) {
        return const AudioDevice(
          name: "Unknown",
          type: AudioDeviceType.unknown,
        );
      }

      return AudioDevice.fromMap(map);
    } catch (e) {
      return const AudioDevice(name: "Error", type: AudioDeviceType.unknown);
    }
  }

  static Future<List<AudioDevice>> getAllDevices() async {
    try {
      final List<dynamic>? devices = await _channel.invokeMethod<List<dynamic>>(
        "getAllDevices",
      );
      if (devices == null) return [];
      return devices
          .map((d) => AudioDevice.fromMap(Map<dynamic, dynamic>.from(d)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Stream<AudioDevice> get onDeviceChanged {
    return _eventChannel.receiveBroadcastStream().map(
      (event) => AudioDevice.fromMap(Map<dynamic, dynamic>.from(event)),
    );
  }

  static Future<void> openBluetoothSettings() async {
    await _channel.invokeMethod('openBluetoothSettings');
  }
}
