import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/audio/queueable_music.dart";
import "package:wavelength/audio/wavelength_audio_handler.dart";
import "package:wavelength/utils/toaster.dart";
import "package:wavelength/widgets/track/track_tile.dart";

class MusicQueueDisplay extends StatefulWidget {
  const MusicQueueDisplay({super.key});

  @override
  State<MusicQueueDisplay> createState() => _MusicQueueDisplayState();
}

class _MusicQueueDisplayState extends State<MusicQueueDisplay> with Toaster {
  List<QueueableMusic> _userQueue = [];
  List<QueueableMusic> _contextQueue = [];
  List<QueueableMusic> _automixQueue = [];
  String? _sourceLabel;

  List<StreamSubscription> queueSubscriptions = [];

  @override
  void initState() {
    super.initState();

    if (!mounted) return;

    final audioHandler = context.read<WavelengthAudioHandler>();

    setState(() {
      _userQueue = audioHandler.userQueue;
      _contextQueue = audioHandler.contextQueue;
      _automixQueue = audioHandler.automixQueue;
      _sourceLabel = audioHandler.label;
    });

    final userQueueSub = audioHandler.onUserQueueChange.listen((songList) {
      setState(() => _userQueue = songList);
    });
    final contextQueueSub = audioHandler.onContextQueueChange.listen((
      songList,
    ) {
      setState(() => _contextQueue = songList);
    });
    final labelSub = audioHandler.onLabelChange.listen((label) {
      setState(() => _sourceLabel = label);
    });
    final automixSub = audioHandler.onAutomixQueueChange.listen((songList) {
      setState(() => _automixQueue = songList);
    });

    queueSubscriptions.addAll([
      userQueueSub,
      contextQueueSub,
      labelSub,
      automixSub,
    ]);
  }

  @override
  void dispose() {
    for (final subscription in queueSubscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      height: MediaQuery.sizeOf(context).height * 0.9,
      width: MediaQuery.sizeOf(context).width,
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 15, top: 15, bottom: 10),
              child: Text(
                "Queue",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final song = _userQueue[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Dismissible(
                  onDismissed: (direction) {
                    context.read<WavelengthAudioHandler>().removeFromQueue(
                      song,
                    );
                    showToast(
                      context,
                      "Removed ${song.title} from queue.",
                      ToastType.info,
                    );
                  },
                  key: ValueKey(song.videoId),
                  child: TrackTile(
                    key: ValueKey(song.videoId),
                    sourceLabel: _sourceLabel,
                    track: Track(
                      videoId: song.videoId,
                      title: song.title,
                      thumbnail: song.thumbnail,
                      artists: song.artists,
                      duration: song.duration,
                      isExplicit: song.isExplicit,
                      album: song.album,
                    ),
                    tracks: _userQueue,
                  ),
                ),
              );
            }, childCount: _userQueue.length),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 10),
              child: Text(
                _sourceLabel == null
                    ? "Playing Now"
                    : "Playing from: $_sourceLabel",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final song = _contextQueue[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TrackTile(
                  key: ValueKey(song.videoId),
                  sourceLabel: _sourceLabel,
                  track: Track(
                    videoId: song.videoId,
                    title: song.title,
                    thumbnail: song.thumbnail,
                    artists: song.artists,
                    duration: song.duration,
                    isExplicit: song.isExplicit,
                    album: song.album,
                  ),
                  tracks: _contextQueue,
                ),
              );
            }, childCount: _contextQueue.length),
          ),
          if (_automixQueue.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(left: 15, bottom: 10),
                child: Text(
                  "Up next",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final song = _automixQueue[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TrackTile(
                  key: ValueKey(song.videoId),
                  sourceLabel: _sourceLabel,
                  track: Track(
                    videoId: song.videoId,
                    title: song.title,
                    thumbnail: song.thumbnail,
                    artists: song.artists,
                    duration: song.duration,
                    isExplicit: song.isExplicit,
                    album: song.album,
                  ),
                  tracks: _automixQueue,
                ),
              );
            }, childCount: _automixQueue.length),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: kBottomNavigationBarHeight),
          ),
        ],
      ),
    );
  }
}
