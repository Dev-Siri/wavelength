import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/audio_device/audio_device_event.dart";
import "package:wavelength/bloc/audio_device/audio_device_state.dart";

class AudioDeviceBloc extends Bloc<AudioDeviceEvent, AudioDeviceState> {
  AudioDeviceBloc() : super(AudioDeviceInitialState()) {
    on<AudioDeviceUpdateEvent>(_updateDevice);
  }

  void _updateDevice(
    AudioDeviceUpdateEvent event,
    Emitter<AudioDeviceState> emit,
  ) => emit(AudioDeviceAvailableState(device: event.device));
}
