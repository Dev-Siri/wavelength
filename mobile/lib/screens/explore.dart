import "dart:async";
import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/search_recommendations.dart";
import "package:wavelength/api/repositories/search_repo.dart";
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
  SearchType _searchType = SearchType.tracks;
  String _searchQuery = "";
  List<String> _suggestions = [];

  // These track whether the data for one particular _searchQuery has already been fetched.
  // Later it is used to prevent refetching on searchType change but same _searchQuery.
  bool _arePlaylistsFetched = false;
  bool _areVideosFetched = false;
  bool _areTracksFetched = false;
  bool _areArtistsFetched = false;

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
    setState(() {
      if (_searchQuery != query) {
        _arePlaylistsFetched = false;
        _areVideosFetched = false;
        _areTracksFetched = false;
        _areArtistsFetched = false;
      }

      _searchQuery = query;
    });

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      switch (_searchType) {
        case SearchType.playlists:
          context.read<PublicPlaylistsBloc>().add(
            PublicPlaylistsFetchEvent(query: query == "" ? null : query),
          );
          setState(() => _arePlaylistsFetched = true);
          break;
        case SearchType.tracks:
          if (query != "") {
            context.read<TracksBloc>().add(TracksFetchEvent(query: query));
            setState(() => _areTracksFetched = true);
          }
          break;
        case SearchType.videos:
          if (query != "") {
            context.read<VideosBloc>().add(VideosFetchEvent(query: query));
            setState(() => _areVideosFetched = true);
          }
          break;
        case SearchType.artists:
          if (query != "") {
            context.read<ArtistsBloc>().add(ArtistsFetchEvent(query: query));
            setState(() => _areArtistsFetched = true);
          }
          break;
      }
    });
  }

  void _changeSearchType(SearchType searchType) {
    setState(() => _searchType = searchType);

    bool shouldFetch = false;

    switch (searchType) {
      case SearchType.playlists:
        shouldFetch = !_arePlaylistsFetched;
        break;
      case SearchType.tracks:
        shouldFetch = !_areTracksFetched;
        break;
      case SearchType.videos:
        shouldFetch = !_areVideosFetched;
        break;
      case SearchType.artists:
        shouldFetch = !_areArtistsFetched;
        break;
    }

    if (shouldFetch) {
      _onSearchChanged(_searchQuery);
    }
  }

  Future<void> _updateSuggestions(String query) async {
    if (query.isEmpty) {
      return setState(() => _suggestions = []);
    }

    final response = await SearchRepo.fetchSearchRecommendations(query: query);

    setState(() {
      if (response is ApiResponseSuccess<SearchRecommendations>) {
        _suggestions = response.data.matchingQueries;
      } else {
        _suggestions = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 20),
        Autocomplete(
          optionsBuilder: (textEditingValue) => _suggestions,
          optionsViewBuilder: (context, onSelected, options) {
            return Column(
              children: options.map((option) {
                final innerUi = Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1, color: Colors.grey.shade800),
                    ),
                  ),
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    option,
                    style: const TextStyle(color: Colors.white),
                  ),
                );

                return ClipRRect(
                  borderRadius: option == options.last
                      ? const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        )
                      : BorderRadius.zero,
                  child: Platform.isIOS
                      ? CupertinoButton.filled(
                          onPressed: () => onSelected(option),
                          padding: EdgeInsets.zero,
                          color: Colors.black,
                          child: innerUi,
                        )
                      : MaterialButton(
                          onPressed: () => onSelected(option),
                          padding: EdgeInsets.zero,
                          color: Colors.black,
                          child: innerUi,
                        ),
                );
              }).toList(),
            );
          },
          onSelected: (option) {
            setState(() => _searchQuery = option);
            _onSearchChanged(option);
            _updateSuggestions(option);
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: (value) {
                _onSearchChanged(value);
                _updateSuggestions(value);
              },
              style: const TextStyle(color: Colors.black),
              cursorColor: Colors.blue,
              autocorrect: false,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Search for ${_getInputHintText()}...",
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w900,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(LucideIcons.compass, color: Colors.grey),
                ),
              ),
            );
          },
        ),
        Row(
          spacing: 4,
          children: [
            ChoiceChip(
              label: const Text("Tracks"),
              selectedColor: Colors.white,
              selected: _searchType == SearchType.tracks,
              onSelected: (_) => _changeSearchType(SearchType.tracks),
            ),
            ChoiceChip(
              label: const Text("Videos"),
              selectedColor: Colors.white,
              selected: _searchType == SearchType.videos,
              onSelected: (_) => _changeSearchType(SearchType.videos),
            ),
            ChoiceChip(
              label: const Text("Artist"),
              selectedColor: Colors.white,
              selected: _searchType == SearchType.artists,
              onSelected: (_) => _changeSearchType(SearchType.artists),
            ),
            ChoiceChip(
              label: const Text("Playlists"),
              selectedColor: Colors.white,
              selected: _searchType == SearchType.playlists,
              onSelected: (_) => _changeSearchType(SearchType.playlists),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_searchType == SearchType.playlists)
          const PlaylistsSearchPresenter(),
        if (_searchType == SearchType.tracks) const TracksSearchPresenter(),
        if (_searchType == SearchType.videos) const VideosSearchPresenter(),
        if (_searchType == SearchType.artists) const ArtistsSearchPresenter(),
        if (_searchQuery == "" &&
            _searchType != SearchType.playlists &&
            !_areArtistsFetched &&
            !_areTracksFetched &&
            !_areVideosFetched)
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.sizeOf(context).height / 4,
            ),
            child: const Center(
              child: Text(
                "Try searching for something.",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
      ],
    );
  }
}
