import "dart:async";

import "package:audio_service/audio_service.dart";
import "package:flutter/foundation.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:just_audio/just_audio.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/enums/stream_record_type.dart";
import "package:wavelength/api/models/enums/video_type.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/api/repositories/diagnostics_repo.dart";
import "package:wavelength/api/repositories/stream_repo.dart";
import "package:wavelength/api/repositories/track_repo.dart";
import "package:wavelength/audio/background_data_constructors.dart";
import "package:wavelength/audio/music_context_queue.dart";
import "package:wavelength/audio/queueable_music.dart";
import "package:wavelength/audio/stream_resolver.dart";

class TrackChangeEvent {
  final PlayableStreamMetadata? metadata;
  final QueueableMusic track;

  const TrackChangeEvent({required this.metadata, required this.track});
}

enum PlaybackSource { queue, context }

class WavelengthAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();

  late StreamResolver _streamResolver;

  List<int> _shuffledIndices = [];
  LoopMode _loopMode = LoopMode.off;
  bool _shuffleMode = false;
  final List<QueueableMusic> _queue = [];
  List<QueueableMusic> _automixedTracks = [];
  PlaybackSource _currentSource = PlaybackSource.context;

  final List<StreamSubscription> _subscriptions = [];
  final _playStateController = StreamController<bool>.broadcast();
  final _shuffleModeController = StreamController<bool>.broadcast();
  final _muteController = StreamController<bool>.broadcast();
  final _loopModeController = StreamController<LoopMode>.broadcast();
  final _timeController = StreamController<Duration>.broadcast();
  final _labelController = StreamController<String>.broadcast();
  final _automixController = StreamController<List<QueueableMusic>>.broadcast();
  final _contextQueueController =
      StreamController<List<QueueableMusic>>.broadcast();
  final _userQueueController =
      StreamController<List<QueueableMusic>>.broadcast();
  final _trackChangeController =
      StreamController<TrackChangeEvent?>.broadcast();

  Stream<bool> get onMuteChange => _muteController.stream;
  Stream<bool> get onPlaystateChange => _playStateController.stream;
  Stream<bool> get onShuffleModeChange => _shuffleModeController.stream;
  Stream<LoopMode> get onLoopModeChange => _loopModeController.stream;
  Stream<TrackChangeEvent?> get onTrackChange => _trackChangeController.stream;
  Stream<Duration> get onTimeChange => _timeController.stream;
  Stream<List<QueueableMusic>> get onContextQueueChange =>
      _contextQueueController.stream;
  Stream<String?> get onLabelChange => _labelController.stream;
  Stream<List<QueueableMusic>> get onUserQueueChange =>
      _userQueueController.stream;
  Stream<List<QueueableMusic>> get onAutomixQueueChange =>
      _automixController.stream;
  List<QueueableMusic> get contextQueue => _musicContextQueue.queue;
  List<int> get shuffledIndices => _shuffledIndices;
  String? get label => _musicContextQueue.sourceLabel;
  List<QueueableMusic> get userQueue => List.unmodifiable(_queue);
  List<QueueableMusic> get automixQueue => _automixedTracks;

  var _musicContextQueue = MusicContextQueue(
    type: MusicContextTypeNone(),
    queue: [],
    sourceLabel: null,
  );

  int? _playingNowIndex;
  bool _is30sReported = false;
  bool _isSwitchingTrack = false;
  int _automixIndex = 0;

  WavelengthAudioHandler(FlutterSecureStorage secureStorage) {
    _streamResolver = StreamResolver(secureStorage);
    _init();
  }

  void _init() {
    final errorSub = _player.errorStream.listen((error) async {
      DiagnosticsRepo.reportError(
        error: error.toString(),
        source: "(listener) just_audio: AudioPlayer.errorStream",
      );
    });

    final playerStateSub = _player.playerStateStream.listen((state) {
      _broadcastState();
      _playStateController.add(state.playing);
    });

    final processingStateSub = _player.processingStateStream
        .where((s) => s == ProcessingState.completed)
        .listen((_) async {
          _broadcastState();
          await _handlePlaybackEnd();
        });

    final positionSub = _player.positionStream.listen((position) async {
      _updateHotState();
      _timeController.add(position);

      if (position.inSeconds > 30 && !_is30sReported) {
        unawaited(
          StreamRepo.recordStream(
            track: _musicContextQueue.queue[_playingNowIndex!],
            type: StreamRecordType.play30s,
          ),
        );
        _is30sReported = true;
      }
    });

    _subscriptions.addAll([
      errorSub,
      playerStateSub,
      processingStateSub,
      positionSub,
    ]);
  }

  void _updateHotState() {
    final current = playbackState.value;

    playbackState.add(
      current.copyWith(
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
      ),
    );
  }

  void _broadcastState() => playbackState.add(
    PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        _player.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: mapProcessingState(_player.processingState),
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    ),
  );

  Future<void> _handlePlaybackEnd() async {
    switch (_player.loopMode) {
      case LoopMode.one:
        await _player.seek(Duration.zero);
        await _player.play();
        break;
      case LoopMode.all:
        QueueableMusic? next;

        if (_queue.isNotEmpty) {
          _currentSource = PlaybackSource.queue;
          next = _queue.removeAt(0);
        } else {
          _currentSource = PlaybackSource.context;
          next = _getNext();
        }

        if (next != null) {
          await _playSource(next);
        } else {
          await _player.seek(Duration.zero, index: 0);
        }
        await _player.play();
        break;
      case LoopMode.off:
        final next = _getNext();
        if (next != null) await _playSource(next);
        break;
    }
  }

  QueueableMusic? _getPrevious() {
    if (_playingNowIndex == null) return null;

    if (_shuffleMode) {
      final currentPos = _shuffledIndices.indexOf(_playingNowIndex!);

      final isFirst = currentPos == 0;

      if (isFirst) {
        if (_loopMode == LoopMode.all) {
          return _musicContextQueue.queue[_shuffledIndices.last];
        }
        return null;
      }

      final prevIndex = _shuffledIndices[currentPos - 1];
      _playingNowIndex = prevIndex;
      return _musicContextQueue.queue[prevIndex];
    }

    final isOnlyElement = _musicContextQueue.queue.length == 1;

    if (isOnlyElement) {
      return _musicContextQueue.queue[0];
    }

    final isFirstItem = _playingNowIndex == 0;
    final isLoopingToEnd = isFirstItem && _loopMode == LoopMode.all;

    if (isLoopingToEnd) {
      return _musicContextQueue.queue.last;
    }

    final currentIndex = _playingNowIndex ?? 0;

    if (currentIndex <= 0) {
      if (_loopMode == LoopMode.all) {
        _playingNowIndex = _musicContextQueue.queue.length - 1;
        return _musicContextQueue.queue.last;
      }
      return null;
    }

    _playingNowIndex = currentIndex - 1;
    return _musicContextQueue.queue[_playingNowIndex!];
  }

  QueueableMusic? _getNext() {
    if (_playingNowIndex == null) return null;

    if (_shuffleMode) {
      final currentPos = _shuffledIndices.indexOf(_playingNowIndex!);
      final isLast = currentPos == _shuffledIndices.length - 1;

      if (isLast) {
        if (_automixedTracks.isNotEmpty) {
          if (_automixIndex >= _automixedTracks.length) return null;

          if (_automixedTracks.length - _automixIndex < 3) {
            unawaited(_automixTracks());
          }

          final track = _automixedTracks[_automixIndex];
          _automixIndex++;

          return track;
        }

        if (_loopMode == LoopMode.all) {
          return _musicContextQueue.queue[_shuffledIndices[0]];
        }

        return null;
      }

      final nextIndex = _shuffledIndices[currentPos + 1];
      _playingNowIndex = nextIndex;
      return _musicContextQueue.queue[nextIndex];
    }

    final isOnlyElement = _musicContextQueue.queue.length == 1;
    final isLastItem =
        _musicContextQueue.queue.length == (_playingNowIndex ?? 0) + 1;
    final isLoopingToStart = isLastItem && _loopMode == LoopMode.all;

    if (isOnlyElement || isLoopingToStart) {
      return _musicContextQueue.queue[0];
    }

    if (isLastItem && _loopMode == LoopMode.off) {
      if (_automixedTracks.isNotEmpty) {
        if (_automixIndex >= _automixedTracks.length) return null;

        if (_automixedTracks.length - _automixIndex < 3) {
          unawaited(_automixTracks());
        }

        final track = _automixedTracks[_automixIndex];
        _automixIndex++;

        return track;
      }
      return null;
    }

    _playingNowIndex = (_playingNowIndex ?? 0) + 1;
    return _musicContextQueue.queue[_playingNowIndex ?? 0];
  }

  void _generateShuffleOrder() {
    _shuffledIndices = List.generate(_musicContextQueue.queue.length, (i) => i)
      ..shuffle();

    if (_playingNowIndex != null) {
      _shuffledIndices.remove(_playingNowIndex);
      _shuffledIndices.insert(0, _playingNowIndex!);
    }
  }

  Future<void> _playSource(QueueableMusic queueableMusic) async {
    if (_isSwitchingTrack) return;
    _isSwitchingTrack = true;
    _is30sReported = false;

    try {
      await _player.clearAudioSources();

      mediaItem.add(constructMediaItem(queueableMusic));
      _trackChangeController.add(
        TrackChangeEvent(track: queueableMusic, metadata: null),
      );

      final stream = await _streamResolver.fetchStreamSource(
        queueableMusic,
        null,
      );
      unawaited(_preloadNext());
      _trackChangeController.add(
        TrackChangeEvent(track: queueableMusic, metadata: stream.metadata),
      );
      unawaited(
        StreamRepo.recordStream(
          track: queueableMusic,
          type: StreamRecordType.playStart,
        ),
      );
      await _player.setAudioSource(
        AudioSource.uri(stream.source, tag: constructMediaItem(queueableMusic)),
      );
      await _player.play();
    } finally {
      _isSwitchingTrack = false;
    }
  }

  Future<void> _preloadNext() async {
    try {
      final next = _peekNext();
      if (next == null) return;

      unawaited(_streamResolver.fetchStreamSource(next, null));
    } catch (_) {
      //
    }
  }

  QueueableMusic? _peekNext() {
    if (_playingNowIndex == null) return null;

    if (_shuffleMode) {
      final currentPos = _shuffledIndices.indexOf(_playingNowIndex!);
      final isLast = currentPos == _shuffledIndices.length - 1;

      if (isLast) {
        if (_automixedTracks.isNotEmpty) {
          if (_automixIndex >= _automixedTracks.length) return null;
          return _automixedTracks[_automixIndex];
        }

        if (_loopMode == LoopMode.all) {
          return _musicContextQueue.queue[_shuffledIndices[0]];
        }

        return null;
      }

      final nextIndex = _shuffledIndices[currentPos + 1];
      return _musicContextQueue.queue[nextIndex];
    }

    final isOnlyElement = _musicContextQueue.queue.length == 1;
    final isLastItem =
        _musicContextQueue.queue.length == (_playingNowIndex ?? 0) + 1;
    final isLoopingToStart = isLastItem && _loopMode == LoopMode.all;

    if (isOnlyElement || isLoopingToStart) {
      return _musicContextQueue.queue[0];
    }

    if (isLastItem && _loopMode == LoopMode.off) {
      if (_automixedTracks.isNotEmpty) {
        if (_automixIndex >= _automixedTracks.length) return null;
        return _automixedTracks[_automixIndex];
      }
      return null;
    }

    return _musicContextQueue.queue[(_playingNowIndex ?? 0) + 1];
  }

  Future<void> _automixTracks() async {
    try {
      QueueableMusic? trackForAutomix;

      final searchQueue = _musicContextQueue.queue.isEmpty
          ? _queue.reversed
          : _musicContextQueue.queue.reversed;
      for (final track in searchQueue) {
        if (track.videoType == VideoType.track) {
          trackForAutomix = track;
          break;
        }
      }

      if (trackForAutomix == null &&
          _musicContextQueue.queue[_playingNowIndex!].videoType ==
              VideoType.track) {
        trackForAutomix = _musicContextQueue.queue[_playingNowIndex!];
      }

      if (trackForAutomix == null) return;

      final response = await TrackRepo.fetchUpNextTracks(
        videoId: trackForAutomix.videoId,
      );

      if (response is! ApiResponseSuccess<List<Track>>) return;

      final existing = _automixedTracks;
      final incoming = (response).data.skip(1).map((track) {
        return QueueableMusic(
          videoId: track.videoId,
          title: track.title,
          thumbnail: track.thumbnail,
          duration: track.duration,
          artists: track.artists,
          album: track.album,
          videoType: VideoType.track,
          isExplicit: track.isExplicit,
        );
      }).toList();

      final seen = <String>{};
      final merged = [...existing, ...incoming];

      final deduped = merged.where((track) {
        if (seen.contains(track.videoId)) return false;
        seen.add(track.videoId);
        return true;
      }).toList();

      _automixedTracks = deduped;
      _automixIndex = 0;
      _automixController.add(_automixedTracks);
    } catch (_) {
      //
    }
  }

  Future<void> playQueue(
    MusicContextType context,
    List<QueueableMusic> tracks,
    QueueableMusic track, {
    String? sourceLabel,
  }) async {
    if (_musicContextQueue.type != context ||
        !listEquals(_musicContextQueue.queue, tracks)) {
      _automixedTracks = [];
      _automixController.add(_automixedTracks);
      _musicContextQueue = MusicContextQueue(
        type: context,
        queue: tracks,
        sourceLabel: sourceLabel,
      );

      if (_musicContextQueue.type is MusicContextTypeNone ||
          ((_musicContextQueue.type is MusicContextTypePlaylist ||
                  _musicContextQueue.type is MusicContextTypeArtistTopSongs) &&
              _loopMode == LoopMode.off)) {
        unawaited(_automixTracks());
      }

      _contextQueueController.add(_musicContextQueue.queue);
    }

    _playingNowIndex = tracks.indexWhere(
      (trackInList) => trackInList.videoId == track.videoId,
    );

    if (_shuffleMode) _generateShuffleOrder();
    return _playSource(track);
  }

  void setShuffleEnabled(bool enabled) {
    _shuffleMode = enabled;

    if (enabled) {
      _generateShuffleOrder();
    } else {
      _shuffledIndices.clear();
    }

    _shuffleModeController.add(enabled);
  }

  void toggleShuffleEnabled() => setShuffleEnabled(!_shuffleMode);

  Future<void> setLoopMode(LoopMode loopMode) async {
    _loopMode = loopMode;
    _loopModeController.add(loopMode);
    await _player.setLoopMode(loopMode);
  }

  Future<void> cycleLoopMode() async {
    switch (_loopMode) {
      case LoopMode.off:
        unawaited(_automixTracks());
        return setLoopMode(LoopMode.all);
      case LoopMode.all:
        return setLoopMode(LoopMode.one);
      case LoopMode.one:
        return setLoopMode(LoopMode.off);
    }
  }

  Future<void> mute() async {
    _muteController.add(true);
    await _player.setVolume(0);
  }

  Future<void> unMute() async {
    _muteController.add(false);
    await _player.setVolume(1);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    QueueableMusic? next;

    if (_currentSource == PlaybackSource.queue) {
      if (_queue.isNotEmpty) {
        next = _queue.removeAt(0);
      } else {
        _currentSource = PlaybackSource.context;
        next = _getNext();
      }
    } else {
      if (_queue.isNotEmpty) {
        _currentSource = PlaybackSource.queue;
        next = _queue.removeAt(0);
      } else {
        next = _getNext();
      }
    }

    if (next != null) {
      await _playSource(next);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    final prev = _getPrevious();
    if (prev != null) {
      _playSource(prev);
    }
  }

  @override
  Future<void> stop() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }

    _playStateController.close();
    _shuffleModeController.close();
    _muteController.close();
    _loopModeController.close();
    _timeController.close();
    _labelController.close();
    _automixController.close();
    _contextQueueController.close();
    _userQueueController.close();
    _trackChangeController.close();

    await _player.dispose();

    return super.stop();
  }

  void addToQueue(QueueableMusic track) {
    _queue.add(track);
    _userQueueController.add(_queue);
  }

  void addNext(QueueableMusic track) {
    _queue.insert(0, track);
    _userQueueController.add(_queue);
  }

  void addAllToQueue(List<QueueableMusic> tracks) {
    _queue.addAll(tracks);
    _userQueueController.add(_queue);
  }

  void removeFromQueue(QueueableMusic track) {
    _queue.removeWhere((t) => t.videoId == track.videoId);
    _userQueueController.add(_queue);
  }

  void clearQueue() {
    _queue.clear();
    _userQueueController.add(_queue);
  }
}
