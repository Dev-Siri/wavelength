import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/location/location_bloc.dart";
import "package:wavelength/bloc/location/location_state.dart";
import "package:wavelength/bloc/quick_picks/quick_picks_bloc.dart";
import "package:wavelength/bloc/quick_picks/quick_picks_event.dart";
import "package:wavelength/bloc/quick_picks/quick_picks_state.dart";
import "package:wavelength/widgets/error_message_dialog.dart";
import "package:wavelength/widgets/quick_pick_song_card.dart";
import "package:wavelength/widgets/skeletons/quick_pick_song_card_skeleton.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: BlocConsumer<LocationBloc, LocationState>(
        listener: (context, state) {
          context.read<QuickPicksBloc>().add(
            QuickPicksFetchEvent(locale: state.countryCode),
          );
        },
        builder: (context, state) {
          return RefreshIndicator.adaptive(
            onRefresh:
                () async => context.read<QuickPicksBloc>().add(
                  QuickPicksFetchEvent(locale: state.countryCode),
                ),
            child: ListView(
              children: [
                BlocConsumer<QuickPicksBloc, QuickPicksState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    if (state is! QuickPicksSuccessState) {
                      return Stack(
                        children: [
                          Wrap(
                            children: [
                              for (int i = 0; i < 8; i++)
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: QuickPickSongCardSkeleton(),
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

                    return Wrap(
                      children: [
                        for (final song in state.songs)
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: QuickPickSongCard(quickPicksItem: song),
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
