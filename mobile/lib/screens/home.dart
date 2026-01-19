import "dart:math" as math;
import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:vector_graphics/vector_graphics.dart";
import "package:wavelength/bloc/library/library_bloc.dart";
import "package:wavelength/bloc/library/library_state.dart";
import "package:wavelength/bloc/location/location_bloc.dart";
import "package:wavelength/bloc/location/location_state.dart";
import "package:wavelength/bloc/quick_picks/quick_picks_bloc.dart";
import "package:wavelength/bloc/quick_picks/quick_picks_event.dart";
import "package:wavelength/bloc/quick_picks/quick_picks_state.dart";
import "package:wavelength/widgets/error_message_dialog.dart";
import "package:wavelength/widgets/followed_artists_carousel.dart";
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
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: BlocBuilder<LibraryBloc, LibraryState>(
              builder: (context, state) {
                if (state is! LibraryFetchSuccessState) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 10, top: 5, bottom: 10),
                      child: Text(
                        "Your Follows",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    FollowedArtistsCarousel(follows: state.followedArtists),
                  ],
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: BlocConsumer<LocationBloc, LocationState>(
              listener: _locationListener,
              builder: (context, state) {
                return Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                          child: Text(
                            "Popular Picks",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    BlocBuilder<QuickPicksBloc, QuickPicksState>(
                      builder: (context, state) {
                        if (state is QuickPicksLoadingState ||
                            state is QuickPicksErrorState) {
                          return Stack(
                            children: [
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  for (int i = 0; i < 8; i++)
                                    SizedBox(
                                      width:
                                          (MediaQuery.sizeOf(context).width -
                                              20) /
                                          2,
                                      child: const Padding(
                                        padding: EdgeInsets.all(5),
                                        child: QuickPickSongCardSkeleton(),
                                      ),
                                    ),
                                ],
                              ),
                              if (state is QuickPicksErrorState)
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      top:
                                          MediaQuery.sizeOf(context).height / 3,
                                    ),
                                    child: const ErrorMessageDialog(
                                      message:
                                          "Something went wrong while trying to fetch your feed.",
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }

                        if (state is QuickPicksDefaultState ||
                            state is! QuickPicksSuccessState ||
                            state.quickPicks.isEmpty) {
                          return SizedBox(
                            height: MediaQuery.sizeOf(context).height / 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const SvgPicture(
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
                                        child: const Text(
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
                                  offset: const Offset(0, -20),
                                  child: const Text(
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
                            for (final song in state.quickPicks)
                              SizedBox(
                                width:
                                    (MediaQuery.sizeOf(context).width - 20) / 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(7.5),
                                  child: QuickPickSongCard(
                                    quickPicksItem: song,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
