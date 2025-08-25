import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:wavelength/api/models/adapters/playlist_adapter.dart";
import "package:wavelength/api/models/adapters/playlist_track_adapter.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/library/library_bloc.dart";
import "package:wavelength/bloc/location/location_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_duration/music_player_duration_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_playstate/music_player_playstate_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_track/music_player_track_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_volume/music_player_volume_bloc.dart";
import "package:wavelength/bloc/quick_picks/quick_picks_bloc.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/router.dart";

Future<void> main() async {
  await dotenv.load(fileName: envFile);

  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(PlaylistTrackAdapter());
  Hive.registerAdapter(PlaylistAdapter());

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // MusicPlayer blocs
        BlocProvider(create: (_) => MusicPlayerDurationBloc()),
        BlocProvider(create: (_) => MusicPlayerPlaystateBloc()),
        BlocProvider(create: (_) => MusicPlayerTrackBloc()),
        BlocProvider(create: (_) => MusicPlayerVolumeBloc()),
        //
        BlocProvider(create: (_) => QuickPicksBloc()),
        BlocProvider(create: (_) => LocationBloc()),
        BlocProvider(create: (_) => LibraryBloc()),
        BlocProvider(
          create:
              (_) => AuthBloc(
                GoogleSignIn(
                  serverClientId:
                      Platform.isAndroid
                          ? dotenv.get("ANDROID_GOOGLE_CLIENT_ID")
                          : null,
                  clientId:
                      Platform.isIOS
                          ? dotenv.get("IOS_GOOGLE_CLIENT_ID")
                          : null,
                  scopes: ["email", "profile"],
                ),
                FlutterSecureStorage(),
              ),
        ),
      ],
      child: MaterialApp.router(
        title: "Wavelength",
        routerConfig: router,
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          colorScheme: ColorScheme.dark(),
          primaryColor: Colors.white,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: AppBarTheme(backgroundColor: Colors.black),
          fontFamily: "Geist",
          fontFamilyFallback: ["AppleColorEmoji", "NotoColorEmoji"],
        ),
      ),
    );
  }
}
