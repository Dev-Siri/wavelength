import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/music_player/music_player_bloc.dart";
import "package:wavelength/router.dart";

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => MusicPlayerBloc()),
        BlocProvider(create: (context) => AuthBloc()),
      ],
      child: MaterialApp.router(
        title: "Wavelength",
        routerConfig: router,
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          colorScheme: ColorScheme.dark(),
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: AppBarTheme(backgroundColor: Colors.black),
          fontFamily: "Geist",
        ),
      ),
    );
  }
}
