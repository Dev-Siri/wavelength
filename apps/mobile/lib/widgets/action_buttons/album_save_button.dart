import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:glass/glass.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/repositories/album_repo.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/bloc/library/library_bloc.dart";
import "package:wavelength/bloc/library/library_event.dart";
import "package:wavelength/constants.dart";
import "package:wavelength/widgets/ui/ampl_icon_button.dart";

class AlbumSaveButton extends StatefulWidget {
  final String albumId;
  const AlbumSaveButton({super.key, required this.albumId});

  @override
  State<AlbumSaveButton> createState() => _AlbumSaveButtonState();
}

class _AlbumSaveButtonState extends State<AlbumSaveButton> {
  bool _isAlbumSaved = false;

  @override
  void initState() {
    super.initState();
    _fetchIsAlbumSaved();
  }

  Future<void> _fetchIsAlbumSaved() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthStateAuthorized) return;

    final connectivity = Connectivity();
    final connectivityResult = await connectivity.checkConnectivity();

    final box = await Hive.openBox(hiveIsAlbumSavedKey);
    final cachedIsSaved = box.get(widget.albumId);

    if (cachedIsSaved != null) {
      setState(() => _isAlbumSaved = cachedIsSaved);
      if (connectivityResult.contains(ConnectivityResult.none)) return;
    }

    final isSavedResponse = await AlbumRepo.fetchIsAlbumSaved(
      albumId: widget.albumId,
      authToken: authState.authToken,
    );

    if (isSavedResponse is ApiResponseSuccess<bool>) {
      box.put(widget.albumId, isSavedResponse.data);
      setState(() => _isAlbumSaved = isSavedResponse.data);
    }
  }

  Future<void> _saveAlbum({
    required String authToken,
    required String email,
  }) async {
    setState(() => _isAlbumSaved = !_isAlbumSaved);
    final libraryBloc = context.read<LibraryBloc>();
    final albumSaveResponse = await AlbumRepo.saveAlbum(
      albumId: widget.albumId,
      authToken: authToken,
    );

    if (albumSaveResponse is ApiResponseSuccess<void>) {
      return libraryBloc.add(
        LibraryFetchEvent(email: email, authToken: authToken),
      );
    }

    setState(() => _isAlbumSaved = !_isAlbumSaved);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthStateAuthorized) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: AmplIconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                _isAlbumSaved ? Icons.star : Icons.star_outline,
                size: 24,
              ),
              onPressed: () => _saveAlbum(
                authToken: state.authToken,
                email: state.user.email,
              ),
            ).asGlass(),
          ),
        );
      },
    );
  }
}
