import "package:flutter/foundation.dart";
import "package:wavelength/audio/audio_device_service.dart";

@immutable
sealed class AudioDeviceState {}

class AudioDeviceInitialState extends AudioDeviceState {}

class AudioDeviceAvailableState extends AudioDeviceState {
  final AudioDevice device;

  AudioDeviceAvailableState({required this.device});
}
