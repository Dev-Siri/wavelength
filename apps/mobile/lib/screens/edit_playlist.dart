import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/svg.dart";
import "package:go_router/go_router.dart";
import "package:image_picker/image_picker.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:vector_graphics/vector_graphics.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/uploadthing_file.dart";
import "package:wavelength/api/repositories/image_repo.dart";
import "package:wavelength/api/repositories/playlists_repo.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_bloc.dart";
import "package:wavelength/bloc/app_bottom_sheet/app_bottom_sheet_event.dart";
import "package:wavelength/bloc/auth/auth_bloc.dart";
import "package:wavelength/bloc/auth/auth_state.dart";
import "package:wavelength/bloc/library/library_bloc.dart";
import "package:wavelength/bloc/library/library_event.dart";
import "package:wavelength/bloc/playlist/playlist_bloc.dart";
import "package:wavelength/bloc/playlist/playlist_event.dart";
import "package:wavelength/utils/toaster.dart";
import "package:wavelength/widgets/brand_cover_image.dart";

@immutable
class EditPlaylistRouteData {
  final String playlistName;
  final String? coverImage;

  const EditPlaylistRouteData({
    required this.playlistName,
    required this.coverImage,
  });
}

class EditPlaylistScreen extends StatefulWidget {
  final String playlistId;
  final EditPlaylistRouteData routeData;

  const EditPlaylistScreen({
    super.key,
    required this.playlistId,
    required this.routeData,
  });

  @override
  State<EditPlaylistScreen> createState() => _EditPlaylistScreenState();
}

class _EditPlaylistScreenState extends State<EditPlaylistScreen> with Toaster {
  final _nameInputControl = TextEditingController();

  bool _isLoading = false;
  bool _hasFileUploadErrored = false;
  XFile? _pickedCoverImage;

  @override
  void initState() {
    super.initState();
    _nameInputControl.text = widget.routeData.playlistName;
  }

  Future<String?> _handleFileUpload() async {
    setState(() => _hasFileUploadErrored = false);
    if (_pickedCoverImage == null) {
      return widget.routeData.coverImage;
    }

    final uploadThingResponse = await ImageRepo.uploadImage(_pickedCoverImage!);

    if (uploadThingResponse is ApiResponseSuccess<UploadThingFile>) {
      return uploadThingResponse.data.url;
    }

    setState(() => _hasFileUploadErrored = true);
    return null;
  }

  Future<void> _confirmEdit() async {
    setState(() => _isLoading = true);

    final appBottomSheet = context.read<AppBottomSheetBloc>();
    final appBottomSheetCloseEvent = AppBottomSheetCloseEvent(context: context);
    final libraryBloc = context.read<LibraryBloc>();
    final playlistBloc = context.read<PlaylistBloc>();
    final authBlocState = context.read<AuthBloc>().state;

    final coverImageUrl = await _handleFileUpload();

    if (_hasFileUploadErrored) {
      if (mounted) {
        showToast(
          context,
          "An error occured while uploading cover image.",
          ToastType.error,
        );
      }
      return;
    }

    final response = await PlaylistsRepo.editPlaylist(
      playlistName: _nameInputControl.text,
      coverImage: coverImageUrl,
      playlistId: widget.playlistId,
    );

    if (response is ApiResponseSuccess &&
        authBlocState is AuthStateAuthorized) {
      libraryBloc.add(
        LibraryFetchEvent(
          email: authBlocState.user.email,
          authToken: authBlocState.authToken,
        ),
      );
      playlistBloc.add(PlaylistFetchEvent(playlistId: widget.playlistId));
      setState(() => _isLoading = false);
      appBottomSheet.add(appBottomSheetCloseEvent);
      return;
    }

    setState(() => _isLoading = false);

    if (mounted) {
      showToast(
        context,
        "An error occured while updating playlist.",
        ToastType.error,
      );
    }
  }

  Future<void> _handleImagePicker() async {
    final picker = ImagePicker();
    final rawImage = await picker.pickImage(source: ImageSource.gallery);

    if (rawImage == null) return;

    setState(() => _pickedCoverImage = rawImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(onPressed: () => context.pop()),
        centerTitle: true,
        title: const SvgPicture(
          AssetBytesLoader("assets/vectors/lambda.svg.vec"),
          height: 45,
          width: 45,
        ),
      ),
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _handleImagePicker,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Opacity(
                    opacity: 0.5,
                    child: _pickedCoverImage == null
                        ? BrandCoverImage(imageUrl: widget.routeData.coverImage)
                        : SizedBox(
                            height: 300,
                            width: 300,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: FutureBuilder(
                                future: _pickedCoverImage!.readAsBytes(),
                                builder: (context, snapshot) {
                                  if (snapshot.data == null) {
                                    return const SizedBox.shrink();
                                  }

                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          ),
                  ),
                ),
                Column(
                  children: [
                    const Icon(LucideIcons.image, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      "Click to pick${widget.routeData.coverImage == null ? " " : " a new "}cover image.",
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Platform.isIOS
                ? CupertinoTextField(
                    controller: _nameInputControl,
                    cursorColor: Colors.white,
                    placeholder: "Playlist Name",
                    style: const TextStyle(fontSize: 30),
                  )
                : TextField(
                    controller: _nameInputControl,
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                      hintText: "Playlist Name",
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 3),
                      ),
                    ),
                    style: const TextStyle(fontSize: 30),
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CupertinoButton(
                onPressed: _isLoading ? null : _confirmEdit,
                color: Colors.white,
                disabledColor: Colors.white.withAlpha(80),
                child: Row(
                  children: [
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator.adaptive(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                            strokeWidth: 1,
                          ),
                        ),
                      ),
                    const Text(
                      "Confirm Edit",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ],
      ),
    );
  }
}
