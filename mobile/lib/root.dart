import "package:flutter/material.dart";
import "package:wavelength/bloc/music_player/music_player_internals.dart";

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
    return Scaffold(resizeToAvoidBottomInset: false, body: widget.child);
  }
}
