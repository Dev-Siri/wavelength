import "dart:io";

import "package:audio_service/audio_service.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:wavelength/audio/wavelength_audio_handler.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/audio_device/audio_device_bloc.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/cover_effect_colors/cover_effect_colors_bloc.dart";
import "package:wavelength/bloc/download/download_bloc.dart";
import "package:wavelength/bloc/downloaded_tracks/downloaded_tracks_bloc.dart";
import "package:wavelength/bloc/library/library_bloc.dart";
import "package:wavelength/bloc/likes/like_count/like_count_bloc.dart";
import "package:wavelength/bloc/location/location_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_repeat_mode/music_player_repeat_mode_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_shuffle_mode/music_player_shuffle_mode_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_volume/music_player_volume_bloc.dart";
import "package:wavelength/bloc/playlist/playlist_bloc.dart";
import "package:wavelength/bloc/playlist_length/playlist_length_bloc.dart";
import "package:wavelength/bloc/quick_picks/quick_picks_bloc.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/hive_adapters_registrar.dart";
import "package:wavelength/src/rust/frb_generated.dart";
import "package:wavelength/router.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class AppLifecycleHandler extends WidgetsBindingObserver {
  final AudioHandler handler;

  AppLifecycleHandler(this.handler);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      handler.stop();
    }
  }
}

late WavelengthAudioHandler _audioHandler;
late FlutterSecureStorage _secureStorage;

Future<void> main() async {
  await dotenv.load(fileName: envFile);

  WidgetsFlutterBinding.ensureInitialized();
  _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  await Hive.initFlutter();
  registerHiveAdapters();

  _audioHandler = await AudioService.init(
    builder: () => WavelengthAudioHandler(_secureStorage),
    config: const AudioServiceConfig(
      androidNotificationChannelId: "dev.siri.wavelength.channel.audio",
      androidNotificationChannelName: "Wavelength",
      androidNotificationIcon: "drawable/ic_launcher_foreground",
      androidStopForegroundOnPause: false,
      preloadArtwork: true,
    ),
  );

  WidgetsBinding.instance.addObserver(AppLifecycleHandler(_audioHandler));

  await RustLib.init();
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<WavelengthAudioHandler>.value(value: _audioHandler),
        RepositoryProvider<FlutterSecureStorage>.value(value: _secureStorage),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final audioHandler = context.read<WavelengthAudioHandler>();

    return MultiBlocProvider(
      providers: [
        // MusicPlayer blocs
        BlocProvider(create: (_) => MusicPlayerDurationBloc(_audioHandler)),
        BlocProvider(create: (_) => MusicPlayerPlaystateBloc(audioHandler)),
        BlocProvider(create: (_) => MusicPlayerTrackBloc(audioHandler)),
        BlocProvider(create: (_) => MusicPlayerShuffleModeBloc()),
        BlocProvider(create: (_) => MusicPlayerVolumeBloc(_audioHandler)),
        BlocProvider(create: (_) => MusicPlayerRepeatModeBloc()),
        // Playlist blocs
        BlocProvider(create: (_) => PlaylistBloc()),
        BlocProvider(create: (_) => PlaylistLengthBloc()),
        //
        BlocProvider(create: (_) => DownloadBloc(_secureStorage)),
        BlocProvider(create: (_) => AppBottomSheetBloc()),
        BlocProvider(create: (_) => QuickPicksBloc(_secureStorage)),
        BlocProvider(create: (_) => LocationBloc()),
        BlocProvider(create: (_) => LibraryBloc()),
        BlocProvider(create: (_) => LikeCountBloc()),
        BlocProvider(create: (_) => AudioDeviceBloc()),
        BlocProvider(create: (_) => CoverEffectColorsBloc()),
        BlocProvider(create: (_) => DownloadedTracksBloc()),
        BlocProvider(
          create: (_) => AuthBloc(
            GoogleSignIn(
              serverClientId: dotenv.get("WEB_GOOGLE_CLIENT_ID"),
              clientId: Platform.isIOS
                  ? dotenv.get("IOS_GOOGLE_CLIENT_ID")
                  : null,
              scopes: ["email", "profile"],
            ),
            context.read<FlutterSecureStorage>(),
          ),
        ),
      ],
      child: AmplApp.router(routerConfig: router),
    );
  }
}
