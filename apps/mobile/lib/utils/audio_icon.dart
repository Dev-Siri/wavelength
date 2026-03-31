import "package:flutter/cupertino.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/audio/audio_device_service.dart";

IconData getAudioIcon(AudioDeviceType deviceType) {
  switch (deviceType) {
    case AudioDeviceType.wiredHeadphones:
    case AudioDeviceType.wiredHeadset:
      return LucideIcons.headphones;
    case AudioDeviceType.bluetooth:
      return LucideIcons.bluetooth;
    case AudioDeviceType.hdmi:
      return LucideIcons.hdmiPort;
    case AudioDeviceType.speaker:
      return LucideIcons.smartphone;
    case AudioDeviceType.usbDevice:
    case AudioDeviceType.usbHeadset:
      return LucideIcons.usb;
    default:
      return LucideIcons.audioLines;
  }
}

String getAudioIconLabel(AudioDeviceType deviceType) {
  switch (deviceType) {
    case AudioDeviceType.wiredHeadphones:
      return "Wired Headphones";
    case AudioDeviceType.wiredHeadset:
      return "Wired Headset";
    case AudioDeviceType.bluetooth:
      return "Bluetooth";
    case AudioDeviceType.speaker:
      return "Speaker";
    case AudioDeviceType.hdmi:
      return "HDMI";
    case AudioDeviceType.usbDevice:
      return "USB";
    case AudioDeviceType.usbHeadset:
      return "USB Headset";
    case AudioDeviceType.unknown:
      return "Audio Device";
    default:
      return "Unknown";
  }
}
