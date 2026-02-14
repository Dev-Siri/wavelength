import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_flutter/adapters.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/enums/video_type.dart";
import "package:wavelength/api/models/track.dart";
import "package:wavelength/api/repositories/track_repo.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/widgets/ui/amplitude.dart";

class LikeButton extends StatefulWidget {
  final Track track;
  final VideoType videoType;
  final double? size;

  const LikeButton({
    super.key,
    required this.track,
    required this.videoType,
    this.size,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool _isLiked = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchIsAlreadyLiked();
  }

  Future<void> _fetchIsAlreadyLiked() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthStateAuthorized) return;

    final box = await Hive.openBox(hiveIsLikedKey);
    final isLikedCached = box.get(widget.track.videoId);

    if (isLikedCached != null) {
      setState(() => _isLiked = isLikedCached);
    }

    final isLikedResponse = await TrackRepo.fetchIsAlreadyLiked(
      authToken: authState.authToken,
      videoId: widget.track.videoId,
    );

    if (isLikedResponse is ApiResponseSuccess<bool>) {
      await box.put(widget.track.videoId, isLikedResponse.data);
      if (mounted) setState(() => _isLiked = isLikedResponse.data);
    }
  }

  Future<void> _likeTrack() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthStateAuthorized) return;

    setState(() => _isLoading = true);

    int duration = widget.track.duration;

    if (duration == 0) {
      final durationResponse = await TrackRepo.fetchTrackDuration(
        trackId: widget.track.videoId,
      );

      if (durationResponse is! ApiResponseSuccess<int>) return;

      duration = durationResponse.data;
    }

    final likeResponse = await TrackRepo.likeTrack(
      authToken: authState.authToken,
      videoType: widget.videoType,
      track: Track(
        videoId: widget.track.videoId,
        album: widget.track.album,
        artists: widget.track.artists,
        duration: duration,
        isExplicit: widget.track.isExplicit,
        thumbnail: widget.track.thumbnail,
        title: widget.track.title,
      ),
    );

    if (likeResponse is ApiResponseSuccess<String>) {
      setState(() => _isLiked = !_isLiked);
      final box = await Hive.openBox(hiveIsLikedKey);
      await box.put(widget.track.videoId, _isLiked);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AmplIconButton(
      padding: EdgeInsets.zero,
      onPressed: _likeTrack,
      disabled: _isLoading,
      icon: Icon(
        _isLiked ? Icons.favorite : Icons.favorite_outline_outlined,
        size: widget.size ?? 18,
        color: _isLiked ? Colors.red : Colors.grey,
      ),
    );
  }
}
