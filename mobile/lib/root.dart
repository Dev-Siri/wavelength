import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_state.dart";
import "package:wavelength/bloc/music_player/music_player_internals.dart";
import "package:wavelength/widgets/floating_music_player_preview.dart";

class Root extends StatefulWidget {
  final String uri;
  final Widget child;

  const Root({super.key, required this.uri, required this.child});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  final _musicPlayerInternals = MusicPlayerInternals();

  @override
  void initState() {
    super.initState();
    _musicPlayerInternals.init(context);
  }

  @override
  void dispose() {
    _musicPlayerInternals.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stringUri = widget.uri.toString();
    final isOutsideAppShell =
        stringUri.startsWith("/artist") || stringUri.startsWith("/playlist");
    final isOnPlayingNowScreen = stringUri.startsWith("/playing-now");

    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          Center(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: isOutsideAppShell
                      ? MediaQuery.of(context).size.height * 0.05
                      : MediaQuery.of(context).size.height * 0.125,
                ),
                child: BlocBuilder<AppBottomSheetBloc, AppBottomSheetState>(
                  builder: (context, state) {
                    if (!isOnPlayingNowScreen &&
                        state is AppBottomSheetClosedState) {
                      return FloatingMusicPlayerPreview();
                    }

                    return SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
