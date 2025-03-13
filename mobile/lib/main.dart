import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
// import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/location/location_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_bloc.dart";
// import "package:wavelength/constants.dart";
import "package:wavelength/router.dart";

Future<void> main() async {
  // await dotenv.load(fileName: envFile);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MusicPlayerBloc()),
        BlocProvider(
          create:
              (_) => AuthBloc(
                GoogleSignIn(scopes: ["email", "profile"]),
                FlutterSecureStorage(),
              ),
        ),
        BlocProvider(create: (_) => LocationBloc()),
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
        ),
      ),
    );
  }
}
