import "package:flutter/foundation.dart";
import "package:wavelength/audio/audio_device_service.dart";

@immutable
sealed class AudioDeviceEvent {}

class AudioDeviceUpdateEvent extends AudioDeviceEvent {
  final AudioDevice device;

  AudioDeviceUpdateEvent({required this.device});
}
