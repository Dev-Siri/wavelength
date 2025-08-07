import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/bloc/public_playlists/public_playlists_bloc.dart";
import "package:wavelength/bloc/search/artists/artists_bloc.dart";
import "package:wavelength/bloc/search/artists/artists_event.dart";
import "package:wavelength/bloc/search/tracks/tracks_bloc.dart";
import "package:wavelength/bloc/search/tracks/tracks_event.dart";
import "package:wavelength/bloc/search/videos/videos_bloc.dart";
import "package:wavelength/bloc/search/videos/videos_event.dart";
import "package:wavelength/screens/search_presenters/artists_search_presenter.dart";
import "package:wavelength/screens/search_presenters/playlists_search_presenter.dart";
import "package:wavelength/screens/search_presenters/tracks_search_presenter.dart";
import "package:wavelength/bloc/public_playlists/public_playlists_event.dart";
import "package:wavelength/screens/search_presenters/videos_search_presenter.dart";

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

enum SearchType { playlists, tracks, videos, artists }

class _ExploreScreenState extends State<ExploreScreen> {
  Timer? _debounce;
  SearchType _searchType = SearchType.playlists;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  String _getInputHintText() {
    switch (_searchType) {
      case SearchType.playlists:
        return "playlists";
      case SearchType.artists:
        return "artists";
      case SearchType.videos:
        return "YouTube videos";
      default:
        return "songs";
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      switch (_searchType) {
        case SearchType.playlists:
          context.read<PublicPlaylistsBloc>().add(
            PublicPlaylistsFetchEvent(query: query == "" ? null : query),
          );
          break;
        case SearchType.tracks:
          if (query != "") {
            context.read<TracksBloc>().add(TracksFetchEvent(query: query));
          }
          break;
        case SearchType.videos:
          if (query != "") {
            context.read<VideosBloc>().add(VideosFetchEvent(query: query));
          }
          break;
        case SearchType.artists:
          if (query != "") {
            context.read<ArtistsBloc>().add(ArtistsFetchEvent(query: query));
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView(
        children: [
          SizedBox(height: 20),
          TextField(
            onChanged: _onSearchChanged,
            style: TextStyle(color: Colors.black),
            cursorColor: Colors.blue,
            autocorrect: false,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Search for ${_getInputHintText()}...",
              hintStyle: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w900,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(LucideIcons.compass, color: Colors.grey),
              ),
            ),
          ),
          Row(
            spacing: 4,
            children: [
              ChoiceChip(
                label: const Text("Playlists"),
                selectedColor: Colors.white,
                selected: _searchType == SearchType.playlists,
                onSelected:
                    (_) => setState(() => _searchType = SearchType.playlists),
              ),
              ChoiceChip(
                label: const Text("Tracks"),
                selectedColor: Colors.white,
                selected: _searchType == SearchType.tracks,
                onSelected:
                    (_) => setState(() => _searchType = SearchType.tracks),
              ),
              ChoiceChip(
                label: const Text("Videos"),
                selectedColor: Colors.white,
                selected: _searchType == SearchType.videos,
                onSelected:
                    (_) => setState(() => _searchType = SearchType.videos),
              ),
              ChoiceChip(
                label: const Text("Artist"),
                selectedColor: Colors.white,
                selected: _searchType == SearchType.artists,
                onSelected:
                    (_) => setState(() => _searchType = SearchType.artists),
              ),
            ],
          ),
          SizedBox(height: 10),
          if (_searchType == SearchType.playlists) PlaylistsSearchPresenter(),
          if (_searchType == SearchType.tracks) TracksSearchPresenter(),
          if (_searchType == SearchType.videos) VideosSearchPresenter(),
          if (_searchType == SearchType.artists) ArtistsSearchPresenter(),
        ],
      ),
    );
  }
}
