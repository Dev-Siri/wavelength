import "dart:math" as math;
import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:vector_graphics/vector_graphics.dart";
import "package:wavelength/bloc/location/location_bloc.dart";
import "package:wavelength/bloc/location/location_state.dart";
import "package:wavelength/bloc/quick_picks/quick_picks_bloc.dart";
import "package:wavelength/bloc/quick_picks/quick_picks_event.dart";
import "package:wavelength/bloc/quick_picks/quick_picks_state.dart";
import "package:wavelength/widgets/error_message_dialog.dart";
import "package:wavelength/widgets/quick_pick_song_card.dart";
import "package:wavelength/widgets/skeletons/quick_pick_song_card_skeleton.dart";

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _locationListener(
    BuildContext context,
    LocationState state,
  ) async {
    final quickPicksBloc = context.read<QuickPicksBloc>();
    final connectivityStatus = await Connectivity().checkConnectivity();

    if (connectivityStatus.contains(ConnectivityResult.wifi)) {
      quickPicksBloc.add(QuickPicksFetchEvent(locale: state.countryCode));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: BlocConsumer<LocationBloc, LocationState>(
        listener: _locationListener,
        builder: (context, state) {
          return RefreshIndicator.adaptive(
            onRefresh: () async => context.read<QuickPicksBloc>().add(
              QuickPicksFetchEvent(locale: state.countryCode),
            ),
            child: ListView(
              children: [
                BlocBuilder<QuickPicksBloc, QuickPicksState>(
                  builder: (context, state) {
                    if (state is! QuickPicksSuccessState) {
                      return Stack(
                        children: [
                          Wrap(
                            children: [
                              for (int i = 0; i < 8; i++)
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width - 20) /
                                      2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: QuickPickSongCardSkeleton(),
                                  ),
                                ),
                            ],
                          ),
                          if (state is QuickPicksErrorState)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height / 3,
                                ),
                                child: ErrorMessageDialog(
                                  message:
                                      "Something went wrong while trying to fetch your feed.",
                                ),
                              ),
                            ),
                        ],
                      );
                    }

                    if (state.songs.isEmpty) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height / 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SvgPicture(
                                  AssetBytesLoader(
                                    "assets/vectors/lambda.svg.vec",
                                  ),
                                  height: 200,
                                  width: 200,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 70,
                                    bottom: 100,
                                  ),
                                  child: Transform.rotate(
                                    angle: math.pi / 12,
                                    child: Text(
                                      "?",
                                      style: TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Transform.translate(
                              offset: Offset(0, -20),
                              child: Text(
                                "Swipe down on the screen.",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Wrap(
                      children: [
                        for (final song in state.songs)
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 20) / 2,
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: QuickPickSongCard(quickPicksItem: song),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}
