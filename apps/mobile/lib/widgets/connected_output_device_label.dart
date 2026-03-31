import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/audio/audio_device_service.dart";
import "package:wavelength/bloc/audio_device/audio_device_bloc.dart";
import "package:wavelength/bloc/audio_device/audio_device_state.dart";
import "package:wavelength/widgets/animations/shimmer_animation.dart";
import "package:wavelength/widgets/bottom_sheets/devices_bottom_sheet.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class ConnectedOutputDeviceLabel extends StatelessWidget {
  const ConnectedOutputDeviceLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioDeviceBloc, AudioDeviceState>(
      builder: (context, state) {
        if (state is! AudioDeviceAvailableState) {
          return const SizedBox.shrink();
        }

        return AmplIconButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            builder: (_) => const DevicesBottomSheet(),
          ),
          padding: EdgeInsets.zero,
          icon: state.device.type != AudioDeviceType.speaker
              ? const ShimmerAnimation(
                  duration: Duration(seconds: 1),
                  child: Icon(LucideIcons.monitorSpeaker),
                )
              : const Icon(LucideIcons.monitorSpeaker),
        );
      },
    );
  }
}
