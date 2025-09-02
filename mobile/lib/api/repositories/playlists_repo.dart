import "dart:convert";

import "package:http/http.dart" as http;
import "package:flutter/foundation.dart";
import "package:wavelength/api/models/api_response.dart";
import "package:wavelength/api/models/playlist.dart";
import "package:wavelength/api/models/playlist_theme_color.dart";
import "package:wavelength/api/models/playlist_track.dart";
import "package:wavelength/api/models/playlist_tracks_length.dart";
import "package:wavelength/constants.dart";

class PlaylistsRepo {
  static Future<ApiResponse> fetchUserPlaylists({required String email}) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/playlists/user/$email"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse = await compute((stringResponse) {
        final decodedJson = jsonDecode(stringResponse);
        final decodedData = ApiResponse.fromJson(decodedJson, (playlists) {
          final listOfItems = playlists as List?;

          if (listOfItems == null) return [];

          return listOfItems
              .map((final playlist) => Playlist.fromJson(playlist))
              .toList();
        });

        return decodedData;
      }, utf8BodyDecoded);

      return decodedResponse;
    } catch (_) {
      return ApiResponse(success: false, data: null);
    }
  }

  static Future<ApiResponse> fetchPublicPlaylists({required String? q}) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/playlists${q != null ? "?q=$q" : ""}"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse = await compute((stringResponse) {
        final decodedJson = jsonDecode(stringResponse);
        final decodedData = ApiResponse.fromJson(decodedJson, (playlists) {
          final listOfItems = playlists as List?;

          if (listOfItems == null) return [];

          return listOfItems
              .map((final playlist) => Playlist.fromJson(playlist))
              .toList();
        });

        return decodedData;
      }, utf8BodyDecoded);

      return decodedResponse;
    } catch (_) {
      return ApiResponse(success: false, data: null);
    }
  }

  static Future<ApiResponse> fetchPlaylistTracks({
    required String playlistId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/playlists/$playlistId/tracks"),
      );
      final utf8BodyDecoded = utf8.decode(response.bodyBytes);
      final decodedResponse = await compute((stringResponse) {
        final decodedJson = jsonDecode(stringResponse);
        final decodedData = ApiResponse.fromJson(decodedJson, (tracks) {
          final listOfItems = tracks as List?;

          if (listOfItems == null) return [];

          return listOfItems
              .map((final track) => PlaylistTrack.fromJson(track))
              .toList();
        });

        return decodedData;
      }, utf8BodyDecoded);

      return decodedResponse;
    } catch (_) {
      return ApiResponse(success: false, data: null);
    }
  }

  static Future<ApiResponse> fetchPlaylistTracksLength({
    required String playlistId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse("$backendUrl/playlists/$playlistId/length"),
      );
      final decodedResponse = await compute((stringResponse) {
        final decodedJson = jsonDecode(stringResponse);
        final decodedData = ApiResponse.fromJson(
          decodedJson,
          (tracksLength) => PlaylistTracksLength.fromJson(tracksLength),
        );

        return decodedData;
      }, response.body);

      return decodedResponse;
    } catch (_) {
      return ApiResponse(success: false, data: null);
    }
  }

  static Future<ApiResponse> fetchPlaylistThemeColor({
    required String playlistId,
    required String playlistImageUrl,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$backendUrl/playlists/$playlistId/theme-color?playlistImageUrl=$playlistImageUrl",
        ),
      );
      final decodedResponse = await compute((stringResponse) {
        final decodedJson = jsonDecode(stringResponse);
        final decodedData = ApiResponse.fromJson(
          decodedJson,
          (playlistThemeColor) => ThemeColor.fromJson(playlistThemeColor),
        );

        return decodedData;
      }, response.body);

      return decodedResponse;
    } catch (_) {
      return ApiResponse(success: false, data: null);
    }
  }

  static Future<ApiResponse> createPlaylist({
    required String email,
    required String username,
    required String image,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          "$backendUrl/playlists/user/$email?authorName=$username&authorImage=$image",
        ),
      );

      final decodedResponse = await compute((stringResponse) {
        final decodedJson = jsonDecode(stringResponse);
        final decodedData = ApiResponse<String>.fromJson(decodedJson, null);

        return decodedData;
      }, response.body);

      return decodedResponse;
    } catch (_) {
      return ApiResponse(success: false, data: null);
    }
  }

  static Future<ApiResponse> deletePlaylist({
    required String playlistId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse("$backendUrl/playlists/$playlistId"),
      );

      final decodedResponse = await compute((stringResponse) {
        final decodedJson = jsonDecode(stringResponse);
        final decodedData = ApiResponse<String>.fromJson(decodedJson, null);

        return decodedData;
      }, response.body);

      return decodedResponse;
    } catch (_) {
      return ApiResponse(success: false, data: null);
    }
  }

  static Future<ApiResponse> editPlaylist({
    required String playlistName,
    required String? coverImage,
    required String playlistId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$backendUrl/playlists/$playlistId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": playlistName, "coverImage": coverImage}),
      );

      final decodedResponse = await compute((stringResponse) {
        final decodedJson = jsonDecode(stringResponse);
        final decodedData = ApiResponse<String>.fromJson(decodedJson, null);

        return decodedData;
      }, response.body);

      return decodedResponse;
    } catch (_) {
      return ApiResponse(success: false, data: null);
    }
  }
}
