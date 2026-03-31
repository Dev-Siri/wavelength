import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:mini_music_visualizer/mini_music_visualizer.dart";
import "package:vector_graphics/vector_graphics.dart";
import "package:wavelength/audio/audio_device_service.dart";
import "package:wavelength/bloc/audio_device/audio_device_bloc.dart";
import "package:wavelength/bloc/audio_device/audio_device_state.dart";
import "package:wavelength/utils/audio_icon.dart";
import "package:wavelength/widgets/animations/shimmer_animation.dart";
import "package:wavelength/widgets/ui/ampl_button.dart";
import "package:wavelength/widgets/ui/ampl_list_tile.dart";

class DevicesBottomSheet extends StatefulWidget {
  const DevicesBottomSheet({super.key});

  @override
  State<DevicesBottomSheet> createState() => _DevicesBottomSheetState();
}

class _DevicesBottomSheetState extends State<DevicesBottomSheet> {
  List<AudioDevice> _availableDevices = [];

  @override
  void initState() {
    super.initState();
    _fetchAvailableDevices();
  }

  Future<void> _fetchAvailableDevices() async {
    final availableDevices = await AudioDeviceService.getAllDevices();
    setState(() => _availableDevices = availableDevices);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AudioDeviceBloc, AudioDeviceState>(
      listener: (context, state) {
        _fetchAvailableDevices();
      },
      builder: (context, state) {
        if (state is! AudioDeviceAvailableState) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.only(top: 5),
          height: MediaQuery.sizeOf(context).height / 2,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 6, top: 4),
                child: SvgPicture(
                  AssetBytesLoader("assets/vectors/wavelength-connect.svg.vec"),
                  height: 60,
                ),
              ),
              ..._availableDevices.map(
                (device) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Material(
                    borderRadius: BorderRadius.circular(10),
                    clipBehavior: Clip.antiAlias,
                    color: Colors.grey.shade900,
                    child: AmplListTile(
                      leading: Icon(getAudioIcon(device.type), size: 20),
                      backgroundColor: Colors.grey.shade900,
                      title:
                          state.device.name == device.name &&
                              state.device.type == device.type
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const MiniMusicVisualizer(
                                  color: Colors.white,
                                  animate: true,
                                  width: 4,
                                  height: 15,
                                ),
                                const SizedBox(width: 4),
                                ShimmerAnimation(
                                  child: Text(
                                    device.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              device.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      subtitle: Text(
                        getAudioIconLabel(device.type),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AmplButton(
                    onPressed: () => AudioDeviceService.openBluetoothSettings(),
                    color: Colors.grey.shade800,
                    padding: const EdgeInsets.all(8),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.bluetooth, size: 15),
                        SizedBox(width: 6),
                        Text("Bluetooth", style: TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
