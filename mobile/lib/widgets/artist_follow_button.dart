import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_flutter/adapters.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/repositories/artist_repo.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/widgets/ui/ampl_button.dart";

class ArtistFollowButton extends StatefulWidget {
  final String name;
  final String thumbnail;
  final String browseId;

  const ArtistFollowButton({
    super.key,
    required this.browseId,
    required this.name,
    required this.thumbnail,
  });

  @override
  State<ArtistFollowButton> createState() => _ArtistFollowButtonState();
}

class _ArtistFollowButtonState extends State<ArtistFollowButton> {
  bool _isFollowing = false;
  bool _isLoading = false;

  @override
  void initState() {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthStateAuthorized) {
      _fetchIsFollowing(authState.authToken);
    }
    super.initState();
  }

  Future<void> _fetchIsFollowing(String authToken) async {
    final isFollowingBox = await Hive.openBox(hiveIsFollowingKey);
    final isFollowingArtistCached = isFollowingBox.get(widget.browseId);

    if (isFollowingArtistCached != null) {
      return setState(() => _isFollowing = isFollowingArtistCached);
    }

    final isFollowing = await ArtistRepo.fetchIsFollowingArtist(
      authToken: authToken,
      browseId: widget.browseId,
    );

    if (isFollowing is ApiResponseSuccess<bool>) {
      await isFollowingBox.put(widget.browseId, isFollowing.data);
      setState(() => _isFollowing = isFollowing.data);
    }
  }

  Future<void> _toggleArtistFollow(String authToken) async {
    setState(() => _isLoading = true);
    final followResponse = await ArtistRepo.followArtist(
      authToken: authToken,
      browseId: widget.browseId,
      name: widget.name,
      thumbnail: widget.thumbnail,
    );

    if (followResponse is ApiResponseSuccess<String>) {
      final isFollowingBox = await Hive.openBox(hiveIsFollowingKey);
      setState(() => _isFollowing = !_isFollowing);
      await isFollowingBox.put(widget.browseId, _isFollowing);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthStateAuthorized) return const SizedBox.shrink();

        return AmplButton(
          onPressed: () => _toggleArtistFollow(state.authToken),
          disabled: _isLoading,
          padding: const EdgeInsets.symmetric(horizontal: 25),
          color: _isFollowing ? Colors.grey.shade900 : Colors.white,
          child: Text(
            _isFollowing ? "Following" : "Follow",
            style: TextStyle(color: _isFollowing ? Colors.white : Colors.black),
          ),
        );
      },
    );
  }
}
